output "id" {
  description = "The ID of the activity log alert"
  value       = azurerm_monitor_activity_log_alert.this.id
}

output "name" {
  description = "The name of the activity log alert"
  value       = azurerm_monitor_activity_log_alert.this.name
}
