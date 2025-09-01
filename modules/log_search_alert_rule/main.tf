resource "azurerm_monitor_scheduled_query_rules_alert_v2" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  evaluation_frequency = var.evaluation_frequency
  window_duration      = var.window_duration
  scopes               = var.scopes
  severity             = var.severity

  criteria {
    query                   = var.query
    time_aggregation_method = var.time_aggregation_method
    threshold               = var.threshold
    operator                = var.operator
    resource_id_column      = var.resource_id_column
    metric_measure_column   = var.metric_measure_column
    dynamic "dimension" {
      for_each = var.dimension_name != null ? [1] : []
      content {
        name     = var.dimension_name
        operator = var.dimension_operator
        values   = var.dimension_values
      }
    }
    failing_periods {
      minimum_failing_periods_to_trigger_alert = var.minimum_failing_periods_to_trigger_alert
      number_of_evaluation_periods             = var.number_of_evaluation_periods
    }
  }

  auto_mitigation_enabled          = var.auto_mitigation_enabled
  workspace_alerts_storage_enabled = var.workspace_alerts_storage_enabled
  description                      = var.description
  display_name                     = var.display_name
  enabled                          = var.enabled
  query_time_range_override        = var.query_time_range_override
  skip_query_validation            = var.skip_query_validation

  action {
    action_groups    = var.action_groups
    custom_properties = var.custom_properties
  }

  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  tags = var.tags

}
