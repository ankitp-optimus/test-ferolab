resource "azurerm_monitor_action_group" "default" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  short_name          = var.short_name

  email_receiver {
    name          = var.email_receiver_name
    email_address = var.alert_email
  }
}