locals {
  activity_log_alert_ddos_attack_detected = {
    name                      = "DDoS Attack Detected"
    resource_group_name       = module.rg_prd_alertsccn.name
    location                  = "global"
    scopes                    = ["/subscriptions/${var.subscription_id}"]
    description               = "Alert when DDoS attack is detected on public IP addresses"
    enabled                   = true
    criteria_category         = "Administrative"
    criteria_operation_name   = "Microsoft.Network/publicIPAddresses/ddosProtectionStatus/action"
    criteria_resource_type    = "microsoft.network/publicipaddresses"
    criteria_resource_id      = null
    action_groups             = [module.action_group.id]
    webhook_properties        = {}
    tags                      = {}
  }

  activity_log_alert_deleted_virtual_network = {
    name                      = "Deleted Virtual Network Alert"
    resource_group_name       = module.rg_prd_alertsccn.name
    location                  = "global"
    scopes                    = ["/subscriptions/${var.subscription_id}"]
    description               = "Alert when a virtual network is deleted"
    enabled                   = true
    criteria_category         = "Administrative"
    criteria_operation_name   = "Microsoft.Network/virtualNetworks/delete"
    criteria_resource_type    = null
    criteria_resource_id      = null
    action_groups             = [module.action_group.id]
    webhook_properties        = {}
    tags                      = {}
  }

  activity_log_alert_networking_services_health_status = {
    name                      = "Networking Services Health Status Alert"
    resource_group_name       = module.rg_prd_alertsccn.name
    location                  = "global"
    scopes                    = ["/subscriptions/${var.subscription_id}"]
    description               = "Alert for networking services health incidents"
    enabled                   = true
    criteria_category         = "ServiceHealth"
    criteria_operation_name   = null
    criteria_resource_type    = null
    criteria_resource_id      = null
    action_groups             = [module.action_group.id]
    webhook_properties        = {}
    tags                      = {}
  }
  activity_log_alert_vpn_gateway_tunnel_down = {
    name                      = "VPN Gateway Tunnel Down"
    resource_group_name       = module.rg_prd_alertsccn.name
    location                  = "global"
    scopes                    = ["/subscriptions/${var.subscription_id}"]
    description               = "Alert when a VPN Gateway tunnel goes down"
    enabled                   = true
    criteria_category         = "Administrative"
    criteria_operation_name   = "microsoft.network/virtualnetworkgateways/disconnectvirtualnetworkgatewayvpnconnections/action"
    criteria_resource_type    = "microsoft.network/virtualnetworkgateways"
    criteria_resource_id      = null
    action_groups             = [module.action_group.id]
    webhook_properties        = {}
    tags                      = {}
  }
}


module "activity_log_alert_ddos_attack_detected" {
  source                    = "./modules/activity_log_alert"
  name                      = local.activity_log_alert_ddos_attack_detected.name
  resource_group_name       = local.activity_log_alert_ddos_attack_detected.resource_group_name
  location                  = local.activity_log_alert_ddos_attack_detected.location
  scopes                    = local.activity_log_alert_ddos_attack_detected.scopes
  description               = local.activity_log_alert_ddos_attack_detected.description
  enabled                   = local.activity_log_alert_ddos_attack_detected.enabled
  criteria_category         = local.activity_log_alert_ddos_attack_detected.criteria_category
  criteria_operation_name   = local.activity_log_alert_ddos_attack_detected.criteria_operation_name
  criteria_resource_type    = local.activity_log_alert_ddos_attack_detected.criteria_resource_type
  criteria_resource_id      = local.activity_log_alert_ddos_attack_detected.criteria_resource_id
  action_groups             = local.activity_log_alert_ddos_attack_detected.action_groups
  webhook_properties        = local.activity_log_alert_ddos_attack_detected.webhook_properties
  tags                      = local.activity_log_alert_ddos_attack_detected.tags
}

module "activity_log_alert_deleted_virtual_network" {
  source                    = "./modules/activity_log_alert"
  name                      = local.activity_log_alert_deleted_virtual_network.name
  resource_group_name       = local.activity_log_alert_deleted_virtual_network.resource_group_name
  location                  = local.activity_log_alert_deleted_virtual_network.location
  scopes                    = local.activity_log_alert_deleted_virtual_network.scopes
  description               = local.activity_log_alert_deleted_virtual_network.description
  enabled                   = local.activity_log_alert_deleted_virtual_network.enabled
  criteria_category         = local.activity_log_alert_deleted_virtual_network.criteria_category
  criteria_operation_name   = local.activity_log_alert_deleted_virtual_network.criteria_operation_name
  criteria_resource_type    = local.activity_log_alert_deleted_virtual_network.criteria_resource_type
  criteria_resource_id      = local.activity_log_alert_deleted_virtual_network.criteria_resource_id
  action_groups             = local.activity_log_alert_deleted_virtual_network.action_groups
  webhook_properties        = local.activity_log_alert_deleted_virtual_network.webhook_properties
  tags                      = local.activity_log_alert_deleted_virtual_network.tags
}

module "activity_log_alert_networking_services_health_status" {
  source                    = "./modules/activity_log_alert"
  name                      = local.activity_log_alert_networking_services_health_status.name
  resource_group_name       = local.activity_log_alert_networking_services_health_status.resource_group_name
  location                  = local.activity_log_alert_networking_services_health_status.location
  scopes                    = local.activity_log_alert_networking_services_health_status.scopes
  description               = local.activity_log_alert_networking_services_health_status.description
  enabled                   = local.activity_log_alert_networking_services_health_status.enabled
  criteria_category         = local.activity_log_alert_networking_services_health_status.criteria_category
  criteria_operation_name   = local.activity_log_alert_networking_services_health_status.criteria_operation_name
  criteria_resource_type    = local.activity_log_alert_networking_services_health_status.criteria_resource_type
  criteria_resource_id      = local.activity_log_alert_networking_services_health_status.criteria_resource_id
  action_groups             = local.activity_log_alert_networking_services_health_status.action_groups
  webhook_properties        = local.activity_log_alert_networking_services_health_status.webhook_properties
  tags                      = local.activity_log_alert_networking_services_health_status.tags
}

module "activity_log_alert_vpn_gateway_tunnel_down" {
  source                    = "./modules/activity_log_alert"
  name                      = local.activity_log_alert_vpn_gateway_tunnel_down.name
  resource_group_name       = local.activity_log_alert_vpn_gateway_tunnel_down.resource_group_name
  location                  = local.activity_log_alert_vpn_gateway_tunnel_down.location
  scopes                    = local.activity_log_alert_vpn_gateway_tunnel_down.scopes
  description               = local.activity_log_alert_vpn_gateway_tunnel_down.description
  enabled                   = local.activity_log_alert_vpn_gateway_tunnel_down.enabled
  criteria_category         = local.activity_log_alert_vpn_gateway_tunnel_down.criteria_category
  criteria_operation_name   = local.activity_log_alert_vpn_gateway_tunnel_down.criteria_operation_name
  criteria_resource_type    = local.activity_log_alert_vpn_gateway_tunnel_down.criteria_resource_type
  criteria_resource_id      = local.activity_log_alert_vpn_gateway_tunnel_down.criteria_resource_id
  action_groups             = local.activity_log_alert_vpn_gateway_tunnel_down.action_groups
  webhook_properties        = local.activity_log_alert_vpn_gateway_tunnel_down.webhook_properties
  tags                      = local.activity_log_alert_vpn_gateway_tunnel_down.tags
}
