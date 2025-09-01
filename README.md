# Azure Alert Management - FeroLab

This Terraform project provides infrastructure as code for managing Azure alerting and monitoring resources. It includes modules for creating action groups, activity log alerts, and log search alert rules to ensure comprehensive monitoring of Azure resources.

## 🏗️ Project Structure

```
test-ferolab/
├── action-group.tf              # Action group configuration
├── activity_log_alert.tf        # Activity log alert rules
├── backend.tf                   # Terraform backend configuration
├── log_sarch_alert_rule.tf      # Log search alert rules
├── providers.tf                 # Azure provider configuration
├── variables.tf                 # Input variables
├── README.md                    # This file
└── modules/
    ├── action-group/            # Action group module
    │   ├── main.tf
    │   ├── output.tf
    │   └── variables.tf
    ├── activity_log_alert/      # Activity log alert module
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    └── log_search_alert_rule/   # Log search alert rule module
        ├── main.tf
        ├── output.tf
        └── variables.tf
```

## 📋 Features

### Action Groups
- **Email Notifications**: Configured to send alerts to `ferolabs@optimusinfo.atlassian.net`
- **Global Scope**: Action group with global location for worldwide coverage
- **Customizable**: Easily configure additional notification channels

### Activity Log Alerts
- **DDoS Attack Detection**: Monitors for DDoS attacks on public IP addresses
- **Virtual Network Deletion**: Alerts when virtual networks are deleted
- **Resource Management**: Comprehensive monitoring of Azure resource changes
- **Administrative Actions**: Tracks administrative operations across subscriptions

### Log Search Alert Rules
- **Custom Queries**: Support for KQL-based alert rules
- **Flexible Thresholds**: Configurable alert thresholds and evaluation frequency
- **Multi-subscription Support**: Can monitor across multiple Azure subscriptions

## 🚀 Prerequisites

- **Terraform**: Version >= 1.1.0
- **Azure CLI**: Authenticated with appropriate permissions
- **Azure Subscription**: Access to target Azure subscription(s)
- **Service Principal**: App registration with necessary permissions

## ⚙️ Configuration

### 1. Service Principal Setup

Update the `providers.tf` file with your Azure service principal details:

```hcl
provider "azurerm" {
  features {}
  client_id       = "<your-app-registration-client-id>"
  client_secret   = "<your-app-registration-client-secret>"
  tenant_id       = "<your-azure-tenant-id>"
  subscription_id = var.subscription_id
}
```

### 2. Variables Configuration

Create a `terraform.tfvars` file:

```hcl
subscription_id     = "your-subscription-id"
prd_subscription_id = "your-production-subscription-id"
```

### 3. Backend Configuration

Configure your Terraform backend in `backend.tf` for state management.

## 🔧 Usage

### Initialize Terraform
```bash
terraform init
```

### Plan Deployment
```bash
terraform plan
```

### Apply Configuration
```bash
terraform apply
```

### Destroy Resources
```bash
terraform destroy
```

## 📊 Monitoring Coverage

### Current Alert Rules

1. **DDoS Attack Detection**
   - **Scope**: All public IP addresses in subscription
   - **Trigger**: DDoS protection status changes
   - **Category**: Administrative

2. **Virtual Network Deletion**
   - **Scope**: All virtual networks in subscription
   - **Trigger**: Virtual network deletion operations
   - **Category**: Administrative

### Action Group Configuration

- **Name**: `fero-ag-optimus-global-prd-01`
- **Short Name**: `OptAG`
- **Location**: Global
- **Email Receiver**: `ferolabs@optimusinfo.atlassian.net`

## 🔐 Security Considerations

- Service principal credentials should be stored securely
- Use Azure Key Vault for sensitive configuration data
- Implement least-privilege access for the service principal
- Regularly rotate service principal secrets

## 🏷️ Modules

### Action Group Module
- **Location**: `./modules/action-group`
- **Purpose**: Creates and manages Azure Monitor Action Groups
- **Outputs**: Action group ID for use in alert rules

### Activity Log Alert Module
- **Location**: `./modules/activity_log_alert`
- **Purpose**: Creates activity log-based alert rules
- **Features**: Supports multiple criteria and action groups

### Log Search Alert Rule Module
- **Location**: `./modules/log_search_alert_rule`
- **Purpose**: Creates KQL-based alert rules for log analytics
- **Features**: Flexible query-based alerting

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-alert`)
3. Commit your changes (`git commit -am 'Add new alert rule'`)
4. Push to the branch (`git push origin feature/new-alert`)
5. Create a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For support and questions, please contact the FeroLabs team at `ferolabs@optimusinfo.atlassian.net`.

## 🔄 Version History

- **v1.0.0**: Initial release with basic alert monitoring
- Current version includes DDoS and VNet deletion monitoring

---

**Maintained by**: Optimus Information Inc - FeroLabs Team  
**Last Updated**: September 2025