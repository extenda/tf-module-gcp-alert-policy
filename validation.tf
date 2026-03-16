locals {
  policy_allowed_keys = toset([
    "display_name",
    "enabled",
    "combiner",
    "user_labels",
    "notification_channels",
    "severity",
    "alert_strategy",
    "documentation",
    "conditions",
  ])

  alert_strategy_allowed_keys = toset([
    "auto_close",
    "notification_rate_limit",
  ])

  notification_rate_limit_allowed_keys = toset([
    "period",
  ])

  documentation_allowed_keys = toset([
    "content",
    "mime_type",
    "subject",
  ])

  condition_allowed_keys = toset([
    "display_name",
    "condition_threshold",
    "condition_monitoring_query_language",
    "condition_prometheus_query_language",
    "condition_matched_log",
    "condition_absent",
  ])

  condition_type_keys = [
    "condition_threshold",
    "condition_monitoring_query_language",
    "condition_prometheus_query_language",
    "condition_matched_log",
    "condition_absent",
  ]

  condition_threshold_allowed_keys = toset([
    "comparison",
    "filter",
    "threshold_value",
    "duration",
    "denominator_filter",
    "evaluation_missing_data",
    "aggregations",
    "denominator_aggregations",
    "trigger",
    "forecast_options",
  ])

  aggregation_allowed_keys = toset([
    "alignment_period",
    "per_series_aligner",
    "cross_series_reducer",
    "group_by_fields",
  ])

  trigger_allowed_keys = toset([
    "count",
    "percent",
  ])

  forecast_options_allowed_keys = toset([
    "forecast_horizon",
  ])

  condition_mql_allowed_keys = toset([
    "query",
    "duration",
    "evaluation_missing_data",
    "trigger",
  ])

  condition_pql_allowed_keys = toset([
    "query",
    "duration",
    "evaluation_interval",
    "labels",
    "rule_group",
    "alert_rule",
  ])

  condition_matched_log_allowed_keys = toset([
    "filter",
    "label_extractors",
  ])

  condition_absent_allowed_keys = toset([
    "duration",
    "filter",
    "aggregations",
    "trigger",
  ])
}

locals {
  policies = try([
    for policy in var.policies :
    jsondecode(jsonencode(policy))
  ], [])

  policies_list_error = can(var.policies[*]) ? [] : [
    "policies must be a list of objects"
  ]

  policy_object_errors = [
    for i, policy in local.policies :
    "policies[${i}] must be an object"
    if !can(keys(policy))
  ]

  policy_key_errors = flatten([
    for i, policy in local.policies : (
      can(keys(policy)) ? [
        for key in setsubtract(toset(keys(policy)), local.policy_allowed_keys) :
        "policies[${i}] has unknown key '${key}'"
      ] : []
    )
  ])

  policy_required_errors = flatten([
    for i, policy in local.policies : (
      can(keys(policy)) ? concat(
        contains(keys(policy), "display_name") ? [] : ["policies[${i}] missing required key 'display_name'"],
        contains(keys(policy), "conditions") ? [] : ["policies[${i}] missing required key 'conditions'"]
      ) : []
    )
  ])

  policy_conditions_shape_errors = flatten([
    for i, policy in local.policies : (
      can(keys(policy)) && contains(keys(policy), "conditions") ? (
        try(policy.conditions, null) == null ? ["policies[${i}].conditions must be a list of objects"] :
        (can(policy.conditions[0]) || try(length(policy.conditions), 0) == 0) ? [] :
        ["policies[${i}].conditions must be a list of objects"]
      ) : []
    )
  ])

  policy_conditions_empty_errors = [
    for i, policy in local.policies :
    "policies[${i}].conditions must contain at least one item"
    if can(keys(policy)) && contains(keys(policy), "conditions") && try(length(policy.conditions), 0) == 0
  ]

  condition_object_errors = flatten([
    for i, policy in local.policies : (
      can(keys(policy)) && contains(keys(policy), "conditions") && (can(policy.conditions[0]) || try(length(policy.conditions), 0) == 0) ? [
        for j, condition in policy.conditions :
        "policies[${i}].conditions[${j}] must be an object"
        if !can(keys(condition))
      ] : []
    )
  ])

  condition_key_errors = flatten([
    for i, policy in local.policies : (
      can(keys(policy)) && contains(keys(policy), "conditions") && (can(policy.conditions[0]) || try(length(policy.conditions), 0) == 0) ? flatten([
        for j, condition in policy.conditions : (
          can(keys(condition)) ? [
            for key in setsubtract(toset(keys(condition)), local.condition_allowed_keys) :
            "policies[${i}].conditions[${j}] has unknown key '${key}'"
          ] : []
        )
      ]) : []
    )
  ])

  condition_required_errors = flatten([
    for i, policy in local.policies : (
      can(keys(policy)) && contains(keys(policy), "conditions") && (can(policy.conditions[0]) || try(length(policy.conditions), 0) == 0) ? flatten([
        for j, condition in policy.conditions : (
          can(keys(condition)) ? (
            contains(keys(condition), "display_name") ? [] : ["policies[${i}].conditions[${j}] missing required key 'display_name'"]
          ) : []
        )
      ]) : []
    )
  ])

  condition_type_errors = flatten([
    for i, policy in local.policies : (
      can(keys(policy)) && contains(keys(policy), "conditions") && (can(policy.conditions[0]) || try(length(policy.conditions), 0) == 0) ? flatten([
        for j, condition in policy.conditions : (
          can(keys(condition)) ? (
            length([
              for key in local.condition_type_keys : key
              if try(condition[key], null) != null
            ]) == 1 ? [] :
            ["policies[${i}].conditions[${j}] must set exactly one of ${join(", ", local.condition_type_keys)}"]
          ) : []
        )
      ]) : []
    )
  ])

  alert_strategy_errors = flatten([
    for i, policy in local.policies : (
      try(policy.alert_strategy, null) == null ? [] :
      can(keys(policy.alert_strategy)) ? [
        for key in setsubtract(toset(keys(policy.alert_strategy)), local.alert_strategy_allowed_keys) :
        "policies[${i}].alert_strategy has unknown key '${key}'"
      ] : ["policies[${i}].alert_strategy must be an object"]
    )
  ])

  notification_rate_limit_errors = flatten([
    for i, policy in local.policies : (
      try(policy.alert_strategy.notification_rate_limit, null) == null ? [] :
      can(keys(policy.alert_strategy.notification_rate_limit)) ? [
        for key in setsubtract(toset(keys(policy.alert_strategy.notification_rate_limit)), local.notification_rate_limit_allowed_keys) :
        "policies[${i}].alert_strategy.notification_rate_limit has unknown key '${key}'"
      ] : ["policies[${i}].alert_strategy.notification_rate_limit must be an object"]
    )
  ])

  documentation_errors = flatten([
    for i, policy in local.policies : (
      try(policy.documentation, null) == null ? [] :
      can(keys(policy.documentation)) ? [
        for key in setsubtract(toset(keys(policy.documentation)), local.documentation_allowed_keys) :
        "policies[${i}].documentation has unknown key '${key}'"
      ] : ["policies[${i}].documentation must be an object"]
    )
  ])

  condition_threshold_errors = flatten([
    for i, policy in local.policies : (
      can(keys(policy)) && contains(keys(policy), "conditions") && (can(policy.conditions[0]) || try(length(policy.conditions), 0) == 0) ? flatten([
        for j, condition in policy.conditions : (
          try(condition.condition_threshold, null) == null ? [] :
          can(keys(condition.condition_threshold)) ? [
            for key in setsubtract(toset(keys(condition.condition_threshold)), local.condition_threshold_allowed_keys) :
            "policies[${i}].conditions[${j}].condition_threshold has unknown key '${key}'"
          ] : ["policies[${i}].conditions[${j}].condition_threshold must be an object"]
        )
      ]) : []
    )
  ])

  condition_threshold_aggregation_errors = flatten([
    for i, policy in local.policies : (
      can(keys(policy)) && contains(keys(policy), "conditions") && (can(policy.conditions[0]) || try(length(policy.conditions), 0) == 0) ? flatten([
        for j, condition in policy.conditions : (
          try(condition.condition_threshold.aggregations, null) == null ? [] :
          (can(condition.condition_threshold.aggregations[0]) || try(length(condition.condition_threshold.aggregations), 0) == 0) ? flatten([
            for k, aggregation in condition.condition_threshold.aggregations : (
              can(keys(aggregation)) ? [
                for key in setsubtract(toset(keys(aggregation)), local.aggregation_allowed_keys) :
                "policies[${i}].conditions[${j}].condition_threshold.aggregations[${k}] has unknown key '${key}'"
              ] : ["policies[${i}].conditions[${j}].condition_threshold.aggregations[${k}] must be an object"]
            )
          ]) : ["policies[${i}].conditions[${j}].condition_threshold.aggregations must be a list of objects"]
        )
      ]) : []
    )
  ])

  condition_threshold_denominator_aggregation_errors = flatten([
    for i, policy in local.policies : (
      can(keys(policy)) && contains(keys(policy), "conditions") && (can(policy.conditions[0]) || try(length(policy.conditions), 0) == 0) ? flatten([
        for j, condition in policy.conditions : (
          try(condition.condition_threshold.denominator_aggregations, null) == null ? [] :
          (can(condition.condition_threshold.denominator_aggregations[0]) || try(length(condition.condition_threshold.denominator_aggregations), 0) == 0) ? flatten([
            for k, aggregation in condition.condition_threshold.denominator_aggregations : (
              can(keys(aggregation)) ? [
                for key in setsubtract(toset(keys(aggregation)), local.aggregation_allowed_keys) :
                "policies[${i}].conditions[${j}].condition_threshold.denominator_aggregations[${k}] has unknown key '${key}'"
              ] : ["policies[${i}].conditions[${j}].condition_threshold.denominator_aggregations[${k}] must be an object"]
            )
          ]) : ["policies[${i}].conditions[${j}].condition_threshold.denominator_aggregations must be a list of objects"]
        )
      ]) : []
    )
  ])

  condition_threshold_trigger_errors = flatten([
    for i, policy in local.policies : (
      can(keys(policy)) && contains(keys(policy), "conditions") && (can(policy.conditions[0]) || try(length(policy.conditions), 0) == 0) ? flatten([
        for j, condition in policy.conditions : (
          try(condition.condition_threshold.trigger, null) == null ? [] :
          can(keys(condition.condition_threshold.trigger)) ? [
            for key in setsubtract(toset(keys(condition.condition_threshold.trigger)), local.trigger_allowed_keys) :
            "policies[${i}].conditions[${j}].condition_threshold.trigger has unknown key '${key}'"
          ] : ["policies[${i}].conditions[${j}].condition_threshold.trigger must be an object"]
        )
      ]) : []
    )
  ])

  condition_threshold_forecast_errors = flatten([
    for i, policy in local.policies : (
      can(keys(policy)) && contains(keys(policy), "conditions") && (can(policy.conditions[0]) || try(length(policy.conditions), 0) == 0) ? flatten([
        for j, condition in policy.conditions : (
          try(condition.condition_threshold.forecast_options, null) == null ? [] :
          can(keys(condition.condition_threshold.forecast_options)) ? [
            for key in setsubtract(toset(keys(condition.condition_threshold.forecast_options)), local.forecast_options_allowed_keys) :
            "policies[${i}].conditions[${j}].condition_threshold.forecast_options has unknown key '${key}'"
          ] : ["policies[${i}].conditions[${j}].condition_threshold.forecast_options must be an object"]
        )
      ]) : []
    )
  ])

  condition_mql_errors = flatten([
    for i, policy in local.policies : (
      can(keys(policy)) && contains(keys(policy), "conditions") && (can(policy.conditions[0]) || try(length(policy.conditions), 0) == 0) ? flatten([
        for j, condition in policy.conditions : (
          try(condition.condition_monitoring_query_language, null) == null ? [] :
          can(keys(condition.condition_monitoring_query_language)) ? [
            for key in setsubtract(toset(keys(condition.condition_monitoring_query_language)), local.condition_mql_allowed_keys) :
            "policies[${i}].conditions[${j}].condition_monitoring_query_language has unknown key '${key}'"
          ] : ["policies[${i}].conditions[${j}].condition_monitoring_query_language must be an object"]
        )
      ]) : []
    )
  ])

  condition_mql_trigger_errors = flatten([
    for i, policy in local.policies : (
      can(keys(policy)) && contains(keys(policy), "conditions") && (can(policy.conditions[0]) || try(length(policy.conditions), 0) == 0) ? flatten([
        for j, condition in policy.conditions : (
          try(condition.condition_monitoring_query_language.trigger, null) == null ? [] :
          can(keys(condition.condition_monitoring_query_language.trigger)) ? [
            for key in setsubtract(toset(keys(condition.condition_monitoring_query_language.trigger)), local.trigger_allowed_keys) :
            "policies[${i}].conditions[${j}].condition_monitoring_query_language.trigger has unknown key '${key}'"
          ] : ["policies[${i}].conditions[${j}].condition_monitoring_query_language.trigger must be an object"]
        )
      ]) : []
    )
  ])

  condition_pql_errors = flatten([
    for i, policy in local.policies : (
      can(keys(policy)) && contains(keys(policy), "conditions") && (can(policy.conditions[0]) || try(length(policy.conditions), 0) == 0) ? flatten([
        for j, condition in policy.conditions : (
          try(condition.condition_prometheus_query_language, null) == null ? [] :
          can(keys(condition.condition_prometheus_query_language)) ? [
            for key in setsubtract(toset(keys(condition.condition_prometheus_query_language)), local.condition_pql_allowed_keys) :
            "policies[${i}].conditions[${j}].condition_prometheus_query_language has unknown key '${key}'"
          ] : ["policies[${i}].conditions[${j}].condition_prometheus_query_language must be an object"]
        )
      ]) : []
    )
  ])

  condition_matched_log_errors = flatten([
    for i, policy in local.policies : (
      can(keys(policy)) && contains(keys(policy), "conditions") && (can(policy.conditions[0]) || try(length(policy.conditions), 0) == 0) ? flatten([
        for j, condition in policy.conditions : (
          try(condition.condition_matched_log, null) == null ? [] :
          can(keys(condition.condition_matched_log)) ? [
            for key in setsubtract(toset(keys(condition.condition_matched_log)), local.condition_matched_log_allowed_keys) :
            "policies[${i}].conditions[${j}].condition_matched_log has unknown key '${key}'"
          ] : ["policies[${i}].conditions[${j}].condition_matched_log must be an object"]
        )
      ]) : []
    )
  ])

  condition_absent_errors = flatten([
    for i, policy in local.policies : (
      can(keys(policy)) && contains(keys(policy), "conditions") && (can(policy.conditions[0]) || try(length(policy.conditions), 0) == 0) ? flatten([
        for j, condition in policy.conditions : (
          try(condition.condition_absent, null) == null ? [] :
          can(keys(condition.condition_absent)) ? [
            for key in setsubtract(toset(keys(condition.condition_absent)), local.condition_absent_allowed_keys) :
            "policies[${i}].conditions[${j}].condition_absent has unknown key '${key}'"
          ] : ["policies[${i}].conditions[${j}].condition_absent must be an object"]
        )
      ]) : []
    )
  ])

  condition_absent_trigger_errors = flatten([
    for i, policy in local.policies : (
      can(keys(policy)) && contains(keys(policy), "conditions") && (can(policy.conditions[0]) || try(length(policy.conditions), 0) == 0) ? flatten([
        for j, condition in policy.conditions : (
          try(condition.condition_absent.trigger, null) == null ? [] :
          can(keys(condition.condition_absent.trigger)) ? [
            for key in setsubtract(toset(keys(condition.condition_absent.trigger)), local.trigger_allowed_keys) :
            "policies[${i}].conditions[${j}].condition_absent.trigger has unknown key '${key}'"
          ] : ["policies[${i}].conditions[${j}].condition_absent.trigger must be an object"]
        )
      ]) : []
    )
  ])

  condition_absent_aggregation_errors = flatten([
    for i, policy in local.policies : (
      can(keys(policy)) && contains(keys(policy), "conditions") && (can(policy.conditions[0]) || try(length(policy.conditions), 0) == 0) ? flatten([
        for j, condition in policy.conditions : (
          try(condition.condition_absent.aggregations, null) == null ? [] :
          (can(condition.condition_absent.aggregations[0]) || try(length(condition.condition_absent.aggregations), 0) == 0) ? flatten([
            for k, aggregation in condition.condition_absent.aggregations : (
              can(keys(aggregation)) ? [
                for key in setsubtract(toset(keys(aggregation)), local.aggregation_allowed_keys) :
                "policies[${i}].conditions[${j}].condition_absent.aggregations[${k}] has unknown key '${key}'"
              ] : ["policies[${i}].conditions[${j}].condition_absent.aggregations[${k}] must be an object"]
            )
          ]) : ["policies[${i}].conditions[${j}].condition_absent.aggregations must be a list of objects"]
        )
      ]) : []
    )
  ])

  policy_schema_errors = concat(
    local.policies_list_error,
    local.policy_object_errors,
    local.policy_key_errors,
    local.policy_required_errors,
    local.policy_conditions_shape_errors,
    local.policy_conditions_empty_errors,
    local.condition_object_errors,
    local.condition_key_errors,
    local.condition_required_errors,
    local.condition_type_errors,
    local.alert_strategy_errors,
    local.notification_rate_limit_errors,
    local.documentation_errors,
    local.condition_threshold_errors,
    local.condition_threshold_aggregation_errors,
    local.condition_threshold_denominator_aggregation_errors,
    local.condition_threshold_trigger_errors,
    local.condition_threshold_forecast_errors,
    local.condition_mql_errors,
    local.condition_mql_trigger_errors,
    local.condition_pql_errors,
    local.condition_matched_log_errors,
    local.condition_absent_errors,
    local.condition_absent_trigger_errors,
    local.condition_absent_aggregation_errors
  )
}

locals {
  alert_keys = [for i, policy in local.policies : try(policy.display_name, "invalid-${i}")]

  policy_errors_by_key = {
    for i, key in local.alert_keys : key => [
      for err in local.policy_schema_errors : err
      if startswith(err, "policies[${i}]") || err == "policies must be a list of objects"
    ]
  }
}
