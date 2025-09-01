locals {
  action_group = {
    name                = "fero-ag-optimus-global-prd-01"
    location            = "Global"
    short_name          = "OptAG"
    alert_email         = "ferolabs@optimusinfo.atlassian.net"
    email_receiver_name = "Optimus Msp"
  }
}

module "action_group" {
  source              = "./modules/action-group"
  name                = local.action_group.name
  resource_group_name = module.rg_prd_alertsccn.name
  location            = local.action_group.location
  short_name          = local.action_group.short_name
  alert_email         = local.action_group.alert_email
  email_receiver_name = local.action_group.email_receiver_name
}
