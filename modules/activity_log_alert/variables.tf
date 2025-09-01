variable "name" {
  description = "The name of the activity log alert"
  type        = string
}

variable "resource_group_name" {
  description = "The resource group name"
  type        = string
}

variable "location" {
  description = "The location/region"
  type        = string
}

variable "scopes" {
  description = "The scopes where the alert rule applies"
  type        = list(string)
}

variable "description" {
  description = "The description of the alert"
  type        = string
  default     = null
}

variable "enabled" {
  description = "Whether the alert is enabled"
  type        = bool
  default     = true
}

variable "criteria_category" {
  description = "The category of the activity log"
  type        = string
}

variable "criteria_operation_name" {
  description = "The operation name"
  type        = string
}

variable "criteria_resource_type" {
  description = "The resource type"
  type        = string
  default     = null
}

variable "criteria_resource_id" {
  description = "The resource ID"
  type        = string
  default     = null
}

variable "action_groups" {
  description = "List of action group IDs"
  type        = list(string)
  default     = []
}

variable "webhook_properties" {
  description = "Webhook properties"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to the resource"
  type        = map(string)
  default     = {}
}
