## Inputs

| Name                           | Description                                                                                                                                                                                                                   | Type        | Default | Required |
| ------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- | ------- | :------: |
| `project`                      | Project ID to create alerts in                                                                                                                                                                                                | `string`    | n/a     |   yes    |
| `default_user_labels`          | Labels to be set for **all** alerts                                                                                                                                                                                           | `map(any)`  | n/a     |    no    |
| `fallback_notification_channels` | NCs to be set for all alerts that don't provide `notification_channels`. Provide the NCs "id" or "display name" (the latter is dependent on the notification_channel_ids variable) [Example](./examples/main.tf#L5) | `list(any)` | n/a     |    no    |
| `notification_channel_ids`    | To be able to provide channels display name instead of id/name, provide a map { display_name: name } or output from tf-module-gcp-notification-channels.                                                                      | `map(any)`  | n/a     |   yes    |
| `policies`                    | The list of alert policies configurations (More info below..)                                                                                                                                                                 | `list(any)` | n/a     |   yes    |

## `policies`

This variable should contain the actual list of alert configs, and should be structured as shown below. \
📖 [Terraform Docs](https://registry.terraform.io/providers/hashicorp/google/5.14.0/docs/resources/monitoring_alert_policy) \
✅ [Examples](./examples/)

```hcl
policies = [
  {
    display_name          = string                    // The Alert name
    enabled               = optional(boolean)         // Whether or not the policy is enabled (default: true)
    combiner              = optional(string)          // How to combine the results of multiple conditions (default: "OR")
    user_labels           = optional(map(string))     // Labels for the alert, merged with var.default_user_labels
    notification_channels = optional(list(string))    // List of Notification Channel IDs for the alert
    severity              = optional(string)          // Severity of the alert (e.g., "CRITICAL", "WARNING", etc.)

    alert_strategy = optional({
      auto_close = optional(string)                   // Auto close the alert after a certain duration (default: "86400s" - 24 hours)
      notification_rate_limit = optional({
        period = optional(string)                     // Rate limit period for notifications (default: "900s" - 15 minutes)
      })
    })

    documentation = optional({
      content   = optional(string)                    // Documentation content in text or markdown
      mime_type = optional(string)                    // MIME type of the documentation (default: "text/markdown")
      subject   = optional(string)                    // The subject line of the notification.
    })

    conditions = [{
      display_name = string                           // The condition name

      condition_threshold = optional({
        comparison              = optional(string)    // Comparison type (default: "COMPARISON_GT")
        filter                  = optional(string)    // Time series filter
        threshold_value         = optional(number)    // Value to compare against
        duration                = optional(string)    // Duration for threshold violation (default: "0s")
        denominator_filter      = optional(string)    // Filter for denominator time series

        aggregations = optional([{
          alignment_period       = optional(string)   // Period for alignment
          per_series_aligner     = optional(string)   // Per-series aligner function
          cross_series_reducer   = optional(string)   // Cross-series reducer function
          group_by_fields        = optional(list(string)) // Fields to group by
        }])

        denominator_aggregations = optional([{
          alignment_period     = optional(string)     // Period for per-time series alignment.
          per_series_aligner   = optional(string)     // The Alignment function. (default: "ALIGN_NONE")
          cross_series_reducer = optional(string)     // How to combine the time series.
          group_by_fields      = optional([])         // The set of fields to preserve when cross_series_reducer is specified.
        }])

        trigger = optional({
          count                  = optional(number)   // Trigger count threshold
          percent                = optional(number)   // Trigger percent threshold
        })

        forecast_options = optional({
          forecast_horizon       = optional(string)   // Forecast horizon for prediction
        })
      })

      condition_monitoring_query_language = optional({
        query                   = optional(string)    // The Monitoring Query Language (MQL) query
        duration                = optional(string)    // Duration for evaluating the query
        evaluation_missing_data = optional(string)    // Behavior when data is missing (default: "EVALUATION_MISSING_DATA_NO_OP")

        trigger = {
          count                  = optional(number)   // Number of timeseries to trigger the alert
          percent                = optional(number)   // Percentage of timeseries to trigger the alert
        }
      })

      condition_prometheus_query_language = optional({
        evaluation_interval = optional(string)        // The interval over which to evaluate the condition.
        labels              = optional(map(string))   // A set of labels to attach to the alert.
        rule_group          = optional(string)        // The name of the Prometheus rule group.
        alert_rule          = optional(string)        // The name of the specific Prometheus alert rule.
      })

      condition_matched_log = optional({
        filter           = optional(string)           // A logs-based filter for matching log entries
        label_extractors = optional(map(string))      // Map of labels to extract from log entries
      })

      condition_absent = optional({
        duration        = optional(string)            // Duration to check for the absence of data
        filter          = optional(string)            // Filter to identify which time series are absent
        aggregations    = optional([{
          alignment_period       = optional(string)   // Period for alignment
          per_series_aligner     = optional(string)   // Per-series aligner function
          cross_series_reducer   = optional(string)   // Cross-series reducer function
          group_by_fields        = optional(list(string)) // Fields to group by
        }])
        trigger = {
          count                  = optional(number)   // Number of timeseries to trigger the alert
          percent                = optional(number)   // Percentage of timeseries to trigger the alert
        }
      })
    }]
  }
]
```
