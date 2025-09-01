variable "name" {
  description = "The name of the log search alert rule"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region for the resource"
  type        = string
}

variable "evaluation_frequency" {
  description = "How often the alert is evaluated (e.g., PT5M)"
  type        = string
}

variable "window_duration" {
  description = "The time window for evaluation (e.g., PT5M)"
  type        = string
}

variable "scopes" {
  description = "List of resource IDs to scope the alert"
  type        = list(string)
}

variable "severity" {
  description = "Severity of the alert (1-4)"
  type        = number
}

variable "query" {
  description = "Kusto query for the alert rule"
  type        = string
}

variable "time_aggregation_method" {
  description = "Aggregation method (e.g., Total, Average)"
  type        = string
}

variable "threshold" {
  description = "Threshold value to trigger the alert"
  type        = number
}

variable "operator" {
  description = "Comparison operator (e.g., GreaterThan)"
  type        = string
}

variable "resource_id_column" {
  description = "Column name for resource ID in query"
  type        = string
}

variable "metric_measure_column" {
  description = "Column name for metric measurement in query"
  type        = string
}

variable "dimension_name" {
  description = "Name of the dimension for filtering"
  type        = string
}

variable "dimension_operator" {
  description = "Operator for dimension filtering"
  type        = string
}

variable "dimension_values" {
  description = "List of values for the dimension filter"
  type        = list(string)
}

variable "minimum_failing_periods_to_trigger_alert" {
  description = "Minimum periods to trigger alert"
  type        = number
}

variable "number_of_evaluation_periods" {
  description = "Number of periods for evaluation"
  type        = number
}

variable "auto_mitigation_enabled" {
  description = "Enable automatic mitigation"
  type        = bool
}

variable "workspace_alerts_storage_enabled" {
  description = "Enable workspace alerts storage"
  type        = bool
}

variable "description" {
  description = "Description of the alert rule"
  type        = string
}

variable "display_name" {
  description = "Display name for the alert rule"
  type        = string
}

variable "enabled" {
  description = "Whether the alert rule is enabled"
  type        = bool
}

variable "query_time_range_override" {
  description = "Override for query time range"
  type        = string
}

variable "skip_query_validation" {
  description = "Skip query validation"
  type        = bool
}

variable "action_groups" {
  description = "List of action group IDs"
  type        = list(string)
}

variable "custom_properties" {
  description = "Custom properties for the alert rule"
  type        = map(string)
}

variable "identity_type" {
  description = "Type of managed identity"
  type        = string
}

variable "identity_ids" {
  description = "List of managed identity IDs"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to the resource"
  type        = map(string)
}

