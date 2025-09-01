resource "azurerm_monitor_activity_log_alert" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  scopes              = var.scopes
  description         = var.description
  enabled             = var.enabled

  criteria {
    category       = var.criteria_category
    operation_name = var.criteria_operation_name
    resource_type  = var.criteria_resource_type
    resource_id    = var.criteria_resource_id
  }

  dynamic "action" {
    for_each = var.action_groups
    content {
      action_group_id = action.value
      webhook_properties = var.webhook_properties
    }
  }

  tags = var.tags
}
