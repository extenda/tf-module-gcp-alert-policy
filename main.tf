data "google_monitoring_notification_channel" "all" {
  for_each = toset(
    concat(
      var.default_notification_channels,
      flatten([for alert in var.policies : try(alert.notification_channels, [])])
    )
  )
  project      = var.project
  display_name = each.value
}

resource "google_monitoring_alert_policy" "alert_policy" {
  depends_on = [data.google_monitoring_notification_channel.all]
  for_each   = { for alert in var.policies : alert.display_name => alert }

  project      = var.project
  display_name = each.value.display_name
  enabled      = try(each.value.enabled, true)
  combiner     = try(each.value.combiner, "OR")
  user_labels  = merge(var.default_user_labels, try(each.value.user_labels, {}))
  notification_channels = concat(
    [for nc in data.google_monitoring_notification_channel.all : nc.id if contains(var.default_notification_channels, nc.display_name)],
    [for nc in data.google_monitoring_notification_channel.all : nc.id if contains(try(each.value.notification_channels, []), nc.display_name)]
  )

  dynamic "conditions" {
    for_each = each.value.conditions
    content {
      display_name = conditions.value.display_name

      dynamic "condition_threshold" {
        for_each = try([conditions.value.condition_threshold], [])
        content {
          comparison         = try(condition_threshold.value.comparison, "COMPARISON_GT")
          filter             = try(condition_threshold.value.filter, null)
          threshold_value    = try(condition_threshold.value.threshold_value, null)
          duration           = try(condition_threshold.value.duration, "0s")
          denominator_filter = try(condition_threshold.value.denominator_filter, "")

          dynamic "aggregations" {
            for_each = try(condition_threshold.value.aggregations, [])
            content {
              alignment_period     = try(aggregations.value.alignment_period, null)
              per_series_aligner   = try(aggregations.value.per_series_aligner, null)
              cross_series_reducer = try(aggregations.value.cross_series_reducer, null) == "REDUCE_NONE" ? null : try(aggregations.value.cross_series_reducer, null)
              group_by_fields      = try(aggregations.value.group_by_fields, [])
            }
          }

          dynamic "denominator_aggregations" {
            for_each = try([conditions.value.denominator_aggregations], [])
            content {
              alignment_period     = try(denominator_aggregations.value.alignment_period, null)
              per_series_aligner   = try(denominator_aggregations.value.per_series_aligner, null)
              cross_series_reducer = try(denominator_aggregations.value.cross_series_reducer, null)
              group_by_fields      = try(denominator_aggregations.value.group_by_fields, [])
            }
          }

          trigger {
            count   = try(condition_threshold.value.trigger.count, 1)
            percent = try(condition_threshold.value.trigger.percent, null)
          }
        }
      }

      dynamic "condition_monitoring_query_language" {
        for_each = try([conditions.value.condition_monitoring_query_language], [])
        content {
          query                   = try(condition_monitoring_query_language.value.query, "")
          duration                = try(condition_monitoring_query_language.value.duration, "")
          evaluation_missing_data = try(condition_monitoring_query_language.value.evaluation_missing_data, null)

          trigger {
            count   = try(condition_monitoring_query_language.value.trigger.count, 1)
            percent = try(condition_monitoring_query_language.value.trigger.percent, null)
          }
        }
      }

      dynamic "condition_matched_log" {
        for_each = try([conditions.value.condition_matched_log], [])
        content {
          filter           = try(condition_matched_log.value.filter, "")
          label_extractors = try(condition_matched_log.value.label_extractors, null)
        }
      }
    }
  }

  alert_strategy {
    auto_close = try(each.value.alert_strategy.auto_close, "86400s")

    dynamic "notification_rate_limit" {
      for_each = try([each.value.alert_strategy.notification_rate_limit], [])
      content {
        period = try(notification_rate_limit.value.period, null)
      }
    }
  }

  documentation {
    mime_type = try(each.value.documentation.mime_type, "text/markdown")
    content   = try(each.value.documentation.content, " ")
  }
}
