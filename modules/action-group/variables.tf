variable "name" {
  description = "The name of the Action Group."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "location" {
  description = "The Azure region for the Action Group."
  type        = string
}

variable "short_name" {
  description = "The short name for the Action Group."
  type        = string
}

variable "alert_email" {
  description = "The email address to receive alert notifications."
  type        = string
}

variable "email_receiver_name" {
  description = "The name of the email receiver in the Action Group."
  type        = string
  default     = "defaultEmail"
}