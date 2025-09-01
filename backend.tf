terraform {
  backend "azurerm" {
    resource_group_name  = "<REPLACE_WITH_RESOURCE_GROUP_NAME>"
    storage_account_name = "<REPLACE_WITH_STORAGE_ACCOUNT_NAME>"
    container_name       = "<REPLACE_WITH_CONTAINER_NAME>"
    key                  = "<REPLACE_WITH_STATE_FILE_NAME>"
  }
}
