## Inputs

| Name                           | Description                                                                                                                                                                                                                   | Type        | Default | Required |
| ------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- | ------- | :------: |
| __project__                    | Project ID to create alerts in                                                                                                                                                                                                | `string`    | n/a     |   yes    |
| default_user_labels            | Labels to be set for __all__ alerts                                                                                                                                                                                           | `map(any)`  | n/a     |    no    |
| fallback_notification_channels | NCs to be set for all alerts that don't provide `notification_channels`. Provide the NCs "full path" or "display name" (the latter is dependant on the notification_channel_ids variable) [Example](./examples/main.tf#L5) | `list(any)` | n/a     |    no    |
| notification_channel_ids       | To be able to provide channels display name instead of id/name, provide a  be { display_name: name } or output from tf-module-gcp-notification-channels.                                                                      | `list(any)` | n/a     |   yes    |
| __policies__                   | The list of alert policies configurations (More info below..)                                                                                                                                                                 | `list(any)` | n/a     |   yes    |

## __policies__

This variable should contain the actual list of alert configs, and should be structured as shown below. \
📖 [Terraform Docs](https://registry.terraform.io/providers/hashicorp/google/4.47.0/docs/resources/monitoring_uptime_check_config) \
✅ [Examples](./examples/)

```hcl
policies = [
  {
    display_name          = string             // () : The Alert name
    enabled               = optional(boolean)  // (true) : Whether or not the policy is enabled
    combiner              = optional(string)   // (OR) - [AND, OR] : How to combine the results of multiple conditions.
    user_labels           = optional({})       // () : Labels for the alert. Will be merged with var.default_user_labels.
    notification_channels = optional([string]) // () : List of NCs. MUST be the "display_name"s of the notification channels!

    alert_strategy = optional({
      auto_close = optional(string) // (86400s) : Will auto close after x many seconds.

      notification_rate_limit = optional({ // Required for LogMatch condition.
        period = optional(string)          // () : I.e "60s".
      })
    })

    documentation = optional({
      content = optional(string) // () : The actual documentation in text or markdown.
    })

    conditions = [{
      display_name = string // () : The condition name

      condition_threshold = {
        comparison         = optional(string) // (COMPARISON_GT) - [COMPARISON_GT, COMPARISON_LT] : When to trigger the alert.
        filter             = optional(string) // () : A filter that identifies the time series.
        threshold_value    = optional(string) // () : A value against which to compare the time series.
        duration           = optional(string) // (0s) - [0s, 60s, 120s, 300s] : The time that a time series must violate the threshold.
        denominator_filter = optional(string) // () :  A filter that identifies a time series that should be used as the denominator.

        aggregations = optional([{
          alignment_period     = optional(string) // () : Period for per-time series alignment. 
          per_series_aligner   = optional(string) // (REDUCE_NONE) : The Alignment function.
          cross_series_reducer = optional(string) // () : How to combine the time series.
          group_by_fields      = optional([])     // () : The set of fields to preserve when cross_series_reducer is specified.
        }])

        denominator_aggregations = optional([{
          alignment_period     = optional(string) // () : Period for per-time series alignment. 
          per_series_aligner   = optional(string) // (REDUCE_NONE) : The Alignment function.
          cross_series_reducer = optional(string) // () : How to combine the time series.
          group_by_fields      = optional([])     // () : The set of fields to preserve when cross_series_reducer is specified.
        }])

        trigger = optional({
          count   = optional(number) // (1) : Number of timeseries that should fail in order to trigger the alert
          percent = optional(string) // () : Percentage of timeseries that should fail in order to trigger the alert
        })
      }

      condition_monitoring_query_language = optional({
        query                   = optional(string) // () : The MQL query.
        duration                = optional(string) // () : How long must a time series violate the threshold.
        evaluation_missing_data = optional(string) // () - [EVALUATION_MISSING_DATA_INACTIVE, EVALUATION_MISSING_DATA_ACTIVE, and EVALUATION_MISSING_DATA_NO_OP] 

        trigger = {
          count   = optional(number) // (1) : Number of timeseries that should fail in order to trigger the alert
          percent = optional(string) // () : Percentage of timeseries that should fail in order to trigger the alert
        }
      })

      condition_matched_log = optional({
        filter           = optional(string) // () : A logs-based filter.
        label_extractors = optional(map())  // ()
      })
    }]
  },
]
```

## Outputs

| Name      | Description          |
| --------- | -------------------- |
| alert_ids | The id of the alerts |
