resource "google_monitoring_alert_policy" "alert_policy" {
  for_each = { for alert in var.policies : alert.display_name => alert }

  project               = var.monitoring_project_id
  display_name          = each.value["display_name"]
  user_labels           = var.user_labels
  notification_channels = concat(var.notification_channels, lookup(each.value, "extra_notification_channels", []))
  enabled               = lookup(each.value, "enabled", "true")
  combiner              = lookup(each.value, "combiner", "OR")

  dynamic "conditions" {
    for_each = each.value["conditions"]
    content {
      display_name = conditions.value["display_name"]
      dynamic "condition_threshold" {
        for_each = length(lookup(conditions.value, "condition_threshold", [])) >= 1 ? [1] : []
        content {
          comparison         = lookup(conditions.value.condition_threshold, "comparison", "COMPARISON_GT")
          filter             = lookup(conditions.value.condition_threshold, "filter", null)
          threshold_value    = lookup(conditions.value.condition_threshold, "threshold_value", null)
          duration           = lookup(conditions.value.condition_threshold, "duration", "0s")
          denominator_filter = lookup(conditions.value.condition_threshold, "denominator_filter", "")

          dynamic "aggregations" {
            for_each = lookup(conditions.value.condition_threshold, "aggregations", [])
            content {
              alignment_period     = lookup(aggregations.value, "alignment_period", null)
              per_series_aligner   = lookup(aggregations.value, "per_series_aligner", null)
              cross_series_reducer = lookup(aggregations.value, "cross_series_reducer", null) == "REDUCE_NONE" ? null : lookup(aggregations.value, "cross_series_reducer", null)
              group_by_fields      = lookup(aggregations.value, "group_by_fields", [])
            }
          }

          dynamic "denominator_aggregations" {
            for_each = length(lookup(conditions.value.condition_threshold, "denominator_aggregations", [])) >= 1 ? [1] : []
            content {
              alignment_period     = lookup(conditions.value.denominator_aggregations, "alignment_period", null)
              per_series_aligner   = lookup(conditions.value.denominator_aggregations, "per_series_aligner", null)
              cross_series_reducer = lookup(conditions.value.denominator_aggregations, "cross_series_reducer", null)
              group_by_fields      = lookup(conditions.value.denominator_aggregations, "group_by_fields", [])
            }
          }

          trigger {
            count   = lookup(lookup(conditions.value.condition_threshold, "trigger", {}), "count", 1)
            percent = lookup(lookup(conditions.value.condition_threshold, "trigger", {}), "percent", null)
          }
        }
      }

      dynamic "condition_monitoring_query_language" {
        for_each = length(lookup(conditions.value, "condition_monitoring_query_language", [])) >= 1 ? [1] : []
        content {
          query                   = lookup(conditions.value.condition_monitoring_query_language, "query", "")
          duration                = lookup(conditions.value.condition_monitoring_query_language, "duration", "")
          evaluation_missing_data = lookup(conditions.value.condition_monitoring_query_language, "evaluation_missing_data", null)

          trigger {
            count   = lookup(lookup(conditions.value.condition_monitoring_query_language, "trigger", {}), "count", 1)
            percent = lookup(lookup(conditions.value.condition_monitoring_query_language, "trigger", {}), "percent", null)
          }
        }
      }

      dynamic "condition_matched_log" {
        for_each = length(lookup(conditions.value, "condition_matched_log", [])) >= 1 ? [1] : []
        content {
          filter           = lookup(conditions.value.condition_matched_log, "filter", "")
          label_extractors = lookup(conditions.value.condition_matched_log, "label_extractors", null)
        }
      }
    }
  }

  dynamic "alert_strategy" {
    for_each = length(lookup(each.value, "alert_strategy", [])) >= 1 ? [1] : []
    content {
      auto_close = lookup(each.value.alert_strategy, "auto_close", null)
      notification_rate_limit {
        period = lookup(each.value.alert_strategy, "period", null)
      }
    }
  }

  documentation {
    mime_type = lookup(lookup(each.value, "documentation", {}), "mime_type", "text/markdown")
    content   = lookup(lookup(each.value, "documentation", {}), "content", " ")
  }
}
