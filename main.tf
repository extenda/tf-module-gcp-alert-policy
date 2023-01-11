locals {
  default_notification_channels = [for nc in var.default_notification_channels : try(var.notification_channel_ids[nc], nc)]
  default_combiner              = "OR"
  default_comparison            = "COMPARISON_GT"
  default_duration              = "0s"
  default_trigger_count         = 1
  default_auto_close            = "86400s" # 24h
}

resource "google_monitoring_alert_policy" "alert_policy" {
  for_each = { for alert in var.policies : alert.display_name => alert }

  project      = var.project
  display_name = each.value.display_name
  enabled      = try(each.value.enabled, true)
  combiner     = try(each.value.combiner, local.default_combiner)
  user_labels  = merge(var.default_user_labels, try(each.value.user_labels, {}))
  notification_channels = concat(
    local.default_notification_channels,
    [for nc in try(each.value.notification_channels, []) : try(var.notification_channel_ids[nc], nc)],
  )

  dynamic "conditions" {
    for_each = each.value.conditions
    content {
      display_name = conditions.value.display_name

      dynamic "condition_threshold" {
        for_each = try([conditions.value.condition_threshold], [])
        content {
          comparison         = try(condition_threshold.value.comparison, local.default_comparison)
          filter             = try(condition_threshold.value.filter, null)
          threshold_value    = try(condition_threshold.value.threshold_value, null)
          duration           = try(condition_threshold.value.duration, local.default_duration)
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
            count   = try(condition_threshold.value.trigger.count, local.default_trigger_count)
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
            count   = try(condition_monitoring_query_language.value.trigger.count, local.default_trigger_count)
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
    auto_close = try(each.value.alert_strategy.auto_close, local.default_auto_close)

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
