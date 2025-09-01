locals {
  log_search_alert_rule_active_connections = {
    name                                    = "Active Connections SKU limits for 30 mins"
    resource_group_name                     = module.rg_prd_alertsccn.name
    location                                = "eastus2"
    evaluation_frequency                    = "PT5M"
    window_duration                         = "PT5M"
    scopes                                  = ["/subscriptions/${var.prd_subscription_id}"]
    severity                                = 2
    query                                   = <<-QUERY
      InsightsMetrics
      | where Namespace == "Microsoft.DBforPostgreSQL/flexibleServers" and Name == "active_connections"
      | where Val > 800
      | summarize CountAbove80 = count() by bin(TimeGenerated, 5m)
      | where CountAbove80 >= 6
    QUERY
    time_aggregation_method                 = "Count"
    threshold                               = 0
    operator                                = "GreaterThan"
    resource_id_column                      = null
    metric_measure_column                   = null
    dimension_name                          = null
    dimension_operator                      = null
    dimension_values                        = []
    minimum_failing_periods_to_trigger_alert = 1
    number_of_evaluation_periods            = 1
    auto_mitigation_enabled                 = false
    workspace_alerts_storage_enabled        = false
    description                             = "Azure Database for PostgreSQL flexible server - Active Connections >80% of SKU limits for 30 mins"
    display_name                            = "Active Connections SKU limits for 30 mins"
    enabled                                 = true
    query_time_range_override               = null
    skip_query_validation                   = false
    action_groups                           = [module.action_group.id]
    custom_properties                       = {}
    identity_type                           = null
    identity_ids                            = []
    tags                                    = {}
  }

  log_search_alert_rule_certificate_expiry = {
    name                                    = "Certificate Expiry"
    resource_group_name                     = module.rg_prd_alertsccn.name
    location                                = "eastus2"
    evaluation_frequency                    = "PT5M"
    window_duration                         = "PT5M"
    scopes                                  = ["/subscriptions/${var.prd_subscription_id}"]
    severity                                = 2
    query                                   = <<-QUERY
      KubeEvents
      | where TimeGenerated > ago(10m)
      | where Reason has "Failed" or Message has "x509" or Message has "certificate" or Message has "expired"
      | project TimeGenerated, Reason, Message, Namespace, ClusterName, ObjectKind
    QUERY
    time_aggregation_method                 = "Count"
    threshold                               = 0
    operator                                = "GreaterThan"
    resource_id_column                      = null
    metric_measure_column                   = null
    dimension_name                          = null
    dimension_operator                      = null
    dimension_values                        = []
    minimum_failing_periods_to_trigger_alert = 1
    number_of_evaluation_periods            = 1
    auto_mitigation_enabled                 = false
    workspace_alerts_storage_enabled        = false
    description                             = null
    display_name                            = "Certificate Expiry"
    enabled                                 = true
    query_time_range_override               = "P2D"
    skip_query_validation                   = false
    action_groups                           = [module.action_group.id]
    custom_properties                       = {}
    identity_type                           = null
    identity_ids                            = []
    tags                                    = {}
  }

  log_search_alert_rule_certificate_expiry_imminent = {
    name                                    = "Certificate Expiry Imminent"
    resource_group_name                     = module.rg_prd_alertsccn.name
    location                                = "eastus2"
    evaluation_frequency                    = "PT5M"
    window_duration                         = "PT5M"
    scopes                                  = ["/subscriptions/${var.prd_subscription_id}"]
    severity                                = 2
    query                                   = <<-QUERY
      AzureDiagnostics
      | where OperationName == "CertificateNearExpiry"
      | extend expiryTime = todatetime(parse_json(AdditionalFields).expiryTime)
      | where expiryTime < now() + 30d
      | summarize Count = count() by bin(TimeGenerated, 5m)
      | where Count > 0
    QUERY
    time_aggregation_method                 = "Total"
    threshold                               = 0
    operator                                = "GreaterThan"
    resource_id_column                      = null
    metric_measure_column                   = "Count"
    dimension_name                          = null
    dimension_operator                      = null
    dimension_values                        = []
    minimum_failing_periods_to_trigger_alert = 1
    number_of_evaluation_periods            = 1
    auto_mitigation_enabled                 = false
    workspace_alerts_storage_enabled        = false
    description                             = null
    display_name                            = "Certificate Expiry Imminent"
    enabled                                 = true
    query_time_range_override               = null
    skip_query_validation                   = false
    action_groups                           = [module.action_group.id]
    custom_properties                       = {}
    identity_type                           = null
    identity_ids                            = []
    tags                                    = {}
  }

  log_search_alert_rule_cpu_utilization_high_node_pod = {
    name                                    = "CPU Utilization High (Node-Pod)"
    resource_group_name                     = module.rg_prd_alertsccn.name
    location                                = "eastus2"
    evaluation_frequency                    = "PT5M"
    window_duration                         = "PT5M"
    scopes                                  = ["/subscriptions/${var.prd_subscription_id}"]
    severity                                = 2
    query                                   = <<-QUERY
      Perf
      | where ObjectName == "K8SNode" and CounterName == "cpuUsageNanoCores"
      | where TimeGenerated > ago(5m)
      | summarize AvgCPU = avg(CounterValue) by bin(TimeGenerated, 5m), Computer
      | where AvgCPU > 800000000  // 0.8 cores en nanoCores (ajustar según necesidad)
    QUERY
    time_aggregation_method                 = "Count"
    threshold                               = 0
    operator                                = "GreaterThan"
    resource_id_column                      = null
    metric_measure_column                   = null
    dimension_name                          = null
    dimension_operator                      = null
    dimension_values                        = []
    minimum_failing_periods_to_trigger_alert = 1
    number_of_evaluation_periods            = 1
    auto_mitigation_enabled                 = false
    workspace_alerts_storage_enabled        = false
    description                             = null
    display_name                            = "CPU Utilization High (Node-Pod)"
    enabled                                 = true
    query_time_range_override               = "P2D"
    skip_query_validation                   = false
    action_groups                           = [module.action_group.id]
    custom_properties                       = {}
    identity_type                           = null
    identity_ids                            = []
    tags                                    = {}
  }

  log_search_alert_rule_dns_latency = {
    name                                    = "DNS latency"
    resource_group_name                     = module.rg_prd_alertsccn.name
    location                                = "eastus2"
    evaluation_frequency                    = "PT5M"
    window_duration                         = "PT5M"
    scopes                                  = ["/subscriptions/${var.prd_subscription_id}"]
    severity                                = 2
    query                                   = <<-QUERY
      Perf
      | where TimeGenerated > ago(10m)
      | where ObjectName == "KubePod" and CounterName contains "dns"
      | summarize AvgDNSLatency = avg(CounterValue) by bin(TimeGenerated, 5m), InstanceName
      | where AvgDNSLatency > 500
    QUERY
    time_aggregation_method                 = "Count"
    threshold                               = 0
    operator                                = "GreaterThan"
    resource_id_column                      = null
    metric_measure_column                   = null
    dimension_name                          = null
    dimension_operator                      = null
    dimension_values                        = []
    minimum_failing_periods_to_trigger_alert = 1
    number_of_evaluation_periods            = 1
    auto_mitigation_enabled                 = false
    workspace_alerts_storage_enabled        = false
    description                             = null
    display_name                            = "DNS latency"
    enabled                                 = true
    query_time_range_override               = "P2D"
    skip_query_validation                   = false
    action_groups                           = [module.action_group.id]
    custom_properties                       = {}
    identity_type                           = null
    identity_ids                            = []
    tags                                    = {}
  }

  log_search_alert_rule_failed_connection_count = {
    name                                    = "Failed Connection Count"
    resource_group_name                     = module.rg_prd_alertsccn.name
    location                                = "eastus2"
    evaluation_frequency                    = "PT5M"
    window_duration                         = "PT5M"
    scopes                                  = ["/subscriptions/${var.prd_subscription_id}"]
    severity                                = 2
    query                                   = <<-QUERY
      InsightsMetrics
      | where Namespace == "Microsoft.DBforPostgreSQL/flexibleServers" and Name == "connections_failed"
      | summarize FailedConnections = sum(Val) by bin(TimeGenerated, 30m)
      | where FailedConnections > 10
    QUERY
    time_aggregation_method                 = "Count"
    threshold                               = 0
    operator                                = "GreaterThan"
    resource_id_column                      = null
    metric_measure_column                   = null
    dimension_name                          = null
    dimension_operator                      = null
    dimension_values                        = []
    minimum_failing_periods_to_trigger_alert = 1
    number_of_evaluation_periods            = 1
    auto_mitigation_enabled                 = false
    workspace_alerts_storage_enabled        = false
    description                             = "Failed Connection Count >10 errors in 30 mins"
    display_name                            = "Failed Connection Count"
    enabled                                 = true
    query_time_range_override               = null
    skip_query_validation                   = false
    action_groups                           = [module.action_group.id]
    custom_properties                       = {}
    identity_type                           = null
    identity_ids                            = []
    tags                                    = {}
  }

  log_search_alert_rule_flow_utilization = {
    name                                    = "Flow Utilization"
    resource_group_name                     = module.rg_prd_alertsccn.name
    location                                = "eastus2"
    evaluation_frequency                    = "PT5M"
    window_duration                         = "PT5M"
    scopes                                  = ["/subscriptions/${var.prd_subscription_id}"]
    severity                                = 2
    query                                   = <<-QUERY
      AzureMetrics
      | where MetricName == "FlowUtilization"
      | where TimeGrain == "PT1M"
      | where Total > 95
      | project TimeGenerated, ResourceId, Total
    QUERY
    time_aggregation_method                 = "Count"
    threshold                               = 0
    operator                                = "GreaterThan"
    resource_id_column                      = "ResourceId"
    metric_measure_column                   = null
    dimension_name                          = null
    dimension_operator                      = null
    dimension_values                        = []
    minimum_failing_periods_to_trigger_alert = 1
    number_of_evaluation_periods            = 1
    auto_mitigation_enabled                 = false
    workspace_alerts_storage_enabled        = false
    description                             = null
    display_name                            = "Flow Utilization"
    enabled                                 = true
    query_time_range_override               = null
    skip_query_validation                   = false
    action_groups                           = [module.action_group.id]
    custom_properties                       = {}
    identity_type                           = null
    identity_ids                            = []
    tags                                    = {}
  }

  log_search_alert_rule_high_latency_vault_operations = {
    name                                    = "High Latency in Vault Operations"
    resource_group_name                     = module.rg_prd_alertsccn.name
    location                                = "eastus2"
    evaluation_frequency                    = "PT5M"
    window_duration                         = "PT5M"
    scopes                                  = ["/subscriptions/${var.prd_subscription_id}"]
    severity                                = 2
    query                                   = <<-QUERY
      AzureDiagnostics
      | where Category == "AuditEvent"
      | where isnotempty(DurationMs)
      | summarize AvgLatency = avg(todouble(DurationMs)) by bin(TimeGenerated, 5m)
      | where AvgLatency > 500
    QUERY
    time_aggregation_method                 = "Count"
    threshold                               = 0
    operator                                = "GreaterThan"
    resource_id_column                      = null
    metric_measure_column                   = null
    dimension_name                          = null
    dimension_operator                      = null
    dimension_values                        = []
    minimum_failing_periods_to_trigger_alert = 1
    number_of_evaluation_periods            = 1
    auto_mitigation_enabled                 = false
    workspace_alerts_storage_enabled        = false
    description                             = null
    display_name                            = "High Latency in Vault Operations"
    enabled                                 = true
    query_time_range_override               = null
    skip_query_validation                   = false
    action_groups                           = [module.action_group.id]
    custom_properties                       = {}
    identity_type                           = null
    identity_ids                            = []
    tags                                    = {}
  }

  log_search_alert_rule_high_memory_utilization = {
    name                                    = "High Memory Utilization"
    resource_group_name                     = module.rg_prd_alertsccn.name
    location                                = "eastus2"
    evaluation_frequency                    = "PT5M"
    window_duration                         = "PT5M"
    scopes                                  = ["/subscriptions/${var.prd_subscription_id}"]
    severity                                = 2
    query                                   = <<-QUERY
      InsightsMetrics
      | where Namespace == "Microsoft.DBforPostgreSQL/flexibleServers" and Name == "memory_percent"
      | where Val > 90
    QUERY
    time_aggregation_method                 = "Count"
    threshold                               = 0
    operator                                = "GreaterThan"
    resource_id_column                      = "_ResourceId"
    metric_measure_column                   = null
    dimension_name                          = null
    dimension_operator                      = null
    dimension_values                        = []
    minimum_failing_periods_to_trigger_alert = 1
    number_of_evaluation_periods            = 1
    auto_mitigation_enabled                 = false
    workspace_alerts_storage_enabled        = false
    description                             = "PostgreSQL flexible server Percentage Memory Utilization > 90%"
    display_name                            = "High Memory Utilization"
    enabled                                 = true
    query_time_range_override               = null
    skip_query_validation                   = false
    action_groups                           = [module.action_group.id]
    custom_properties                       = {}
    identity_type                           = null
    identity_ids                            = []
    tags                                    = {}
  }

  log_search_alert_rule_high_network_latency = {
    name                                    = "High Network Latency"
    resource_group_name                     = module.rg_prd_alertsccn.name
    location                                = "eastus2"
    evaluation_frequency                    = "PT5M"
    window_duration                         = "PT5M"
    scopes                                  = ["/subscriptions/${var.prd_subscription_id}"]
    severity                                = 2
    query                                   = <<-QUERY
      AzureMetrics
      | where MetricName == "RoundTripTime"
      | where TimeGrain == "PT1M"
      | summarize AvgRTT = avg(Total) by bin(TimeGenerated, 5m), ResourceId
      | where AvgRTT > 500
    QUERY
    time_aggregation_method                 = "Count"
    threshold                               = 0
    operator                                = "GreaterThan"
    resource_id_column                      = "ResourceId"
    metric_measure_column                   = null
    dimension_name                          = null
    dimension_operator                      = null
    dimension_values                        = []
    minimum_failing_periods_to_trigger_alert = 1
    number_of_evaluation_periods            = 1
    auto_mitigation_enabled                 = false
    workspace_alerts_storage_enabled        = false
    description                             = null
    display_name                            = "High Network Latency"
    enabled                                 = true
    query_time_range_override               = null
    skip_query_validation                   = false
    action_groups                           = [module.action_group.id]
    custom_properties                       = {}
    identity_type                           = null
    identity_ids                            = []
    tags                                    = {}
  }

  log_search_alert_rule_high_network_throughput = {
    name                                    = "High Network Throughput"
    resource_group_name                     = module.rg_prd_alertsccn.name
    location                                = "eastus2"
    evaluation_frequency                    = "PT5M"
    window_duration                         = "PT5M"
    scopes                                  = ["/subscriptions/${var.prd_subscription_id}"]
    severity                                = 2
    query                                   = <<-QUERY
      AzureMetrics
      | where MetricName in ("Network In Total", "Network Out Total")
      | where TimeGrain == "PT1M"
      | summarize MaxRate = max(Total) by bin(TimeGenerated, 5m), ResourceId
      | where MaxRate > 124518400
    QUERY
    time_aggregation_method                 = "Count"
    threshold                               = 0
    operator                                = "GreaterThan"
    resource_id_column                      = "ResourceId"
    metric_measure_column                   = null
    dimension_name                          = null
    dimension_operator                      = null
    dimension_values                        = []
    minimum_failing_periods_to_trigger_alert = 1
    number_of_evaluation_periods            = 1
    auto_mitigation_enabled                 = false
    workspace_alerts_storage_enabled        = false
    description                             = null
    display_name                            = "High Network Throughput"
    enabled                                 = true
    query_time_range_override               = null
    skip_query_validation                   = false
    action_groups                           = [module.action_group.id]
    custom_properties                       = {}
    identity_type                           = null
    identity_ids                            = []
    tags                                    = {}
  }

  log_search_alert_rule_high_percentage_cpu_utilization = {
    name                                    = "High Percentage CPU Utilization"
    resource_group_name                     = module.rg_prd_alertsccn.name
    location                                = "eastus2"
    evaluation_frequency                    = "PT5M"
    window_duration                         = "PT5M"
    scopes                                  = ["/subscriptions/${var.prd_subscription_id}"]
    severity                                = 2
    query                                   = <<-QUERY
      InsightsMetrics
      | where Namespace == "Microsoft.DBforPostgreSQL/flexibleServers" and Name == "cpu_percent"
      | where Val > 90
      | summarize CountAbove90 = count() by bin(TimeGenerated, 1m)
      | where CountAbove90 >= 5
    QUERY
    time_aggregation_method                 = "Count"
    threshold                               = 0
    operator                                = "GreaterThan"
    resource_id_column                      = null
    metric_measure_column                   = null
    dimension_name                          = null
    dimension_operator                      = null
    dimension_values                        = []
    minimum_failing_periods_to_trigger_alert = 1
    number_of_evaluation_periods            = 1
    auto_mitigation_enabled                 = false
    workspace_alerts_storage_enabled        = false
    description                             = "Percentage CPU Utilization >90% for more than 5 minutes"
    display_name                            = "High Percentage CPU Utilization"
    enabled                                 = true
    query_time_range_override               = null
    skip_query_validation                   = false
    action_groups                           = [module.action_group.id]
    custom_properties                       = {}
    identity_type                           = null
    identity_ids                            = []
    tags                                    = {}
  }

  log_search_alert_rule_high_storage_utilization = {
    name                                    = "High Storage Utilization"
    resource_group_name                     = module.rg_prd_alertsccn.name
    location                                = "eastus2"
    evaluation_frequency                    = "PT5M"
    window_duration                         = "PT5M"
    scopes                                  = ["/subscriptions/${var.prd_subscription_id}"]
    severity                                = 2
    query                                   = <<-QUERY
      InsightsMetrics
      | where Namespace == "Microsoft.DBforPostgreSQL/flexibleServers" and Name == "storage_percent"
      | where Val > 85
    QUERY
    time_aggregation_method                 = "Count"
    threshold                               = 0
    operator                                = "GreaterThan"
    resource_id_column                      = "_ResourceId"
    metric_measure_column                   = null
    dimension_name                          = null
    dimension_operator                      = null
    dimension_values                        = []
    minimum_failing_periods_to_trigger_alert = 1
    number_of_evaluation_periods            = 1
    auto_mitigation_enabled                 = false
    workspace_alerts_storage_enabled        = false
    description                             = "Azure Database for PostgreSQL flexible server Storage Utilization >85%"
    display_name                            = "High Storage Utilization"
    enabled                                 = true
    query_time_range_override               = null
    skip_query_validation                   = false
    action_groups                           = [module.action_group.id]
    custom_properties                       = {}
    identity_type                           = null
    identity_ids                            = []
    tags                                    = {}
  }

  log_search_alert_rule_iops_consumed_percentage = {
    name                                    = "IOPS Consumed Percentage"
    resource_group_name                     = module.rg_prd_alertsccn.name
    location                                = "eastus2"
    evaluation_frequency                    = "PT5M"
    window_duration                         = "PT5M"
    scopes                                  = ["/subscriptions/${var.prd_subscription_id}"]
    severity                                = 2
    query                                   = <<-QUERY
      InsightsMetrics
      | where Namespace == "Microsoft.DBforPostgreSQL/flexibleServers" and Name == "iops_consumed_percent"
      | where Val > 90
      | summarize CountAbove90 = count() by bin(TimeGenerated, 5m)
      | where CountAbove90 >= 12
    QUERY
    time_aggregation_method                 = "Count"
    threshold                               = 0
    operator                                = "GreaterThan"
    resource_id_column                      = null
    metric_measure_column                   = null
    dimension_name                          = null
    dimension_operator                      = null
    dimension_values                        = []
    minimum_failing_periods_to_trigger_alert = 1
    number_of_evaluation_periods            = 1
    auto_mitigation_enabled                 = false
    workspace_alerts_storage_enabled        = false
    description                             = "Azure Database for PostgreSQL flexible server IOPS Consumed Percentage > 90% for 60 min"
    display_name                            = "IOPS Consumed Percentage"
    enabled                                 = true
    query_time_range_override               = null
    skip_query_validation                   = false
    action_groups                           = [module.action_group.id]
    custom_properties                       = {}
    identity_type                           = null
    identity_ids                            = []
    tags                                    = {}
  }

  log_search_alert_rule_key_expiry_imminent = {
    name                                    = "Key Expiry Imminent"
    resource_group_name                     = module.rg_prd_alertsccn.name
    location                                = "eastus2"
    evaluation_frequency                    = "PT5M"
    window_duration                         = "PT5M"
    scopes                                  = ["/subscriptions/${var.prd_subscription_id}"]
    severity                                = 2
    query                                   = <<-QUERY
      AzureDiagnostics
      | where OperationName == "KeyNearExpiry"
    QUERY
    time_aggregation_method                 = "Count"
    threshold                               = 0
    operator                                = "GreaterThan"
    resource_id_column                      = "_ResourceId"
    metric_measure_column                   = null
    dimension_name                          = null
    dimension_operator                      = null
    dimension_values                        = []
    minimum_failing_periods_to_trigger_alert = 1
    number_of_evaluation_periods            = 1
    auto_mitigation_enabled                 = false
    workspace_alerts_storage_enabled        = false
    description                             = null
    display_name                            = "Key Expiry Imminent"
    enabled                                 = true
    query_time_range_override               = null
    skip_query_validation                   = false
    action_groups                           = [module.action_group.id]
    custom_properties                       = {}
    identity_type                           = null
    identity_ids                            = []
    tags                                    = {}
  }

  log_search_alert_rule_kubelet_down = {
    name                                    = "Kubelet Down"
    resource_group_name                     = module.rg_prd_alertsccn.name
    location                                = "eastus2"
    evaluation_frequency                    = "PT5M"
    window_duration                         = "PT5M"
    scopes                                  = ["/subscriptions/${var.prd_subscription_id}"]
    severity                                = 1
    query                                   = <<-QUERY
      Heartbeat
      | where TimeGenerated > ago(5m)
      | where Category == "InsightsMetrics" and Resource contains "aks"
      | summarize LastSeen = max(TimeGenerated) by Computer
      | where LastSeen < ago(5m)
    QUERY
    time_aggregation_method                 = "Count"
    threshold                               = 0
    operator                                = "GreaterThan"
    resource_id_column                      = null
    metric_measure_column                   = null
    dimension_name                          = null
    dimension_operator                      = null
    dimension_values                        = []
    minimum_failing_periods_to_trigger_alert = 1
    number_of_evaluation_periods            = 1
    auto_mitigation_enabled                 = false
    workspace_alerts_storage_enabled        = false
    description                             = null
    display_name                            = "Kubelet Down"
    enabled                                 = true
    query_time_range_override               = "P2D"
    skip_query_validation                   = false
    action_groups                           = [module.action_group.id]
    custom_properties                       = {}
    identity_type                           = null
    identity_ids                            = []
    tags                                    = {}
  }

  log_search_alert_rule_pod_crashloopbackoff = {
    name                                    = "Pod CrashLoopBackOff"
    resource_group_name                     = module.rg_prd_alertsccn.name
    location                                = "eastus2"
    evaluation_frequency                    = "PT5M"
    window_duration                         = "PT5M"
    scopes                                  = ["/subscriptions/${var.prd_subscription_id}"]
    severity                                = 1
    query                                   = <<-QUERY
      KubePodInventory
      | where TimeGenerated > ago(5m)
      | where ContainerStatus == "Waiting"
      | summarize FailedPodCount = count() by bin(TimeGenerated, 5m)
      | where FailedPodCount > 0
    QUERY
    time_aggregation_method                 = "Count"
    threshold                               = 0
    operator                                = "GreaterThan"
    resource_id_column                      = null
    metric_measure_column                   = null
    dimension_name                          = null
    dimension_operator                      = null
    dimension_values                        = []
    minimum_failing_periods_to_trigger_alert = 1
    number_of_evaluation_periods            = 1
    auto_mitigation_enabled                 = false
    workspace_alerts_storage_enabled        = false
    description                             = null
    display_name                            = "Pod CrashLoopBackOff"
    enabled                                 = true
    query_time_range_override               = "P2D"
    skip_query_validation                   = false
    action_groups                           = [module.action_group.id]
    custom_properties                       = {}
    identity_type                           = null
    identity_ids                            = []
    tags                                    = {}
  }

  log_search_alert_rule_postgresql_db_availability = {
    name                                    = "Postgree DB Availability"
    resource_group_name                     = module.rg_prd_alertsccn.name
    location                                = "eastus2"
    evaluation_frequency                    = "PT5M"
    window_duration                         = "PT5M"
    scopes                                  = ["/subscriptions/${var.prd_subscription_id}"]
    severity                                = 1
    query                                   = <<-QUERY
      InsightsMetrics
      | where Namespace == "Microsoft.DBforPostgreSQL/flexibleServers"
      | where Name == "connections_failed"
      | summarize FailedConnections = sum(Val) by bin(TimeGenerated, 5m)
    QUERY
    time_aggregation_method                 = "Count"
    threshold                               = 0
    operator                                = "GreaterThan"
    resource_id_column                      = null
    metric_measure_column                   = null
    dimension_name                          = null
    dimension_operator                      = null
    dimension_values                        = []
    minimum_failing_periods_to_trigger_alert = 1
    number_of_evaluation_periods            = 1
    auto_mitigation_enabled                 = false
    workspace_alerts_storage_enabled        = false
    description                             = "Postgre SQL DB Availability > 5% failure rate over 5 minutes"
    display_name                            = "Postgree DB Availability"
    enabled                                 = true
    query_time_range_override               = null
    skip_query_validation                   = false
    action_groups                           = [module.action_group.id]
    custom_properties                       = {}
    identity_type                           = null
    identity_ids                            = []
    tags                                    = {}
  }

  log_search_alert_rule_load_balancer_health_probe_failure = {
    name                                    = "Load Balancer Health Probe Failure"
    resource_group_name                     = module.rg_prd_alertsccn.name
    location                                = "eastus2"
    evaluation_frequency                    = "PT5M"
    window_duration                         = "PT5M"
    scopes                                  = ["/subscriptions/${var.prd_subscription_id}"]
    severity                                = 2
    query                                   = <<-QUERY
      AzureDiagnostics
      | where Category == "LoadBalancerProbeHealthStatus"
      | where EventName_s == "HealthProbeStatus"
      | where ProbeResult_s == "Down"
      | summarize Count = count() by ResourceId
    QUERY
    time_aggregation_method                 = "Count"
    threshold                               = 0
    operator                                = "GreaterThan"
    resource_id_column                      = "ResourceId"
    metric_measure_column                   = null
    dimension_name                          = null
    dimension_operator                      = null
    dimension_values                        = []
    minimum_failing_periods_to_trigger_alert = 1
    number_of_evaluation_periods            = 1
    auto_mitigation_enabled                 = false
    workspace_alerts_storage_enabled        = false
    description                             = null
    display_name                            = "Load Balancer Health Probe Failure"
    enabled                                 = true
    query_time_range_override               = null
    skip_query_validation                   = false
    action_groups                           = [module.action_group.id]
    custom_properties                       = {}
    identity_type                           = null
    identity_ids                            = []
    tags                                    = {}
  }

  log_search_alert_rule_node_not_ready = {
    name                                    = "Node Not Ready"
    resource_group_name                     = module.rg_prd_alertsccn.name
    location                                = "eastus2"
    evaluation_frequency                    = "PT5M"
    window_duration                         = "PT5M"
    scopes                                  = ["/subscriptions/${var.prd_subscription_id}"]
    severity                                = 2
    query                                   = <<-QUERY
      KubeNodeInventory
      | where TimeGenerated > ago(5m)
      | where Status != "Ready"
      | summarize NodeNotReadyCount = count() by Computer, Status
      | where NodeNotReadyCount > 0
    QUERY
    time_aggregation_method                 = "Count"
    threshold                               = 0
    operator                                = "GreaterThan"
    resource_id_column                      = null
    metric_measure_column                   = null
    dimension_name                          = null
    dimension_operator                      = null
    dimension_values                        = []
    minimum_failing_periods_to_trigger_alert = 1
    number_of_evaluation_periods            = 1
    auto_mitigation_enabled                 = false
    workspace_alerts_storage_enabled        = false
    description                             = null
    display_name                            = "Node Not Ready"
    enabled                                 = true
    query_time_range_override               = "P2D"
    skip_query_validation                   = false
    action_groups                           = [module.action_group.id]
    custom_properties                       = {}
    identity_type                           = null
    identity_ids                            = []
    tags                                    = {}
  }

  log_search_alert_rule_network_security_group_rule_hit_count = {
    name                                    = "Network Security Group Rule Hit Count"
    resource_group_name                     = module.rg_prd_alertsccn.name
    location                                = "eastus2"
    evaluation_frequency                    = "PT5M"
    window_duration                         = "PT5M"
    scopes                                  = ["/subscriptions/${var.prd_subscription_id}"]
    severity                                = 3
    query                                   = <<-QUERY
      AzureDiagnostics
      | where Category == "NetworkSecurityGroupRuleCounter"
      | where matchedConnections_d > 100
      | summarize HitCount = sum(matchedConnections_d) by ResourceId
    QUERY
    time_aggregation_method                 = "Count"
    threshold                               = 0
    operator                                = "GreaterThan"
    resource_id_column                      = "ResourceId"
    metric_measure_column                   = null
    dimension_name                          = null
    dimension_operator                      = null
    dimension_values                        = []
    minimum_failing_periods_to_trigger_alert = 1
    number_of_evaluation_periods            = 1
    auto_mitigation_enabled                 = false
    workspace_alerts_storage_enabled        = false
    description                             = null
    display_name                            = "Network Security Group Rule Hit Count"
    enabled                                 = true
    query_time_range_override               = null
    skip_query_validation                   = false
    action_groups                           = [module.action_group.id]
    custom_properties                       = {}
    identity_type                           = null
    identity_ids                            = []
    tags                                    = {}
  }

  log_search_alert_rule_secret_expiry_imminent = {
    name                                    = "Secret Expiry Imminent"
    resource_group_name                     = module.rg_prd_alertsccn.name
    location                                = "eastus2"
    evaluation_frequency                    = "PT5M"
    window_duration                         = "PT5M"
    scopes                                  = ["/subscriptions/${var.prd_subscription_id}"]
    severity                                = 2
    query                                   = <<-QUERY
      AzureDiagnostics
      | where OperationName == "SecretNearExpiry"
    QUERY
    time_aggregation_method                 = "Count"
    threshold                               = 0
    operator                                = "GreaterThan"
    resource_id_column                      = "_ResourceId"
    metric_measure_column                   = null
    dimension_name                          = null
    dimension_operator                      = null
    dimension_values                        = []
    minimum_failing_periods_to_trigger_alert = 1
    number_of_evaluation_periods            = 1
    auto_mitigation_enabled                 = false
    workspace_alerts_storage_enabled        = false
    description                             = null
    display_name                            = "Secret Expiry Imminent"
    enabled                                 = true
    query_time_range_override               = null
    skip_query_validation                   = false
    action_groups                           = [module.action_group.id]
    custom_properties                       = {}
    identity_type                           = null
    identity_ids                            = []
    tags                                    = {}
  }

  log_search_alert_rule_networking_services_health_status_degraded = {
    name                                    = "Networking Services Health Status - Degraded"
    resource_group_name                     = module.rg_prd_alertsccn.name
    location                                = "eastus2"
    evaluation_frequency                    = "PT5M"
    window_duration                         = "PT5M"
    scopes                                  = ["/subscriptions/${var.prd_subscription_id}"]
    severity                                = 2
    query                                   = <<-QUERY
      ServiceHealth
      | where ServiceName contains "Network"
      | where HealthStatus == "Degraded"
      | summarize Count = count() by bin(TimeGenerated, 5m)
    QUERY
    time_aggregation_method                 = "Count"
    threshold                               = 0
    operator                                = "GreaterThan"
    resource_id_column                      = null
    metric_measure_column                   = null
    dimension_name                          = null
    dimension_operator                      = null
    dimension_values                        = []
    minimum_failing_periods_to_trigger_alert = 1
    number_of_evaluation_periods            = 1
    auto_mitigation_enabled                 = false
    workspace_alerts_storage_enabled        = false
    description                             = null
    display_name                            = "Networking Services Health Status - Degraded"
    enabled                                 = true
    query_time_range_override               = null
    skip_query_validation                   = false
    action_groups                           = [module.action_group.id]
    custom_properties                       = {}
    identity_type                           = null
    identity_ids                            = []
    tags                                    = {}
  }

  log_search_alert_rule_networking_services_health_status_unavailable = {
    name                                    = "Networking Services Health Status - Unavailable"
    resource_group_name                     = module.rg_prd_alertsccn.name
    location                                = "eastus2"
    evaluation_frequency                    = "PT5M"
    window_duration                         = "PT5M"
    scopes                                  = ["/subscriptions/${var.prd_subscription_id}"]
    severity                                = 1
    query                                   = <<-QUERY
      ServiceHealth
      | where ServiceName contains "Network"
      | where HealthStatus == "Unavailable"
      | summarize Count = count() by bin(TimeGenerated, 5m)
    QUERY
    time_aggregation_method                 = "Count"
    threshold                               = 0
    operator                                = "GreaterThan"
    resource_id_column                      = null
    metric_measure_column                   = null
    dimension_name                          = null
    dimension_operator                      = null
    dimension_values                        = []
    minimum_failing_periods_to_trigger_alert = 1
    number_of_evaluation_periods            = 1
    auto_mitigation_enabled                 = false
    workspace_alerts_storage_enabled        = false
    description                             = null
    display_name                            = "Networking Services Health Status - Unavailable"
    enabled                                 = true
    query_time_range_override               = null
    skip_query_validation                   = false
    action_groups                           = [module.action_group.id]
    custom_properties                       = {}
    identity_type                           = null
    identity_ids                            = []
    tags                                    = {}
  }

  log_search_alert_rule_memory_utilization_high_node_pod = {
    name                                    = "Memory Utilization High (Node-Pod)"
    resource_group_name                     = module.rg_prd_alertsccn.name
    location                                = "eastus2"
    evaluation_frequency                    = "PT5M"
    window_duration                         = "PT5M"
    scopes                                  = ["/subscriptions/${var.prd_subscription_id}"]
    severity                                = 2
    query                                   = <<-QUERY
      Perf
      | where ObjectName == "K8SNode" and CounterName == "memoryUsagePercentage"
      | where CounterValue > 85
      | summarize HighMemoryCount = count() by Computer, bin(TimeGenerated, 5m)
      | where HighMemoryCount > 0
    QUERY
    time_aggregation_method                 = "Count"
    threshold                               = 0
    operator                                = "GreaterThan"
    resource_id_column                      = null
    metric_measure_column                   = null
    dimension_name                          = null
    dimension_operator                      = null
    dimension_values                        = []
    minimum_failing_periods_to_trigger_alert = 1
    number_of_evaluation_periods            = 1
    auto_mitigation_enabled                 = false
    workspace_alerts_storage_enabled        = false
    description                             = "Memory utilization >85% on Kubernetes nodes/pods"
    display_name                            = "Memory Utilization High (Node-Pod)"
    enabled                                 = true
    query_time_range_override               = "P2D"
    skip_query_validation                   = false
    action_groups                           = [module.action_group.id]
    custom_properties                       = {}
    identity_type                           = null
    identity_ids                            = []
    tags                                    = {}
  }

  log_search_alert_rule_networking_services_health_status = {
    name                                    = "Networking services health status"
    resource_group_name                     = module.rg_prd_alertsccn.name
    location                                = "eastus2"
    evaluation_frequency                    = "PT5M"
    window_duration                         = "PT5M"
    scopes                                  = ["/subscriptions/${var.prd_subscription_id}"]
    severity                                = 2
    query                                   = <<-QUERY
      AzureActivity
      | where CategoryValue == "ServiceHealth"
      | where ResourceProvider == "Microsoft.Network"
      | where Properties has "incident"
      | where TimeGenerated > ago(5m)
      | summarize EventCount = count() by bin(TimeGenerated, 5m), Resource
      | where EventCount > 0
    QUERY
    time_aggregation_method                 = "Count"
    threshold                               = 0
    operator                                = "GreaterThan"
    resource_id_column                      = "Resource"
    metric_measure_column                   = null
    dimension_name                          = null
    dimension_operator                      = null
    dimension_values                        = []
    minimum_failing_periods_to_trigger_alert = 1
    number_of_evaluation_periods            = 1
    auto_mitigation_enabled                 = false
    workspace_alerts_storage_enabled        = false
    description                             = null
    display_name                            = "Networking services health status"
    enabled                                 = true
    query_time_range_override               = "P2D"
    skip_query_validation                   = false
    action_groups                           = [module.action_group.id]
    custom_properties                       = {}
    identity_type                           = null
    identity_ids                            = []
    tags                                    = {}
  }

  log_search_alert_rule_networking_services_health_status_02 = {
    name                                    = "Networking services health status 02"
    resource_group_name                     = module.rg_prd_alertsccn.name
    location                                = "eastus2"
    evaluation_frequency                    = "PT5M"
    window_duration                         = "PT5M"
    scopes                                  = ["/subscriptions/${var.subscription_id}"]
    severity                                = 2
    query                                   = <<-QUERY
      AzureActivity
      | where CategoryValue == "ServiceHealth"
      | where ResourceProvider == "Microsoft.Network"
      | where Properties has "incident"
      | where TimeGenerated > ago(5m)
      | summarize EventCount = count() by bin(TimeGenerated, 5m), Resource
      | where EventCount > 0
    QUERY
    time_aggregation_method                 = "Count"
    threshold                               = 0
    operator                                = "GreaterThan"
    resource_id_column                      = "Resource"
    metric_measure_column                   = null
    dimension_name                          = null
    dimension_operator                      = null
    dimension_values                        = []
    minimum_failing_periods_to_trigger_alert = 1
    number_of_evaluation_periods            = 1
    auto_mitigation_enabled                 = false
    workspace_alerts_storage_enabled        = false
    description                             = null
    display_name                            = "Networking services health status 02"
    enabled                                 = true
    query_time_range_override               = "P2D"
    skip_query_validation                   = false
    action_groups                           = [module.action_group.id]
    custom_properties                       = {}
    identity_type                           = null
    identity_ids                            = []
    tags                                    = {}
  }

  log_search_alert_rule_public_ip_address_change = {
    name                                    = "Public IP Address Change"
    resource_group_name                     = module.rg_prd_alertsccn.name
    location                                = "eastus2"
    evaluation_frequency                    = "PT5M"
    window_duration                         = "PT5M"
    scopes                                  = ["/subscriptions/${var.prd_subscription_id}"]
    severity                                = 2
    query                                   = <<-QUERY
      AzureActivity
      | where ResourceProviderValue == "MICROSOFT.NETWORK/PUBLICIPADDRESSES"
      | where OperationNameValue in ("MICROSOFT.NETWORK/PUBLICIPADDRESSES/WRITE", "MICROSOFT.NETWORK/PUBLICIPADDRESSES/DELETE")
      | where ActivityStatusValue == "Succeeded"
      | project TimeGenerated, OperationNameValue, ResourceGroup, Resource, Caller, ActivityStatusValue
    QUERY
    time_aggregation_method                 = "Count"
    threshold                               = 0
    operator                                = "GreaterThan"
    resource_id_column                      = "Resource"
    metric_measure_column                   = null
    dimension_name                          = null
    dimension_operator                      = null
    dimension_values                        = []
    minimum_failing_periods_to_trigger_alert = 1
    number_of_evaluation_periods            = 1
    auto_mitigation_enabled                 = false
    workspace_alerts_storage_enabled        = false
    description                             = null
    display_name                            = "Public IP Address Change"
    enabled                                 = true
    query_time_range_override               = null
    skip_query_validation                   = false
    action_groups                           = [module.action_group.id]
    custom_properties                       = {}
    identity_type                           = null
    identity_ids                            = []
    tags                                    = {}
  }

  log_search_alert_rule_public_ip_address_change_02 = {
    name                                    = "Public IP Address Change 02"
    resource_group_name                     = module.rg_prd_alertsccn.name
    location                                = "eastus2"
    evaluation_frequency                    = "PT5M"
    window_duration                         = "PT5M"
    scopes                                  = ["/subscriptions/${var.subscription_id}"]
    severity                                = 2
    query                                   = <<-QUERY
      AzureActivity
      | where ResourceProviderValue == "MICROSOFT.NETWORK/PUBLICIPADDRESSES"
      | where OperationNameValue in ("MICROSOFT.NETWORK/PUBLICIPADDRESSES/WRITE", "MICROSOFT.NETWORK/PUBLICIPADDRESSES/DELETE")
      | where ActivityStatusValue == "Succeeded"
      | project TimeGenerated, OperationNameValue, ResourceGroup, Resource, Caller, ActivityStatusValue
    QUERY
    time_aggregation_method                 = "Count"
    threshold                               = 0
    operator                                = "GreaterThan"
    resource_id_column                      = "Resource"
    metric_measure_column                   = null
    dimension_name                          = null
    dimension_operator                      = null
    dimension_values                        = []
    minimum_failing_periods_to_trigger_alert = 1
    number_of_evaluation_periods            = 1
    auto_mitigation_enabled                 = false
    workspace_alerts_storage_enabled        = false
    description                             = null
    display_name                            = "Public IP Address Change 02"
    enabled                                 = true
    query_time_range_override               = null
    skip_query_validation                   = false
    action_groups                           = [module.action_group.id]
    custom_properties                       = {}
    identity_type                           = null
    identity_ids                            = []
    tags                                    = {}
  }

  log_search_alert_rule_subnet_change = {
    name                                    = "Subnet change"
    resource_group_name                     = module.rg_prd_alertsccn.name
    location                                = "eastus2"
    evaluation_frequency                    = "PT5M"
    window_duration                         = "PT5M"
    scopes                                  = ["/subscriptions/${var.prd_subscription_id}"]
    severity                                = 2
    query                                   = <<-QUERY
      AzureActivity
      | where OperationNameValue has "MICROSOFT.NETWORK/VIRTUALNETWORKS/SUBNETS/WRITE"
      | where ActivityStatusValue == "Success"
      | where TimeGenerated > ago(5m)
    QUERY
    time_aggregation_method                 = "Count"
    threshold                               = 0
    operator                                = "GreaterThan"
    resource_id_column                      = "_ResourceId"
    metric_measure_column                   = null
    dimension_name                          = null
    dimension_operator                      = null
    dimension_values                        = []
    minimum_failing_periods_to_trigger_alert = 1
    number_of_evaluation_periods            = 1
    auto_mitigation_enabled                 = false
    workspace_alerts_storage_enabled        = false
    description                             = null
    display_name                            = "Subnet change"
    enabled                                 = true
    query_time_range_override               = "P2D"
    skip_query_validation                   = false
    action_groups                           = [module.action_group.id]
    custom_properties                       = {}
    identity_type                           = null
    identity_ids                            = []
    tags                                    = {}
  }

  log_search_alert_rule_subnet_change_02 = {
    name                                    = "Subnet change 02"
    resource_group_name                     = module.rg_prd_alertsccn.name
    location                                = "eastus2"
    evaluation_frequency                    = "PT5M"
    window_duration                         = "PT5M"
    scopes                                  = ["/subscriptions/${var.subscription_id}"]
    severity                                = 2
    query                                   = <<-QUERY
      AzureActivity
      | where OperationNameValue has "MICROSOFT.NETWORK/VIRTUALNETWORKS/SUBNETS/WRITE"
      | where ActivityStatusValue == "Success"
      | where TimeGenerated > ago(5m)
    QUERY
    time_aggregation_method                 = "Count"
    threshold                               = 0
    operator                                = "GreaterThan"
    resource_id_column                      = "_ResourceId"
    metric_measure_column                   = null
    dimension_name                          = null
    dimension_operator                      = null
    dimension_values                        = []
    minimum_failing_periods_to_trigger_alert = 1
    number_of_evaluation_periods            = 1
    auto_mitigation_enabled                 = false
    workspace_alerts_storage_enabled        = false
    description                             = null
    display_name                            = "Subnet change 02"
    enabled                                 = true
    query_time_range_override               = "P2D"
    skip_query_validation                   = false
    action_groups                           = [module.action_group.id]
    custom_properties                       = {}
    identity_type                           = null
    identity_ids                            = []
    tags                                    = {}
  }

  log_search_alert_rule_unauthorized_ip_access_attempt = {
    name                                    = "Unauthorized IP Access Attempt"
    resource_group_name                     = module.rg_prd_alertsccn.name
    location                                = "eastus2"
    evaluation_frequency                    = "PT5M"
    window_duration                         = "PT5M"
    scopes                                  = ["/subscriptions/${var.prd_subscription_id}"]
    severity                                = 2
    query                                   = <<-QUERY
      AzureDiagnostics
      | where Category == "AuditEvent"
      | where OperationName in ("SecretGet", "SecretList", "KeyGet", "KeyList", "CertificateGet", "CertificateList")
      | where isnotempty(CallerIPAddress)
      | where CallerIPAddress !in ("1.2.3.4", "5.6.7.8")
      | summarize Count = count() by bin(TimeGenerated, 5m)
      | where Count > 0
    QUERY
    time_aggregation_method                 = "Total"
    threshold                               = 0
    operator                                = "GreaterThan"
    resource_id_column                      = null
    metric_measure_column                   = "Count"
    dimension_name                          = null
    dimension_operator                      = null
    dimension_values                        = []
    minimum_failing_periods_to_trigger_alert = 1
    number_of_evaluation_periods            = 1
    auto_mitigation_enabled                 = false
    workspace_alerts_storage_enabled        = false
    description                             = null
    display_name                            = "Unauthorized IP Access Attempt"
    enabled                                 = true
    query_time_range_override               = null
    skip_query_validation                   = false
    action_groups                           = [module.action_group.id]
    custom_properties                       = {}
    identity_type                           = null
    identity_ids                            = []
    tags                                    = {}
  }

  log_search_alert_rule_vault_access_denied = {
    name                                    = "Vault Access Denied"
    resource_group_name                     = module.rg_prd_alertsccn.name
    location                                = "eastus2"
    evaluation_frequency                    = "PT5M"
    window_duration                         = "PT5M"
    scopes                                  = ["/subscriptions/${var.prd_subscription_id}"]
    severity                                = 2
    query                                   = <<-QUERY
      AzureDiagnostics
      | where ResourceType == "VAULTS"
      | where OperationName == "SecretGet" or OperationName == "SecretList" or OperationName == "GetKey"
      | where ResultType == "403"
      | where TimeGenerated >= ago(10m)
      | summarize FailedAttempts = count() by bin(TimeGenerated, 5m), Resource, CallerIPAddress
      | where FailedAttempts > 5
    QUERY
    time_aggregation_method                 = "Count"
    threshold                               = 0
    operator                                = "GreaterThan"
    resource_id_column                      = "Resource"
    metric_measure_column                   = null
    dimension_name                          = null
    dimension_operator                      = null
    dimension_values                        = []
    minimum_failing_periods_to_trigger_alert = 1
    number_of_evaluation_periods            = 1
    auto_mitigation_enabled                 = false
    workspace_alerts_storage_enabled        = false
    description                             = null
    display_name                            = "Vault Access Denied"
    enabled                                 = true
    query_time_range_override               = "P2D"
    skip_query_validation                   = false
    action_groups                           = [module.action_group.id]
    custom_properties                       = {}
    identity_type                           = null
    identity_ids                            = []
    tags                                    = {}
  }

  log_search_alert_rule_vault_throttling_events = {
    name                                    = "Vault Throttling Events"
    resource_group_name                     = module.rg_prd_alertsccn.name
    location                                = "eastus2"
    evaluation_frequency                    = "PT5M"
    window_duration                         = "PT5M"
    scopes                                  = ["/subscriptions/${var.prd_subscription_id}"]
    severity                                = 2
    query                                   = <<-QUERY
      AzureDiagnostics
      | where Category == "AuditEvent"
      | where ResultType == "429"
      | summarize Count = count() by bin(TimeGenerated, 5m)
      | where Count > 0
    QUERY
    time_aggregation_method                 = "Total"
    threshold                               = 0
    operator                                = "GreaterThan"
    resource_id_column                      = null
    metric_measure_column                   = "Count"
    dimension_name                          = null
    dimension_operator                      = null
    dimension_values                        = []
    minimum_failing_periods_to_trigger_alert = 1
    number_of_evaluation_periods            = 1
    auto_mitigation_enabled                 = false
    workspace_alerts_storage_enabled        = false
    description                             = null
    display_name                            = "Vault Throttling Events"
    enabled                                 = true
    query_time_range_override               = null
    skip_query_validation                   = false
    action_groups                           = [module.action_group.id]
    custom_properties                       = {}
    identity_type                           = null
    identity_ids                            = []
    tags                                    = {}
  }

  log_search_alert_rule_virtual_network_update_deletion = {
    name                                    = "Virtual Network Update - Deletion"
    resource_group_name                     = module.rg_prd_alertsccn.name
    location                                = "eastus2"
    evaluation_frequency                    = "PT5M"
    window_duration                         = "PT5M"
    scopes                                  = ["/subscriptions/${var.prd_subscription_id}"]
    severity                                = 2
    query                                   = <<-QUERY
      AzureActivity
      | where OperationNameValue in ("MICROSOFT.NETWORK/VIRTUALNETWORKS/WRITE", "MICROSOFT.NETWORK/VIRTUALNETWORKS/DELETE")
      | where ActivityStatusValue == "Success"
      | where TimeGenerated > ago(5m)
    QUERY
    time_aggregation_method                 = "Count"
    threshold                               = 0
    operator                                = "GreaterThan"
    resource_id_column                      = "_ResourceId"
    metric_measure_column                   = null
    dimension_name                          = null
    dimension_operator                      = null
    dimension_values                        = []
    minimum_failing_periods_to_trigger_alert = 1
    number_of_evaluation_periods            = 1
    auto_mitigation_enabled                 = false
    workspace_alerts_storage_enabled        = false
    description                             = null
    display_name                            = "Virtual Network Update - Deletion"
    enabled                                 = true
    query_time_range_override               = "P2D"
    skip_query_validation                   = false
    action_groups                           = [module.action_group.id]
    custom_properties                       = {}
    identity_type                           = null
    identity_ids                            = []
    tags                                    = {}
  }

  log_search_alert_rule_virtual_network_update_deletion_02 = {
    name                                    = "Virtual Network Update - Deletion 02"
    resource_group_name                     = module.rg_prd_alertsccn.name
    location                                = "eastus2"
    evaluation_frequency                    = "PT5M"
    window_duration                         = "PT5M"
    scopes                                  = ["/subscriptions/${var.subscription_id}"]
    severity                                = 2
    query                                   = <<-QUERY
      AzureActivity
      | where OperationNameValue in ("MICROSOFT.NETWORK/VIRTUALNETWORKS/WRITE", "MICROSOFT.NETWORK/VIRTUALNETWORKS/DELETE")
      | where ActivityStatusValue == "Success"
      | where TimeGenerated > ago(5m)
    QUERY
    time_aggregation_method                 = "Count"
    threshold                               = 0
    operator                                = "GreaterThan"
    resource_id_column                      = "_ResourceId"
    metric_measure_column                   = null
    dimension_name                          = null
    dimension_operator                      = null
    dimension_values                        = []
    minimum_failing_periods_to_trigger_alert = 1
    number_of_evaluation_periods            = 1
    auto_mitigation_enabled                 = false
    workspace_alerts_storage_enabled        = false
    description                             = null
    display_name                            = "Virtual Network Update - Deletion 02"
    enabled                                 = true
    query_time_range_override               = "P2D"
    skip_query_validation                   = false
    action_groups                           = [module.action_group.id]
    custom_properties                       = {}
    identity_type                           = null
    identity_ids                            = []
    tags                                    = {}
  }
}

module "log_search_alert_rule_active_connections" {
  source                                    = "./modules/log_search_alert_rule"
  name                                      = local.log_search_alert_rule_active_connections.name
  resource_group_name                       = local.log_search_alert_rule_active_connections.resource_group_name
  location                                  = local.log_search_alert_rule_active_connections.location
  evaluation_frequency                      = local.log_search_alert_rule_active_connections.evaluation_frequency
  window_duration                           = local.log_search_alert_rule_active_connections.window_duration
  scopes                                    = local.log_search_alert_rule_active_connections.scopes
  severity                                  = local.log_search_alert_rule_active_connections.severity
  query                                     = local.log_search_alert_rule_active_connections.query
  time_aggregation_method                   = local.log_search_alert_rule_active_connections.time_aggregation_method
  threshold                                 = local.log_search_alert_rule_active_connections.threshold
  operator                                  = local.log_search_alert_rule_active_connections.operator
  resource_id_column                        = local.log_search_alert_rule_active_connections.resource_id_column
  metric_measure_column                     = local.log_search_alert_rule_active_connections.metric_measure_column
  dimension_name                            = local.log_search_alert_rule_active_connections.dimension_name
  dimension_operator                        = local.log_search_alert_rule_active_connections.dimension_operator
  dimension_values                          = local.log_search_alert_rule_active_connections.dimension_values
  minimum_failing_periods_to_trigger_alert  = local.log_search_alert_rule_active_connections.minimum_failing_periods_to_trigger_alert
  number_of_evaluation_periods              = local.log_search_alert_rule_active_connections.number_of_evaluation_periods
  auto_mitigation_enabled                   = local.log_search_alert_rule_active_connections.auto_mitigation_enabled
  workspace_alerts_storage_enabled          = local.log_search_alert_rule_active_connections.workspace_alerts_storage_enabled
  description                               = local.log_search_alert_rule_active_connections.description
  display_name                              = local.log_search_alert_rule_active_connections.display_name
  enabled                                   = local.log_search_alert_rule_active_connections.enabled
  query_time_range_override                 = local.log_search_alert_rule_active_connections.query_time_range_override
  skip_query_validation                     = local.log_search_alert_rule_active_connections.skip_query_validation
  action_groups                             = local.log_search_alert_rule_active_connections.action_groups
  custom_properties                         = local.log_search_alert_rule_active_connections.custom_properties
  identity_type                             = local.log_search_alert_rule_active_connections.identity_type
  identity_ids                              = local.log_search_alert_rule_active_connections.identity_ids
  tags                                      = local.log_search_alert_rule_active_connections.tags
}

module "log_search_alert_rule_certificate_expiry" {
  source                                    = "./modules/log_search_alert_rule"
  name                                      = local.log_search_alert_rule_certificate_expiry.name
  resource_group_name                       = local.log_search_alert_rule_certificate_expiry.resource_group_name
  location                                  = local.log_search_alert_rule_certificate_expiry.location
  evaluation_frequency                      = local.log_search_alert_rule_certificate_expiry.evaluation_frequency
  window_duration                           = local.log_search_alert_rule_certificate_expiry.window_duration
  scopes                                    = local.log_search_alert_rule_certificate_expiry.scopes
  severity                                  = local.log_search_alert_rule_certificate_expiry.severity
  query                                     = local.log_search_alert_rule_certificate_expiry.query
  time_aggregation_method                   = local.log_search_alert_rule_certificate_expiry.time_aggregation_method
  threshold                                 = local.log_search_alert_rule_certificate_expiry.threshold
  operator                                  = local.log_search_alert_rule_certificate_expiry.operator
  resource_id_column                        = local.log_search_alert_rule_certificate_expiry.resource_id_column
  metric_measure_column                     = local.log_search_alert_rule_certificate_expiry.metric_measure_column
  dimension_name                            = local.log_search_alert_rule_certificate_expiry.dimension_name
  dimension_operator                        = local.log_search_alert_rule_certificate_expiry.dimension_operator
  dimension_values                          = local.log_search_alert_rule_certificate_expiry.dimension_values
  minimum_failing_periods_to_trigger_alert  = local.log_search_alert_rule_certificate_expiry.minimum_failing_periods_to_trigger_alert
  number_of_evaluation_periods              = local.log_search_alert_rule_certificate_expiry.number_of_evaluation_periods
  auto_mitigation_enabled                   = local.log_search_alert_rule_certificate_expiry.auto_mitigation_enabled
  workspace_alerts_storage_enabled          = local.log_search_alert_rule_certificate_expiry.workspace_alerts_storage_enabled
  description                               = local.log_search_alert_rule_certificate_expiry.description
  display_name                              = local.log_search_alert_rule_certificate_expiry.display_name
  enabled                                   = local.log_search_alert_rule_certificate_expiry.enabled
  query_time_range_override                 = local.log_search_alert_rule_certificate_expiry.query_time_range_override
  skip_query_validation                     = local.log_search_alert_rule_certificate_expiry.skip_query_validation
  action_groups                             = local.log_search_alert_rule_certificate_expiry.action_groups
  custom_properties                         = local.log_search_alert_rule_certificate_expiry.custom_properties
  identity_type                             = local.log_search_alert_rule_certificate_expiry.identity_type
  identity_ids                              = local.log_search_alert_rule_certificate_expiry.identity_ids
  tags                                      = local.log_search_alert_rule_certificate_expiry.tags
}

module "log_search_alert_rule_certificate_expiry_imminent" {
  source                                    = "./modules/log_search_alert_rule"
  name                                      = local.log_search_alert_rule_certificate_expiry_imminent.name
  resource_group_name                       = local.log_search_alert_rule_certificate_expiry_imminent.resource_group_name
  location                                  = local.log_search_alert_rule_certificate_expiry_imminent.location
  evaluation_frequency                      = local.log_search_alert_rule_certificate_expiry_imminent.evaluation_frequency
  window_duration                           = local.log_search_alert_rule_certificate_expiry_imminent.window_duration
  scopes                                    = local.log_search_alert_rule_certificate_expiry_imminent.scopes
  severity                                  = local.log_search_alert_rule_certificate_expiry_imminent.severity
  query                                     = local.log_search_alert_rule_certificate_expiry_imminent.query
  time_aggregation_method                   = local.log_search_alert_rule_certificate_expiry_imminent.time_aggregation_method
  threshold                                 = local.log_search_alert_rule_certificate_expiry_imminent.threshold
  operator                                  = local.log_search_alert_rule_certificate_expiry_imminent.operator
  resource_id_column                        = local.log_search_alert_rule_certificate_expiry_imminent.resource_id_column
  metric_measure_column                     = local.log_search_alert_rule_certificate_expiry_imminent.metric_measure_column
  dimension_name                            = local.log_search_alert_rule_certificate_expiry_imminent.dimension_name
  dimension_operator                        = local.log_search_alert_rule_certificate_expiry_imminent.dimension_operator
  dimension_values                          = local.log_search_alert_rule_certificate_expiry_imminent.dimension_values
  minimum_failing_periods_to_trigger_alert  = local.log_search_alert_rule_certificate_expiry_imminent.minimum_failing_periods_to_trigger_alert
  number_of_evaluation_periods              = local.log_search_alert_rule_certificate_expiry_imminent.number_of_evaluation_periods
  auto_mitigation_enabled                   = local.log_search_alert_rule_certificate_expiry_imminent.auto_mitigation_enabled
  workspace_alerts_storage_enabled          = local.log_search_alert_rule_certificate_expiry_imminent.workspace_alerts_storage_enabled
  description                               = local.log_search_alert_rule_certificate_expiry_imminent.description
  display_name                              = local.log_search_alert_rule_certificate_expiry_imminent.display_name
  enabled                                   = local.log_search_alert_rule_certificate_expiry_imminent.enabled
  query_time_range_override                 = local.log_search_alert_rule_certificate_expiry_imminent.query_time_range_override
  skip_query_validation                     = local.log_search_alert_rule_certificate_expiry_imminent.skip_query_validation
  action_groups                             = local.log_search_alert_rule_certificate_expiry_imminent.action_groups
  custom_properties                         = local.log_search_alert_rule_certificate_expiry_imminent.custom_properties
  identity_type                             = local.log_search_alert_rule_certificate_expiry_imminent.identity_type
  identity_ids                              = local.log_search_alert_rule_certificate_expiry_imminent.identity_ids
  tags                                      = local.log_search_alert_rule_certificate_expiry_imminent.tags
}

module "log_search_alert_rule_cpu_utilization_high_node_pod" {
  source                                    = "./modules/log_search_alert_rule"
  name                                      = local.log_search_alert_rule_cpu_utilization_high_node_pod.name
  resource_group_name                       = local.log_search_alert_rule_cpu_utilization_high_node_pod.resource_group_name
  location                                  = local.log_search_alert_rule_cpu_utilization_high_node_pod.location
  evaluation_frequency                      = local.log_search_alert_rule_cpu_utilization_high_node_pod.evaluation_frequency
  window_duration                           = local.log_search_alert_rule_cpu_utilization_high_node_pod.window_duration
  scopes                                    = local.log_search_alert_rule_cpu_utilization_high_node_pod.scopes
  severity                                  = local.log_search_alert_rule_cpu_utilization_high_node_pod.severity
  query                                     = local.log_search_alert_rule_cpu_utilization_high_node_pod.query
  time_aggregation_method                   = local.log_search_alert_rule_cpu_utilization_high_node_pod.time_aggregation_method
  threshold                                 = local.log_search_alert_rule_cpu_utilization_high_node_pod.threshold
  operator                                  = local.log_search_alert_rule_cpu_utilization_high_node_pod.operator
  resource_id_column                        = local.log_search_alert_rule_cpu_utilization_high_node_pod.resource_id_column
  metric_measure_column                     = local.log_search_alert_rule_cpu_utilization_high_node_pod.metric_measure_column
  dimension_name                            = local.log_search_alert_rule_cpu_utilization_high_node_pod.dimension_name
  dimension_operator                        = local.log_search_alert_rule_cpu_utilization_high_node_pod.dimension_operator
  dimension_values                          = local.log_search_alert_rule_cpu_utilization_high_node_pod.dimension_values
  minimum_failing_periods_to_trigger_alert  = local.log_search_alert_rule_cpu_utilization_high_node_pod.minimum_failing_periods_to_trigger_alert
  number_of_evaluation_periods              = local.log_search_alert_rule_cpu_utilization_high_node_pod.number_of_evaluation_periods
  auto_mitigation_enabled                   = local.log_search_alert_rule_cpu_utilization_high_node_pod.auto_mitigation_enabled
  workspace_alerts_storage_enabled          = local.log_search_alert_rule_cpu_utilization_high_node_pod.workspace_alerts_storage_enabled
  description                               = local.log_search_alert_rule_cpu_utilization_high_node_pod.description
  display_name                              = local.log_search_alert_rule_cpu_utilization_high_node_pod.display_name
  enabled                                   = local.log_search_alert_rule_cpu_utilization_high_node_pod.enabled
  query_time_range_override                 = local.log_search_alert_rule_cpu_utilization_high_node_pod.query_time_range_override
  skip_query_validation                     = local.log_search_alert_rule_cpu_utilization_high_node_pod.skip_query_validation
  action_groups                             = local.log_search_alert_rule_cpu_utilization_high_node_pod.action_groups
  custom_properties                         = local.log_search_alert_rule_cpu_utilization_high_node_pod.custom_properties
  identity_type                             = local.log_search_alert_rule_cpu_utilization_high_node_pod.identity_type
  identity_ids                              = local.log_search_alert_rule_cpu_utilization_high_node_pod.identity_ids
  tags                                      = local.log_search_alert_rule_cpu_utilization_high_node_pod.tags
}

module "log_search_alert_rule_dns_latency" {
  source                                    = "./modules/log_search_alert_rule"
  name                                      = local.log_search_alert_rule_dns_latency.name
  resource_group_name                       = local.log_search_alert_rule_dns_latency.resource_group_name
  location                                  = local.log_search_alert_rule_dns_latency.location
  evaluation_frequency                      = local.log_search_alert_rule_dns_latency.evaluation_frequency
  window_duration                           = local.log_search_alert_rule_dns_latency.window_duration
  scopes                                    = local.log_search_alert_rule_dns_latency.scopes
  severity                                  = local.log_search_alert_rule_dns_latency.severity
  query                                     = local.log_search_alert_rule_dns_latency.query
  time_aggregation_method                   = local.log_search_alert_rule_dns_latency.time_aggregation_method
  threshold                                 = local.log_search_alert_rule_dns_latency.threshold
  operator                                  = local.log_search_alert_rule_dns_latency.operator
  resource_id_column                        = local.log_search_alert_rule_dns_latency.resource_id_column
  metric_measure_column                     = local.log_search_alert_rule_dns_latency.metric_measure_column
  dimension_name                            = local.log_search_alert_rule_dns_latency.dimension_name
  dimension_operator                        = local.log_search_alert_rule_dns_latency.dimension_operator
  dimension_values                          = local.log_search_alert_rule_dns_latency.dimension_values
  minimum_failing_periods_to_trigger_alert  = local.log_search_alert_rule_dns_latency.minimum_failing_periods_to_trigger_alert
  number_of_evaluation_periods              = local.log_search_alert_rule_dns_latency.number_of_evaluation_periods
  auto_mitigation_enabled                   = local.log_search_alert_rule_dns_latency.auto_mitigation_enabled
  workspace_alerts_storage_enabled          = local.log_search_alert_rule_dns_latency.workspace_alerts_storage_enabled
  description                               = local.log_search_alert_rule_dns_latency.description
  display_name                              = local.log_search_alert_rule_dns_latency.display_name
  enabled                                   = local.log_search_alert_rule_dns_latency.enabled
  query_time_range_override                 = local.log_search_alert_rule_dns_latency.query_time_range_override
  skip_query_validation                     = local.log_search_alert_rule_dns_latency.skip_query_validation
  action_groups                             = local.log_search_alert_rule_dns_latency.action_groups
  custom_properties                         = local.log_search_alert_rule_dns_latency.custom_properties
  identity_type                             = local.log_search_alert_rule_dns_latency.identity_type
  identity_ids                              = local.log_search_alert_rule_dns_latency.identity_ids
  tags                                      = local.log_search_alert_rule_dns_latency.tags
}

module "log_search_alert_rule_failed_connection_count" {
  source                                    = "./modules/log_search_alert_rule"
  name                                      = local.log_search_alert_rule_failed_connection_count.name
  resource_group_name                       = local.log_search_alert_rule_failed_connection_count.resource_group_name
  location                                  = local.log_search_alert_rule_failed_connection_count.location
  evaluation_frequency                      = local.log_search_alert_rule_failed_connection_count.evaluation_frequency
  window_duration                           = local.log_search_alert_rule_failed_connection_count.window_duration
  scopes                                    = local.log_search_alert_rule_failed_connection_count.scopes
  severity                                  = local.log_search_alert_rule_failed_connection_count.severity
  query                                     = local.log_search_alert_rule_failed_connection_count.query
  time_aggregation_method                   = local.log_search_alert_rule_failed_connection_count.time_aggregation_method
  threshold                                 = local.log_search_alert_rule_failed_connection_count.threshold
  operator                                  = local.log_search_alert_rule_failed_connection_count.operator
  resource_id_column                        = local.log_search_alert_rule_failed_connection_count.resource_id_column
  metric_measure_column                     = local.log_search_alert_rule_failed_connection_count.metric_measure_column
  dimension_name                            = local.log_search_alert_rule_failed_connection_count.dimension_name
  dimension_operator                        = local.log_search_alert_rule_failed_connection_count.dimension_operator
  dimension_values                          = local.log_search_alert_rule_failed_connection_count.dimension_values
  minimum_failing_periods_to_trigger_alert  = local.log_search_alert_rule_failed_connection_count.minimum_failing_periods_to_trigger_alert
  number_of_evaluation_periods              = local.log_search_alert_rule_failed_connection_count.number_of_evaluation_periods
  auto_mitigation_enabled                   = local.log_search_alert_rule_failed_connection_count.auto_mitigation_enabled
  workspace_alerts_storage_enabled          = local.log_search_alert_rule_failed_connection_count.workspace_alerts_storage_enabled
  description                               = local.log_search_alert_rule_failed_connection_count.description
  display_name                              = local.log_search_alert_rule_failed_connection_count.display_name
  enabled                                   = local.log_search_alert_rule_failed_connection_count.enabled
  query_time_range_override                 = local.log_search_alert_rule_failed_connection_count.query_time_range_override
  skip_query_validation                     = local.log_search_alert_rule_failed_connection_count.skip_query_validation
  action_groups                             = local.log_search_alert_rule_failed_connection_count.action_groups
  custom_properties                         = local.log_search_alert_rule_failed_connection_count.custom_properties
  identity_type                             = local.log_search_alert_rule_failed_connection_count.identity_type
  identity_ids                              = local.log_search_alert_rule_failed_connection_count.identity_ids
  tags                                      = local.log_search_alert_rule_failed_connection_count.tags
}

module "log_search_alert_rule_flow_utilization" {
  source                                    = "./modules/log_search_alert_rule"
  name                                      = local.log_search_alert_rule_flow_utilization.name
  resource_group_name                       = local.log_search_alert_rule_flow_utilization.resource_group_name
  location                                  = local.log_search_alert_rule_flow_utilization.location
  evaluation_frequency                      = local.log_search_alert_rule_flow_utilization.evaluation_frequency
  window_duration                           = local.log_search_alert_rule_flow_utilization.window_duration
  scopes                                    = local.log_search_alert_rule_flow_utilization.scopes
  severity                                  = local.log_search_alert_rule_flow_utilization.severity
  query                                     = local.log_search_alert_rule_flow_utilization.query
  time_aggregation_method                   = local.log_search_alert_rule_flow_utilization.time_aggregation_method
  threshold                                 = local.log_search_alert_rule_flow_utilization.threshold
  operator                                  = local.log_search_alert_rule_flow_utilization.operator
  resource_id_column                        = local.log_search_alert_rule_flow_utilization.resource_id_column
  metric_measure_column                     = local.log_search_alert_rule_flow_utilization.metric_measure_column
  dimension_name                            = local.log_search_alert_rule_flow_utilization.dimension_name
  dimension_operator                        = local.log_search_alert_rule_flow_utilization.dimension_operator
  dimension_values                          = local.log_search_alert_rule_flow_utilization.dimension_values
  minimum_failing_periods_to_trigger_alert  = local.log_search_alert_rule_flow_utilization.minimum_failing_periods_to_trigger_alert
  number_of_evaluation_periods              = local.log_search_alert_rule_flow_utilization.number_of_evaluation_periods
  auto_mitigation_enabled                   = local.log_search_alert_rule_flow_utilization.auto_mitigation_enabled
  workspace_alerts_storage_enabled          = local.log_search_alert_rule_flow_utilization.workspace_alerts_storage_enabled
  description                               = local.log_search_alert_rule_flow_utilization.description
  display_name                              = local.log_search_alert_rule_flow_utilization.display_name
  enabled                                   = local.log_search_alert_rule_flow_utilization.enabled
  query_time_range_override                 = local.log_search_alert_rule_flow_utilization.query_time_range_override
  skip_query_validation                     = local.log_search_alert_rule_flow_utilization.skip_query_validation
  action_groups                             = local.log_search_alert_rule_flow_utilization.action_groups
  custom_properties                         = local.log_search_alert_rule_flow_utilization.custom_properties
  identity_type                             = local.log_search_alert_rule_flow_utilization.identity_type
  identity_ids                              = local.log_search_alert_rule_flow_utilization.identity_ids
  tags                                      = local.log_search_alert_rule_flow_utilization.tags
}

module "log_search_alert_rule_high_latency_vault_operations" {
  source                                    = "./modules/log_search_alert_rule"
  name                                      = local.log_search_alert_rule_high_latency_vault_operations.name
  resource_group_name                       = local.log_search_alert_rule_high_latency_vault_operations.resource_group_name
  location                                  = local.log_search_alert_rule_high_latency_vault_operations.location
  evaluation_frequency                      = local.log_search_alert_rule_high_latency_vault_operations.evaluation_frequency
  window_duration                           = local.log_search_alert_rule_high_latency_vault_operations.window_duration
  scopes                                    = local.log_search_alert_rule_high_latency_vault_operations.scopes
  severity                                  = local.log_search_alert_rule_high_latency_vault_operations.severity
  query                                     = local.log_search_alert_rule_high_latency_vault_operations.query
  time_aggregation_method                   = local.log_search_alert_rule_high_latency_vault_operations.time_aggregation_method
  threshold                                 = local.log_search_alert_rule_high_latency_vault_operations.threshold
  operator                                  = local.log_search_alert_rule_high_latency_vault_operations.operator
  resource_id_column                        = local.log_search_alert_rule_high_latency_vault_operations.resource_id_column
  metric_measure_column                     = local.log_search_alert_rule_high_latency_vault_operations.metric_measure_column
  dimension_name                            = local.log_search_alert_rule_high_latency_vault_operations.dimension_name
  dimension_operator                        = local.log_search_alert_rule_high_latency_vault_operations.dimension_operator
  dimension_values                          = local.log_search_alert_rule_high_latency_vault_operations.dimension_values
  minimum_failing_periods_to_trigger_alert  = local.log_search_alert_rule_high_latency_vault_operations.minimum_failing_periods_to_trigger_alert
  number_of_evaluation_periods              = local.log_search_alert_rule_high_latency_vault_operations.number_of_evaluation_periods
  auto_mitigation_enabled                   = local.log_search_alert_rule_high_latency_vault_operations.auto_mitigation_enabled
  workspace_alerts_storage_enabled          = local.log_search_alert_rule_high_latency_vault_operations.workspace_alerts_storage_enabled
  description                               = local.log_search_alert_rule_high_latency_vault_operations.description
  display_name                              = local.log_search_alert_rule_high_latency_vault_operations.display_name
  enabled                                   = local.log_search_alert_rule_high_latency_vault_operations.enabled
  query_time_range_override                 = local.log_search_alert_rule_high_latency_vault_operations.query_time_range_override
  skip_query_validation                     = local.log_search_alert_rule_high_latency_vault_operations.skip_query_validation
  action_groups                             = local.log_search_alert_rule_high_latency_vault_operations.action_groups
  custom_properties                         = local.log_search_alert_rule_high_latency_vault_operations.custom_properties
  identity_type                             = local.log_search_alert_rule_high_latency_vault_operations.identity_type
  identity_ids                              = local.log_search_alert_rule_high_latency_vault_operations.identity_ids
  tags                                      = local.log_search_alert_rule_high_latency_vault_operations.tags
}

module "log_search_alert_rule_high_memory_utilization" {
  source                                    = "./modules/log_search_alert_rule"
  name                                      = local.log_search_alert_rule_high_memory_utilization.name
  resource_group_name                       = local.log_search_alert_rule_high_memory_utilization.resource_group_name
  location                                  = local.log_search_alert_rule_high_memory_utilization.location
  evaluation_frequency                      = local.log_search_alert_rule_high_memory_utilization.evaluation_frequency
  window_duration                           = local.log_search_alert_rule_high_memory_utilization.window_duration
  scopes                                    = local.log_search_alert_rule_high_memory_utilization.scopes
  severity                                  = local.log_search_alert_rule_high_memory_utilization.severity
  query                                     = local.log_search_alert_rule_high_memory_utilization.query
  time_aggregation_method                   = local.log_search_alert_rule_high_memory_utilization.time_aggregation_method
  threshold                                 = local.log_search_alert_rule_high_memory_utilization.threshold
  operator                                  = local.log_search_alert_rule_high_memory_utilization.operator
  resource_id_column                        = local.log_search_alert_rule_high_memory_utilization.resource_id_column
  metric_measure_column                     = local.log_search_alert_rule_high_memory_utilization.metric_measure_column
  dimension_name                            = local.log_search_alert_rule_high_memory_utilization.dimension_name
  dimension_operator                        = local.log_search_alert_rule_high_memory_utilization.dimension_operator
  dimension_values                          = local.log_search_alert_rule_high_memory_utilization.dimension_values
  minimum_failing_periods_to_trigger_alert  = local.log_search_alert_rule_high_memory_utilization.minimum_failing_periods_to_trigger_alert
  number_of_evaluation_periods              = local.log_search_alert_rule_high_memory_utilization.number_of_evaluation_periods
  auto_mitigation_enabled                   = local.log_search_alert_rule_high_memory_utilization.auto_mitigation_enabled
  workspace_alerts_storage_enabled          = local.log_search_alert_rule_high_memory_utilization.workspace_alerts_storage_enabled
  description                               = local.log_search_alert_rule_high_memory_utilization.description
  display_name                              = local.log_search_alert_rule_high_memory_utilization.display_name
  enabled                                   = local.log_search_alert_rule_high_memory_utilization.enabled
  query_time_range_override                 = local.log_search_alert_rule_high_memory_utilization.query_time_range_override
  skip_query_validation                     = local.log_search_alert_rule_high_memory_utilization.skip_query_validation
  action_groups                             = local.log_search_alert_rule_high_memory_utilization.action_groups
  custom_properties                         = local.log_search_alert_rule_high_memory_utilization.custom_properties
  identity_type                             = local.log_search_alert_rule_high_memory_utilization.identity_type
  identity_ids                              = local.log_search_alert_rule_high_memory_utilization.identity_ids
  tags                                      = local.log_search_alert_rule_high_memory_utilization.tags
}

module "log_search_alert_rule_high_network_latency" {
  source                                    = "./modules/log_search_alert_rule"
  name                                      = local.log_search_alert_rule_high_network_latency.name
  resource_group_name                       = local.log_search_alert_rule_high_network_latency.resource_group_name
  location                                  = local.log_search_alert_rule_high_network_latency.location
  evaluation_frequency                      = local.log_search_alert_rule_high_network_latency.evaluation_frequency
  window_duration                           = local.log_search_alert_rule_high_network_latency.window_duration
  scopes                                    = local.log_search_alert_rule_high_network_latency.scopes
  severity                                  = local.log_search_alert_rule_high_network_latency.severity
  query                                     = local.log_search_alert_rule_high_network_latency.query
  time_aggregation_method                   = local.log_search_alert_rule_high_network_latency.time_aggregation_method
  threshold                                 = local.log_search_alert_rule_high_network_latency.threshold
  operator                                  = local.log_search_alert_rule_high_network_latency.operator
  resource_id_column                        = local.log_search_alert_rule_high_network_latency.resource_id_column
  metric_measure_column                     = local.log_search_alert_rule_high_network_latency.metric_measure_column
  dimension_name                            = local.log_search_alert_rule_high_network_latency.dimension_name
  dimension_operator                        = local.log_search_alert_rule_high_network_latency.dimension_operator
  dimension_values                          = local.log_search_alert_rule_high_network_latency.dimension_values
  minimum_failing_periods_to_trigger_alert  = local.log_search_alert_rule_high_network_latency.minimum_failing_periods_to_trigger_alert
  number_of_evaluation_periods              = local.log_search_alert_rule_high_network_latency.number_of_evaluation_periods
  auto_mitigation_enabled                   = local.log_search_alert_rule_high_network_latency.auto_mitigation_enabled
  workspace_alerts_storage_enabled          = local.log_search_alert_rule_high_network_latency.workspace_alerts_storage_enabled
  description                               = local.log_search_alert_rule_high_network_latency.description
  display_name                              = local.log_search_alert_rule_high_network_latency.display_name
  enabled                                   = local.log_search_alert_rule_high_network_latency.enabled
  query_time_range_override                 = local.log_search_alert_rule_high_network_latency.query_time_range_override
  skip_query_validation                     = local.log_search_alert_rule_high_network_latency.skip_query_validation
  action_groups                             = local.log_search_alert_rule_high_network_latency.action_groups
  custom_properties                         = local.log_search_alert_rule_high_network_latency.custom_properties
  identity_type                             = local.log_search_alert_rule_high_network_latency.identity_type
  identity_ids                              = local.log_search_alert_rule_high_network_latency.identity_ids
  tags                                      = local.log_search_alert_rule_high_network_latency.tags
}

module "log_search_alert_rule_high_network_throughput" {
  source                                    = "./modules/log_search_alert_rule"
  name                                      = local.log_search_alert_rule_high_network_throughput.name
  resource_group_name                       = local.log_search_alert_rule_high_network_throughput.resource_group_name
  location                                  = local.log_search_alert_rule_high_network_throughput.location
  evaluation_frequency                      = local.log_search_alert_rule_high_network_throughput.evaluation_frequency
  window_duration                           = local.log_search_alert_rule_high_network_throughput.window_duration
  scopes                                    = local.log_search_alert_rule_high_network_throughput.scopes
  severity                                  = local.log_search_alert_rule_high_network_throughput.severity
  query                                     = local.log_search_alert_rule_high_network_throughput.query
  time_aggregation_method                   = local.log_search_alert_rule_high_network_throughput.time_aggregation_method
  threshold                                 = local.log_search_alert_rule_high_network_throughput.threshold
  operator                                  = local.log_search_alert_rule_high_network_throughput.operator
  resource_id_column                        = local.log_search_alert_rule_high_network_throughput.resource_id_column
  metric_measure_column                     = local.log_search_alert_rule_high_network_throughput.metric_measure_column
  dimension_name                            = local.log_search_alert_rule_high_network_throughput.dimension_name
  dimension_operator                        = local.log_search_alert_rule_high_network_throughput.dimension_operator
  dimension_values                          = local.log_search_alert_rule_high_network_throughput.dimension_values
  minimum_failing_periods_to_trigger_alert  = local.log_search_alert_rule_high_network_throughput.minimum_failing_periods_to_trigger_alert
  number_of_evaluation_periods              = local.log_search_alert_rule_high_network_throughput.number_of_evaluation_periods
  auto_mitigation_enabled                   = local.log_search_alert_rule_high_network_throughput.auto_mitigation_enabled
  workspace_alerts_storage_enabled          = local.log_search_alert_rule_high_network_throughput.workspace_alerts_storage_enabled
  description                               = local.log_search_alert_rule_high_network_throughput.description
  display_name                              = local.log_search_alert_rule_high_network_throughput.display_name
  enabled                                   = local.log_search_alert_rule_high_network_throughput.enabled
  query_time_range_override                 = local.log_search_alert_rule_high_network_throughput.query_time_range_override
  skip_query_validation                     = local.log_search_alert_rule_high_network_throughput.skip_query_validation
  action_groups                             = local.log_search_alert_rule_high_network_throughput.action_groups
  custom_properties                         = local.log_search_alert_rule_high_network_throughput.custom_properties
  identity_type                             = local.log_search_alert_rule_high_network_throughput.identity_type
  identity_ids                              = local.log_search_alert_rule_high_network_throughput.identity_ids
  tags                                      = local.log_search_alert_rule_high_network_throughput.tags
}

module "log_search_alert_rule_high_percentage_cpu_utilization" {
  source                                    = "./modules/log_search_alert_rule"
  name                                      = local.log_search_alert_rule_high_percentage_cpu_utilization.name
  resource_group_name                       = local.log_search_alert_rule_high_percentage_cpu_utilization.resource_group_name
  location                                  = local.log_search_alert_rule_high_percentage_cpu_utilization.location
  evaluation_frequency                      = local.log_search_alert_rule_high_percentage_cpu_utilization.evaluation_frequency
  window_duration                           = local.log_search_alert_rule_high_percentage_cpu_utilization.window_duration
  scopes                                    = local.log_search_alert_rule_high_percentage_cpu_utilization.scopes
  severity                                  = local.log_search_alert_rule_high_percentage_cpu_utilization.severity
  query                                     = local.log_search_alert_rule_high_percentage_cpu_utilization.query
  time_aggregation_method                   = local.log_search_alert_rule_high_percentage_cpu_utilization.time_aggregation_method
  threshold                                 = local.log_search_alert_rule_high_percentage_cpu_utilization.threshold
  operator                                  = local.log_search_alert_rule_high_percentage_cpu_utilization.operator
  resource_id_column                        = local.log_search_alert_rule_high_percentage_cpu_utilization.resource_id_column
  metric_measure_column                     = local.log_search_alert_rule_high_percentage_cpu_utilization.metric_measure_column
  dimension_name                            = local.log_search_alert_rule_high_percentage_cpu_utilization.dimension_name
  dimension_operator                        = local.log_search_alert_rule_high_percentage_cpu_utilization.dimension_operator
  dimension_values                          = local.log_search_alert_rule_high_percentage_cpu_utilization.dimension_values
  minimum_failing_periods_to_trigger_alert  = local.log_search_alert_rule_high_percentage_cpu_utilization.minimum_failing_periods_to_trigger_alert
  number_of_evaluation_periods              = local.log_search_alert_rule_high_percentage_cpu_utilization.number_of_evaluation_periods
  auto_mitigation_enabled                   = local.log_search_alert_rule_high_percentage_cpu_utilization.auto_mitigation_enabled
  workspace_alerts_storage_enabled          = local.log_search_alert_rule_high_percentage_cpu_utilization.workspace_alerts_storage_enabled
  description                               = local.log_search_alert_rule_high_percentage_cpu_utilization.description
  display_name                              = local.log_search_alert_rule_high_percentage_cpu_utilization.display_name
  enabled                                   = local.log_search_alert_rule_high_percentage_cpu_utilization.enabled
  query_time_range_override                 = local.log_search_alert_rule_high_percentage_cpu_utilization.query_time_range_override
  skip_query_validation                     = local.log_search_alert_rule_high_percentage_cpu_utilization.skip_query_validation
  action_groups                             = local.log_search_alert_rule_high_percentage_cpu_utilization.action_groups
  custom_properties                         = local.log_search_alert_rule_high_percentage_cpu_utilization.custom_properties
  identity_type                             = local.log_search_alert_rule_high_percentage_cpu_utilization.identity_type
  identity_ids                              = local.log_search_alert_rule_high_percentage_cpu_utilization.identity_ids
  tags                                      = local.log_search_alert_rule_high_percentage_cpu_utilization.tags
}

module "log_search_alert_rule_kubelet_down" {
  source = "./modules/log_search_alert_rule"
  
  name                                      = local.log_search_alert_rule_kubelet_down.name
  resource_group_name                       = local.log_search_alert_rule_kubelet_down.resource_group_name
  location                                  = local.log_search_alert_rule_kubelet_down.location
  evaluation_frequency                      = local.log_search_alert_rule_kubelet_down.evaluation_frequency
  window_duration                           = local.log_search_alert_rule_kubelet_down.window_duration
  scopes                                    = local.log_search_alert_rule_kubelet_down.scopes
  severity                                  = local.log_search_alert_rule_kubelet_down.severity
  query                                     = local.log_search_alert_rule_kubelet_down.query
  time_aggregation_method                   = local.log_search_alert_rule_kubelet_down.time_aggregation_method
  threshold                                 = local.log_search_alert_rule_kubelet_down.threshold
  operator                                  = local.log_search_alert_rule_kubelet_down.operator
  resource_id_column                        = local.log_search_alert_rule_kubelet_down.resource_id_column
  metric_measure_column                     = local.log_search_alert_rule_kubelet_down.metric_measure_column
  dimension_name                            = local.log_search_alert_rule_kubelet_down.dimension_name
  dimension_operator                        = local.log_search_alert_rule_kubelet_down.dimension_operator
  dimension_values                          = local.log_search_alert_rule_kubelet_down.dimension_values
  minimum_failing_periods_to_trigger_alert = local.log_search_alert_rule_kubelet_down.minimum_failing_periods_to_trigger_alert
  number_of_evaluation_periods              = local.log_search_alert_rule_kubelet_down.number_of_evaluation_periods
  auto_mitigation_enabled                   = local.log_search_alert_rule_kubelet_down.auto_mitigation_enabled
  workspace_alerts_storage_enabled          = local.log_search_alert_rule_kubelet_down.workspace_alerts_storage_enabled
  description                               = local.log_search_alert_rule_kubelet_down.description
  display_name                              = local.log_search_alert_rule_kubelet_down.display_name
  enabled                                   = local.log_search_alert_rule_kubelet_down.enabled
  query_time_range_override                 = local.log_search_alert_rule_kubelet_down.query_time_range_override
  skip_query_validation                     = local.log_search_alert_rule_kubelet_down.skip_query_validation
  action_groups                             = local.log_search_alert_rule_kubelet_down.action_groups
  custom_properties                         = local.log_search_alert_rule_kubelet_down.custom_properties
  identity_type                             = local.log_search_alert_rule_kubelet_down.identity_type
  identity_ids                              = local.log_search_alert_rule_kubelet_down.identity_ids
  tags                                      = local.log_search_alert_rule_kubelet_down.tags
}

module "log_search_alert_rule_pod_crashloopbackoff" {
  source = "./modules/log_search_alert_rule"
  
  name                                      = local.log_search_alert_rule_pod_crashloopbackoff.name
  resource_group_name                       = local.log_search_alert_rule_pod_crashloopbackoff.resource_group_name
  location                                  = local.log_search_alert_rule_pod_crashloopbackoff.location
  evaluation_frequency                      = local.log_search_alert_rule_pod_crashloopbackoff.evaluation_frequency
  window_duration                           = local.log_search_alert_rule_pod_crashloopbackoff.window_duration
  scopes                                    = local.log_search_alert_rule_pod_crashloopbackoff.scopes
  severity                                  = local.log_search_alert_rule_pod_crashloopbackoff.severity
  query                                     = local.log_search_alert_rule_pod_crashloopbackoff.query
  time_aggregation_method                   = local.log_search_alert_rule_pod_crashloopbackoff.time_aggregation_method
  threshold                                 = local.log_search_alert_rule_pod_crashloopbackoff.threshold
  operator                                  = local.log_search_alert_rule_pod_crashloopbackoff.operator
  resource_id_column                        = local.log_search_alert_rule_pod_crashloopbackoff.resource_id_column
  metric_measure_column                     = local.log_search_alert_rule_pod_crashloopbackoff.metric_measure_column
  dimension_name                            = local.log_search_alert_rule_pod_crashloopbackoff.dimension_name
  dimension_operator                        = local.log_search_alert_rule_pod_crashloopbackoff.dimension_operator
  dimension_values                          = local.log_search_alert_rule_pod_crashloopbackoff.dimension_values
  minimum_failing_periods_to_trigger_alert = local.log_search_alert_rule_pod_crashloopbackoff.minimum_failing_periods_to_trigger_alert
  number_of_evaluation_periods              = local.log_search_alert_rule_pod_crashloopbackoff.number_of_evaluation_periods
  auto_mitigation_enabled                   = local.log_search_alert_rule_pod_crashloopbackoff.auto_mitigation_enabled
  workspace_alerts_storage_enabled          = local.log_search_alert_rule_pod_crashloopbackoff.workspace_alerts_storage_enabled
  description                               = local.log_search_alert_rule_pod_crashloopbackoff.description
  display_name                              = local.log_search_alert_rule_pod_crashloopbackoff.display_name
  enabled                                   = local.log_search_alert_rule_pod_crashloopbackoff.enabled
  query_time_range_override                 = local.log_search_alert_rule_pod_crashloopbackoff.query_time_range_override
  skip_query_validation                     = local.log_search_alert_rule_pod_crashloopbackoff.skip_query_validation
  action_groups                             = local.log_search_alert_rule_pod_crashloopbackoff.action_groups
  custom_properties                         = local.log_search_alert_rule_pod_crashloopbackoff.custom_properties
  identity_type                             = local.log_search_alert_rule_pod_crashloopbackoff.identity_type
  identity_ids                              = local.log_search_alert_rule_pod_crashloopbackoff.identity_ids
  tags                                      = local.log_search_alert_rule_pod_crashloopbackoff.tags
}

module "log_search_alert_rule_postgresql_db_availability" {
  source = "./modules/log_search_alert_rule"
  
  name                                      = local.log_search_alert_rule_postgresql_db_availability.name
  resource_group_name                       = local.log_search_alert_rule_postgresql_db_availability.resource_group_name
  location                                  = local.log_search_alert_rule_postgresql_db_availability.location
  evaluation_frequency                      = local.log_search_alert_rule_postgresql_db_availability.evaluation_frequency
  window_duration                           = local.log_search_alert_rule_postgresql_db_availability.window_duration
  scopes                                    = local.log_search_alert_rule_postgresql_db_availability.scopes
  severity                                  = local.log_search_alert_rule_postgresql_db_availability.severity
  query                                     = local.log_search_alert_rule_postgresql_db_availability.query
  time_aggregation_method                   = local.log_search_alert_rule_postgresql_db_availability.time_aggregation_method
  threshold                                 = local.log_search_alert_rule_postgresql_db_availability.threshold
  operator                                  = local.log_search_alert_rule_postgresql_db_availability.operator
  resource_id_column                        = local.log_search_alert_rule_postgresql_db_availability.resource_id_column
  metric_measure_column                     = local.log_search_alert_rule_postgresql_db_availability.metric_measure_column
  dimension_name                            = local.log_search_alert_rule_postgresql_db_availability.dimension_name
  dimension_operator                        = local.log_search_alert_rule_postgresql_db_availability.dimension_operator
  dimension_values                          = local.log_search_alert_rule_postgresql_db_availability.dimension_values
  minimum_failing_periods_to_trigger_alert = local.log_search_alert_rule_postgresql_db_availability.minimum_failing_periods_to_trigger_alert
  number_of_evaluation_periods              = local.log_search_alert_rule_postgresql_db_availability.number_of_evaluation_periods
  auto_mitigation_enabled                   = local.log_search_alert_rule_postgresql_db_availability.auto_mitigation_enabled
  workspace_alerts_storage_enabled          = local.log_search_alert_rule_postgresql_db_availability.workspace_alerts_storage_enabled
  description                               = local.log_search_alert_rule_postgresql_db_availability.description
  display_name                              = local.log_search_alert_rule_postgresql_db_availability.display_name
  enabled                                   = local.log_search_alert_rule_postgresql_db_availability.enabled
  query_time_range_override                 = local.log_search_alert_rule_postgresql_db_availability.query_time_range_override
  skip_query_validation                     = local.log_search_alert_rule_postgresql_db_availability.skip_query_validation
  action_groups                             = local.log_search_alert_rule_postgresql_db_availability.action_groups
  custom_properties                         = local.log_search_alert_rule_postgresql_db_availability.custom_properties
  identity_type                             = local.log_search_alert_rule_postgresql_db_availability.identity_type
  identity_ids                              = local.log_search_alert_rule_postgresql_db_availability.identity_ids
  tags                                      = local.log_search_alert_rule_postgresql_db_availability.tags
}

module "log_search_alert_rule_load_balancer_health_probe_failure" {
  source = "./modules/log_search_alert_rule"
  
  name                                      = local.log_search_alert_rule_load_balancer_health_probe_failure.name
  resource_group_name                       = local.log_search_alert_rule_load_balancer_health_probe_failure.resource_group_name
  location                                  = local.log_search_alert_rule_load_balancer_health_probe_failure.location
  evaluation_frequency                      = local.log_search_alert_rule_load_balancer_health_probe_failure.evaluation_frequency
  window_duration                           = local.log_search_alert_rule_load_balancer_health_probe_failure.window_duration
  scopes                                    = local.log_search_alert_rule_load_balancer_health_probe_failure.scopes
  severity                                  = local.log_search_alert_rule_load_balancer_health_probe_failure.severity
  query                                     = local.log_search_alert_rule_load_balancer_health_probe_failure.query
  time_aggregation_method                   = local.log_search_alert_rule_load_balancer_health_probe_failure.time_aggregation_method
  threshold                                 = local.log_search_alert_rule_load_balancer_health_probe_failure.threshold
  operator                                  = local.log_search_alert_rule_load_balancer_health_probe_failure.operator
  resource_id_column                        = local.log_search_alert_rule_load_balancer_health_probe_failure.resource_id_column
  metric_measure_column                     = local.log_search_alert_rule_load_balancer_health_probe_failure.metric_measure_column
  dimension_name                            = local.log_search_alert_rule_load_balancer_health_probe_failure.dimension_name
  dimension_operator                        = local.log_search_alert_rule_load_balancer_health_probe_failure.dimension_operator
  dimension_values                          = local.log_search_alert_rule_load_balancer_health_probe_failure.dimension_values
  minimum_failing_periods_to_trigger_alert = local.log_search_alert_rule_load_balancer_health_probe_failure.minimum_failing_periods_to_trigger_alert
  number_of_evaluation_periods              = local.log_search_alert_rule_load_balancer_health_probe_failure.number_of_evaluation_periods
  auto_mitigation_enabled                   = local.log_search_alert_rule_load_balancer_health_probe_failure.auto_mitigation_enabled
  workspace_alerts_storage_enabled          = local.log_search_alert_rule_load_balancer_health_probe_failure.workspace_alerts_storage_enabled
  description                               = local.log_search_alert_rule_load_balancer_health_probe_failure.description
  display_name                              = local.log_search_alert_rule_load_balancer_health_probe_failure.display_name
  enabled                                   = local.log_search_alert_rule_load_balancer_health_probe_failure.enabled
  query_time_range_override                 = local.log_search_alert_rule_load_balancer_health_probe_failure.query_time_range_override
  skip_query_validation                     = local.log_search_alert_rule_load_balancer_health_probe_failure.skip_query_validation
  action_groups                             = local.log_search_alert_rule_load_balancer_health_probe_failure.action_groups
  custom_properties                         = local.log_search_alert_rule_load_balancer_health_probe_failure.custom_properties
  identity_type                             = local.log_search_alert_rule_load_balancer_health_probe_failure.identity_type
  identity_ids                              = local.log_search_alert_rule_load_balancer_health_probe_failure.identity_ids
  tags                                      = local.log_search_alert_rule_load_balancer_health_probe_failure.tags
}

module "log_search_alert_rule_node_not_ready" {
  source = "./modules/log_search_alert_rule"
  
  name                                      = local.log_search_alert_rule_node_not_ready.name
  resource_group_name                       = local.log_search_alert_rule_node_not_ready.resource_group_name
  location                                  = local.log_search_alert_rule_node_not_ready.location
  evaluation_frequency                      = local.log_search_alert_rule_node_not_ready.evaluation_frequency
  window_duration                           = local.log_search_alert_rule_node_not_ready.window_duration
  scopes                                    = local.log_search_alert_rule_node_not_ready.scopes
  severity                                  = local.log_search_alert_rule_node_not_ready.severity
  query                                     = local.log_search_alert_rule_node_not_ready.query
  time_aggregation_method                   = local.log_search_alert_rule_node_not_ready.time_aggregation_method
  threshold                                 = local.log_search_alert_rule_node_not_ready.threshold
  operator                                  = local.log_search_alert_rule_node_not_ready.operator
  resource_id_column                        = local.log_search_alert_rule_node_not_ready.resource_id_column
  metric_measure_column                     = local.log_search_alert_rule_node_not_ready.metric_measure_column
  dimension_name                            = local.log_search_alert_rule_node_not_ready.dimension_name
  dimension_operator                        = local.log_search_alert_rule_node_not_ready.dimension_operator
  dimension_values                          = local.log_search_alert_rule_node_not_ready.dimension_values
  minimum_failing_periods_to_trigger_alert = local.log_search_alert_rule_node_not_ready.minimum_failing_periods_to_trigger_alert
  number_of_evaluation_periods              = local.log_search_alert_rule_node_not_ready.number_of_evaluation_periods
  auto_mitigation_enabled                   = local.log_search_alert_rule_node_not_ready.auto_mitigation_enabled
  workspace_alerts_storage_enabled          = local.log_search_alert_rule_node_not_ready.workspace_alerts_storage_enabled
  description                               = local.log_search_alert_rule_node_not_ready.description
  display_name                              = local.log_search_alert_rule_node_not_ready.display_name
  enabled                                   = local.log_search_alert_rule_node_not_ready.enabled
  query_time_range_override                 = local.log_search_alert_rule_node_not_ready.query_time_range_override
  skip_query_validation                     = local.log_search_alert_rule_node_not_ready.skip_query_validation
  action_groups                             = local.log_search_alert_rule_node_not_ready.action_groups
  custom_properties                         = local.log_search_alert_rule_node_not_ready.custom_properties
  identity_type                             = local.log_search_alert_rule_node_not_ready.identity_type
  identity_ids                              = local.log_search_alert_rule_node_not_ready.identity_ids
  tags                                      = local.log_search_alert_rule_node_not_ready.tags
}

module "log_search_alert_rule_network_security_group_rule_hit_count" {
  source = "./modules/log_search_alert_rule"
  
  name                                      = local.log_search_alert_rule_network_security_group_rule_hit_count.name
  resource_group_name                       = local.log_search_alert_rule_network_security_group_rule_hit_count.resource_group_name
  location                                  = local.log_search_alert_rule_network_security_group_rule_hit_count.location
  evaluation_frequency                      = local.log_search_alert_rule_network_security_group_rule_hit_count.evaluation_frequency
  window_duration                           = local.log_search_alert_rule_network_security_group_rule_hit_count.window_duration
  scopes                                    = local.log_search_alert_rule_network_security_group_rule_hit_count.scopes
  severity                                  = local.log_search_alert_rule_network_security_group_rule_hit_count.severity
  query                                     = local.log_search_alert_rule_network_security_group_rule_hit_count.query
  time_aggregation_method                   = local.log_search_alert_rule_network_security_group_rule_hit_count.time_aggregation_method
  threshold                                 = local.log_search_alert_rule_network_security_group_rule_hit_count.threshold
  operator                                  = local.log_search_alert_rule_network_security_group_rule_hit_count.operator
  resource_id_column                        = local.log_search_alert_rule_network_security_group_rule_hit_count.resource_id_column
  metric_measure_column                     = local.log_search_alert_rule_network_security_group_rule_hit_count.metric_measure_column
  dimension_name                            = local.log_search_alert_rule_network_security_group_rule_hit_count.dimension_name
  dimension_operator                        = local.log_search_alert_rule_network_security_group_rule_hit_count.dimension_operator
  dimension_values                          = local.log_search_alert_rule_network_security_group_rule_hit_count.dimension_values
  minimum_failing_periods_to_trigger_alert = local.log_search_alert_rule_network_security_group_rule_hit_count.minimum_failing_periods_to_trigger_alert
  number_of_evaluation_periods              = local.log_search_alert_rule_network_security_group_rule_hit_count.number_of_evaluation_periods
  auto_mitigation_enabled                   = local.log_search_alert_rule_network_security_group_rule_hit_count.auto_mitigation_enabled
  workspace_alerts_storage_enabled          = local.log_search_alert_rule_network_security_group_rule_hit_count.workspace_alerts_storage_enabled
  description                               = local.log_search_alert_rule_network_security_group_rule_hit_count.description
  display_name                              = local.log_search_alert_rule_network_security_group_rule_hit_count.display_name
  enabled                                   = local.log_search_alert_rule_network_security_group_rule_hit_count.enabled
  query_time_range_override                 = local.log_search_alert_rule_network_security_group_rule_hit_count.query_time_range_override
  skip_query_validation                     = local.log_search_alert_rule_network_security_group_rule_hit_count.skip_query_validation
  action_groups                             = local.log_search_alert_rule_network_security_group_rule_hit_count.action_groups
  custom_properties                         = local.log_search_alert_rule_network_security_group_rule_hit_count.custom_properties
  identity_type                             = local.log_search_alert_rule_network_security_group_rule_hit_count.identity_type
  identity_ids                              = local.log_search_alert_rule_network_security_group_rule_hit_count.identity_ids
  tags                                      = local.log_search_alert_rule_network_security_group_rule_hit_count.tags
}

module "log_search_alert_rule_secret_expiry_imminent" {
  source = "./modules/log_search_alert_rule"
  
  name                                      = local.log_search_alert_rule_secret_expiry_imminent.name
  resource_group_name                       = local.log_search_alert_rule_secret_expiry_imminent.resource_group_name
  location                                  = local.log_search_alert_rule_secret_expiry_imminent.location
  evaluation_frequency                      = local.log_search_alert_rule_secret_expiry_imminent.evaluation_frequency
  window_duration                           = local.log_search_alert_rule_secret_expiry_imminent.window_duration
  scopes                                    = local.log_search_alert_rule_secret_expiry_imminent.scopes
  severity                                  = local.log_search_alert_rule_secret_expiry_imminent.severity
  query                                     = local.log_search_alert_rule_secret_expiry_imminent.query
  time_aggregation_method                   = local.log_search_alert_rule_secret_expiry_imminent.time_aggregation_method
  threshold                                 = local.log_search_alert_rule_secret_expiry_imminent.threshold
  operator                                  = local.log_search_alert_rule_secret_expiry_imminent.operator
  resource_id_column                        = local.log_search_alert_rule_secret_expiry_imminent.resource_id_column
  metric_measure_column                     = local.log_search_alert_rule_secret_expiry_imminent.metric_measure_column
  dimension_name                            = local.log_search_alert_rule_secret_expiry_imminent.dimension_name
  dimension_operator                        = local.log_search_alert_rule_secret_expiry_imminent.dimension_operator
  dimension_values                          = local.log_search_alert_rule_secret_expiry_imminent.dimension_values
  minimum_failing_periods_to_trigger_alert = local.log_search_alert_rule_secret_expiry_imminent.minimum_failing_periods_to_trigger_alert
  number_of_evaluation_periods              = local.log_search_alert_rule_secret_expiry_imminent.number_of_evaluation_periods
  auto_mitigation_enabled                   = local.log_search_alert_rule_secret_expiry_imminent.auto_mitigation_enabled
  workspace_alerts_storage_enabled          = local.log_search_alert_rule_secret_expiry_imminent.workspace_alerts_storage_enabled
  description                               = local.log_search_alert_rule_secret_expiry_imminent.description
  display_name                              = local.log_search_alert_rule_secret_expiry_imminent.display_name
  enabled                                   = local.log_search_alert_rule_secret_expiry_imminent.enabled
  query_time_range_override                 = local.log_search_alert_rule_secret_expiry_imminent.query_time_range_override
  skip_query_validation                     = local.log_search_alert_rule_secret_expiry_imminent.skip_query_validation
  action_groups                             = local.log_search_alert_rule_secret_expiry_imminent.action_groups
  custom_properties                         = local.log_search_alert_rule_secret_expiry_imminent.custom_properties
  identity_type                             = local.log_search_alert_rule_secret_expiry_imminent.identity_type
  identity_ids                              = local.log_search_alert_rule_secret_expiry_imminent.identity_ids
  tags                                      = local.log_search_alert_rule_secret_expiry_imminent.tags
}

module "log_search_alert_rule_networking_services_health_status_degraded" {
  source = "./modules/log_search_alert_rule"
  
  name                                      = local.log_search_alert_rule_networking_services_health_status_degraded.name
  resource_group_name                       = local.log_search_alert_rule_networking_services_health_status_degraded.resource_group_name
  location                                  = local.log_search_alert_rule_networking_services_health_status_degraded.location
  evaluation_frequency                      = local.log_search_alert_rule_networking_services_health_status_degraded.evaluation_frequency
  window_duration                           = local.log_search_alert_rule_networking_services_health_status_degraded.window_duration
  scopes                                    = local.log_search_alert_rule_networking_services_health_status_degraded.scopes
  severity                                  = local.log_search_alert_rule_networking_services_health_status_degraded.severity
  query                                     = local.log_search_alert_rule_networking_services_health_status_degraded.query
  time_aggregation_method                   = local.log_search_alert_rule_networking_services_health_status_degraded.time_aggregation_method
  threshold                                 = local.log_search_alert_rule_networking_services_health_status_degraded.threshold
  operator                                  = local.log_search_alert_rule_networking_services_health_status_degraded.operator
  resource_id_column                        = local.log_search_alert_rule_networking_services_health_status_degraded.resource_id_column
  metric_measure_column                     = local.log_search_alert_rule_networking_services_health_status_degraded.metric_measure_column
  dimension_name                            = local.log_search_alert_rule_networking_services_health_status_degraded.dimension_name
  dimension_operator                        = local.log_search_alert_rule_networking_services_health_status_degraded.dimension_operator
  dimension_values                          = local.log_search_alert_rule_networking_services_health_status_degraded.dimension_values
  minimum_failing_periods_to_trigger_alert = local.log_search_alert_rule_networking_services_health_status_degraded.minimum_failing_periods_to_trigger_alert
  number_of_evaluation_periods              = local.log_search_alert_rule_networking_services_health_status_degraded.number_of_evaluation_periods
  auto_mitigation_enabled                   = local.log_search_alert_rule_networking_services_health_status_degraded.auto_mitigation_enabled
  workspace_alerts_storage_enabled          = local.log_search_alert_rule_networking_services_health_status_degraded.workspace_alerts_storage_enabled
  description                               = local.log_search_alert_rule_networking_services_health_status_degraded.description
  display_name                              = local.log_search_alert_rule_networking_services_health_status_degraded.display_name
  enabled                                   = local.log_search_alert_rule_networking_services_health_status_degraded.enabled
  query_time_range_override                 = local.log_search_alert_rule_networking_services_health_status_degraded.query_time_range_override
  skip_query_validation                     = local.log_search_alert_rule_networking_services_health_status_degraded.skip_query_validation
  action_groups                             = local.log_search_alert_rule_networking_services_health_status_degraded.action_groups
  custom_properties                         = local.log_search_alert_rule_networking_services_health_status_degraded.custom_properties
  identity_type                             = local.log_search_alert_rule_networking_services_health_status_degraded.identity_type
  identity_ids                              = local.log_search_alert_rule_networking_services_health_status_degraded.identity_ids
  tags                                      = local.log_search_alert_rule_networking_services_health_status_degraded.tags
}


module "log_search_alert_rule_memory_utilization_high_node_pod" {
  source = "./modules/log_search_alert_rule"
  
  name                                      = local.log_search_alert_rule_memory_utilization_high_node_pod.name
  resource_group_name                       = local.log_search_alert_rule_memory_utilization_high_node_pod.resource_group_name
  location                                  = local.log_search_alert_rule_memory_utilization_high_node_pod.location
  evaluation_frequency                      = local.log_search_alert_rule_memory_utilization_high_node_pod.evaluation_frequency
  window_duration                           = local.log_search_alert_rule_memory_utilization_high_node_pod.window_duration
  scopes                                    = local.log_search_alert_rule_memory_utilization_high_node_pod.scopes
  severity                                  = local.log_search_alert_rule_memory_utilization_high_node_pod.severity
  query                                     = local.log_search_alert_rule_memory_utilization_high_node_pod.query
  time_aggregation_method                   = local.log_search_alert_rule_memory_utilization_high_node_pod.time_aggregation_method
  threshold                                 = local.log_search_alert_rule_memory_utilization_high_node_pod.threshold
  operator                                  = local.log_search_alert_rule_memory_utilization_high_node_pod.operator
  resource_id_column                        = local.log_search_alert_rule_memory_utilization_high_node_pod.resource_id_column
  metric_measure_column                     = local.log_search_alert_rule_memory_utilization_high_node_pod.metric_measure_column
  dimension_name                            = local.log_search_alert_rule_memory_utilization_high_node_pod.dimension_name
  dimension_operator                        = local.log_search_alert_rule_memory_utilization_high_node_pod.dimension_operator
  dimension_values                          = local.log_search_alert_rule_memory_utilization_high_node_pod.dimension_values
  minimum_failing_periods_to_trigger_alert = local.log_search_alert_rule_memory_utilization_high_node_pod.minimum_failing_periods_to_trigger_alert
  number_of_evaluation_periods              = local.log_search_alert_rule_memory_utilization_high_node_pod.number_of_evaluation_periods
  auto_mitigation_enabled                   = local.log_search_alert_rule_memory_utilization_high_node_pod.auto_mitigation_enabled
  workspace_alerts_storage_enabled          = local.log_search_alert_rule_memory_utilization_high_node_pod.workspace_alerts_storage_enabled
  description                               = local.log_search_alert_rule_memory_utilization_high_node_pod.description
  display_name                              = local.log_search_alert_rule_memory_utilization_high_node_pod.display_name
  enabled                                   = local.log_search_alert_rule_memory_utilization_high_node_pod.enabled
  query_time_range_override                 = local.log_search_alert_rule_memory_utilization_high_node_pod.query_time_range_override
  skip_query_validation                     = local.log_search_alert_rule_memory_utilization_high_node_pod.skip_query_validation
  action_groups                             = local.log_search_alert_rule_memory_utilization_high_node_pod.action_groups
  custom_properties                         = local.log_search_alert_rule_memory_utilization_high_node_pod.custom_properties
  identity_type                             = local.log_search_alert_rule_memory_utilization_high_node_pod.identity_type
  identity_ids                              = local.log_search_alert_rule_memory_utilization_high_node_pod.identity_ids
  tags                                      = local.log_search_alert_rule_memory_utilization_high_node_pod.tags
}

module "log_search_alert_rule_networking_services_health_status" {
  source = "./modules/log_search_alert_rule"
  
  name                                      = local.log_search_alert_rule_networking_services_health_status.name
  resource_group_name                       = local.log_search_alert_rule_networking_services_health_status.resource_group_name
  location                                  = local.log_search_alert_rule_networking_services_health_status.location
  evaluation_frequency                      = local.log_search_alert_rule_networking_services_health_status.evaluation_frequency
  window_duration                           = local.log_search_alert_rule_networking_services_health_status.window_duration
  scopes                                    = local.log_search_alert_rule_networking_services_health_status.scopes
  severity                                  = local.log_search_alert_rule_networking_services_health_status.severity
  query                                     = local.log_search_alert_rule_networking_services_health_status.query
  time_aggregation_method                   = local.log_search_alert_rule_networking_services_health_status.time_aggregation_method
  threshold                                 = local.log_search_alert_rule_networking_services_health_status.threshold
  operator                                  = local.log_search_alert_rule_networking_services_health_status.operator
  resource_id_column                        = local.log_search_alert_rule_networking_services_health_status.resource_id_column
  metric_measure_column                     = local.log_search_alert_rule_networking_services_health_status.metric_measure_column
  dimension_name                            = local.log_search_alert_rule_networking_services_health_status.dimension_name
  dimension_operator                        = local.log_search_alert_rule_networking_services_health_status.dimension_operator
  dimension_values                          = local.log_search_alert_rule_networking_services_health_status.dimension_values
  minimum_failing_periods_to_trigger_alert = local.log_search_alert_rule_networking_services_health_status.minimum_failing_periods_to_trigger_alert
  number_of_evaluation_periods              = local.log_search_alert_rule_networking_services_health_status.number_of_evaluation_periods
  auto_mitigation_enabled                   = local.log_search_alert_rule_networking_services_health_status.auto_mitigation_enabled
  workspace_alerts_storage_enabled          = local.log_search_alert_rule_networking_services_health_status.workspace_alerts_storage_enabled
  description                               = local.log_search_alert_rule_networking_services_health_status.description
  display_name                              = local.log_search_alert_rule_networking_services_health_status.display_name
  enabled                                   = local.log_search_alert_rule_networking_services_health_status.enabled
  query_time_range_override                 = local.log_search_alert_rule_networking_services_health_status.query_time_range_override
  skip_query_validation                     = local.log_search_alert_rule_networking_services_health_status.skip_query_validation
  action_groups                             = local.log_search_alert_rule_networking_services_health_status.action_groups
  custom_properties                         = local.log_search_alert_rule_networking_services_health_status.custom_properties
  identity_type                             = local.log_search_alert_rule_networking_services_health_status.identity_type
  identity_ids                              = local.log_search_alert_rule_networking_services_health_status.identity_ids
  tags                                      = local.log_search_alert_rule_networking_services_health_status.tags
}

module "log_search_alert_rule_networking_services_health_status_02" {
  source = "./modules/log_search_alert_rule"
  
  name                                      = local.log_search_alert_rule_networking_services_health_status_02.name
  resource_group_name                       = local.log_search_alert_rule_networking_services_health_status_02.resource_group_name
  location                                  = local.log_search_alert_rule_networking_services_health_status_02.location
  evaluation_frequency                      = local.log_search_alert_rule_networking_services_health_status_02.evaluation_frequency
  window_duration                           = local.log_search_alert_rule_networking_services_health_status_02.window_duration
  scopes                                    = local.log_search_alert_rule_networking_services_health_status_02.scopes
  severity                                  = local.log_search_alert_rule_networking_services_health_status_02.severity
  query                                     = local.log_search_alert_rule_networking_services_health_status_02.query
  time_aggregation_method                   = local.log_search_alert_rule_networking_services_health_status_02.time_aggregation_method
  threshold                                 = local.log_search_alert_rule_networking_services_health_status_02.threshold
  operator                                  = local.log_search_alert_rule_networking_services_health_status_02.operator
  resource_id_column                        = local.log_search_alert_rule_networking_services_health_status_02.resource_id_column
  metric_measure_column                     = local.log_search_alert_rule_networking_services_health_status_02.metric_measure_column
  dimension_name                            = local.log_search_alert_rule_networking_services_health_status_02.dimension_name
  dimension_operator                        = local.log_search_alert_rule_networking_services_health_status_02.dimension_operator
  dimension_values                          = local.log_search_alert_rule_networking_services_health_status_02.dimension_values
  minimum_failing_periods_to_trigger_alert = local.log_search_alert_rule_networking_services_health_status_02.minimum_failing_periods_to_trigger_alert
  number_of_evaluation_periods              = local.log_search_alert_rule_networking_services_health_status_02.number_of_evaluation_periods
  auto_mitigation_enabled                   = local.log_search_alert_rule_networking_services_health_status_02.auto_mitigation_enabled
  workspace_alerts_storage_enabled          = local.log_search_alert_rule_networking_services_health_status_02.workspace_alerts_storage_enabled
  description                               = local.log_search_alert_rule_networking_services_health_status_02.description
  display_name                              = local.log_search_alert_rule_networking_services_health_status_02.display_name
  enabled                                   = local.log_search_alert_rule_networking_services_health_status_02.enabled
  query_time_range_override                 = local.log_search_alert_rule_networking_services_health_status_02.query_time_range_override
  skip_query_validation                     = local.log_search_alert_rule_networking_services_health_status_02.skip_query_validation
  action_groups                             = local.log_search_alert_rule_networking_services_health_status_02.action_groups
  custom_properties                         = local.log_search_alert_rule_networking_services_health_status_02.custom_properties
  identity_type                             = local.log_search_alert_rule_networking_services_health_status_02.identity_type
  identity_ids                              = local.log_search_alert_rule_networking_services_health_status_02.identity_ids
  tags                                      = local.log_search_alert_rule_networking_services_health_status_02.tags
}

module "log_search_alert_rule_public_ip_address_change" {
  source = "./modules/log_search_alert_rule"
  
  name                                      = local.log_search_alert_rule_public_ip_address_change.name
  resource_group_name                       = local.log_search_alert_rule_public_ip_address_change.resource_group_name
  location                                  = local.log_search_alert_rule_public_ip_address_change.location
  evaluation_frequency                      = local.log_search_alert_rule_public_ip_address_change.evaluation_frequency
  window_duration                           = local.log_search_alert_rule_public_ip_address_change.window_duration
  scopes                                    = local.log_search_alert_rule_public_ip_address_change.scopes
  severity                                  = local.log_search_alert_rule_public_ip_address_change.severity
  query                                     = local.log_search_alert_rule_public_ip_address_change.query
  time_aggregation_method                   = local.log_search_alert_rule_public_ip_address_change.time_aggregation_method
  threshold                                 = local.log_search_alert_rule_public_ip_address_change.threshold
  operator                                  = local.log_search_alert_rule_public_ip_address_change.operator
  resource_id_column                        = local.log_search_alert_rule_public_ip_address_change.resource_id_column
  metric_measure_column                     = local.log_search_alert_rule_public_ip_address_change.metric_measure_column
  dimension_name                            = local.log_search_alert_rule_public_ip_address_change.dimension_name
  dimension_operator                        = local.log_search_alert_rule_public_ip_address_change.dimension_operator
  dimension_values                          = local.log_search_alert_rule_public_ip_address_change.dimension_values
  minimum_failing_periods_to_trigger_alert = local.log_search_alert_rule_public_ip_address_change.minimum_failing_periods_to_trigger_alert
  number_of_evaluation_periods              = local.log_search_alert_rule_public_ip_address_change.number_of_evaluation_periods
  auto_mitigation_enabled                   = local.log_search_alert_rule_public_ip_address_change.auto_mitigation_enabled
  workspace_alerts_storage_enabled          = local.log_search_alert_rule_public_ip_address_change.workspace_alerts_storage_enabled
  description                               = local.log_search_alert_rule_public_ip_address_change.description
  display_name                              = local.log_search_alert_rule_public_ip_address_change.display_name
  enabled                                   = local.log_search_alert_rule_public_ip_address_change.enabled
  query_time_range_override                 = local.log_search_alert_rule_public_ip_address_change.query_time_range_override
  skip_query_validation                     = local.log_search_alert_rule_public_ip_address_change.skip_query_validation
  action_groups                             = local.log_search_alert_rule_public_ip_address_change.action_groups
  custom_properties                         = local.log_search_alert_rule_public_ip_address_change.custom_properties
  identity_type                             = local.log_search_alert_rule_public_ip_address_change.identity_type
  identity_ids                              = local.log_search_alert_rule_public_ip_address_change.identity_ids
  tags                                      = local.log_search_alert_rule_public_ip_address_change.tags
}

module "log_search_alert_rule_public_ip_address_change_02" {
  source = "./modules/log_search_alert_rule"
  
  name                                      = local.log_search_alert_rule_public_ip_address_change_02.name
  resource_group_name                       = local.log_search_alert_rule_public_ip_address_change_02.resource_group_name
  location                                  = local.log_search_alert_rule_public_ip_address_change_02.location
  evaluation_frequency                      = local.log_search_alert_rule_public_ip_address_change_02.evaluation_frequency
  window_duration                           = local.log_search_alert_rule_public_ip_address_change_02.window_duration
  scopes                                    = local.log_search_alert_rule_public_ip_address_change_02.scopes
  severity                                  = local.log_search_alert_rule_public_ip_address_change_02.severity
  query                                     = local.log_search_alert_rule_public_ip_address_change_02.query
  time_aggregation_method                   = local.log_search_alert_rule_public_ip_address_change_02.time_aggregation_method
  threshold                                 = local.log_search_alert_rule_public_ip_address_change_02.threshold
  operator                                  = local.log_search_alert_rule_public_ip_address_change_02.operator
  resource_id_column                        = local.log_search_alert_rule_public_ip_address_change_02.resource_id_column
  metric_measure_column                     = local.log_search_alert_rule_public_ip_address_change_02.metric_measure_column
  dimension_name                            = local.log_search_alert_rule_public_ip_address_change_02.dimension_name
  dimension_operator                        = local.log_search_alert_rule_public_ip_address_change_02.dimension_operator
  dimension_values                          = local.log_search_alert_rule_public_ip_address_change_02.dimension_values
  minimum_failing_periods_to_trigger_alert = local.log_search_alert_rule_public_ip_address_change_02.minimum_failing_periods_to_trigger_alert
  number_of_evaluation_periods              = local.log_search_alert_rule_public_ip_address_change_02.number_of_evaluation_periods
  auto_mitigation_enabled                   = local.log_search_alert_rule_public_ip_address_change_02.auto_mitigation_enabled
  workspace_alerts_storage_enabled          = local.log_search_alert_rule_public_ip_address_change_02.workspace_alerts_storage_enabled
  description                               = local.log_search_alert_rule_public_ip_address_change_02.description
  display_name                              = local.log_search_alert_rule_public_ip_address_change_02.display_name
  enabled                                   = local.log_search_alert_rule_public_ip_address_change_02.enabled
  query_time_range_override                 = local.log_search_alert_rule_public_ip_address_change_02.query_time_range_override
  skip_query_validation                     = local.log_search_alert_rule_public_ip_address_change_02.skip_query_validation
  action_groups                             = local.log_search_alert_rule_public_ip_address_change_02.action_groups
  custom_properties                         = local.log_search_alert_rule_public_ip_address_change_02.custom_properties
  identity_type                             = local.log_search_alert_rule_public_ip_address_change_02.identity_type
  identity_ids                              = local.log_search_alert_rule_public_ip_address_change_02.identity_ids
  tags                                      = local.log_search_alert_rule_public_ip_address_change_02.tags
}

module "log_search_alert_rule_networking_services_health_status_unavailable" {
  source = "./modules/log_search_alert_rule"
  
  name                                      = local.log_search_alert_rule_networking_services_health_status_unavailable.name
  resource_group_name                       = local.log_search_alert_rule_networking_services_health_status_unavailable.resource_group_name
  location                                  = local.log_search_alert_rule_networking_services_health_status_unavailable.location
  evaluation_frequency                      = local.log_search_alert_rule_networking_services_health_status_unavailable.evaluation_frequency
  window_duration                           = local.log_search_alert_rule_networking_services_health_status_unavailable.window_duration
  scopes                                    = local.log_search_alert_rule_networking_services_health_status_unavailable.scopes
  severity                                  = local.log_search_alert_rule_networking_services_health_status_unavailable.severity
  query                                     = local.log_search_alert_rule_networking_services_health_status_unavailable.query
  time_aggregation_method                   = local.log_search_alert_rule_networking_services_health_status_unavailable.time_aggregation_method
  threshold                                 = local.log_search_alert_rule_networking_services_health_status_unavailable.threshold
  operator                                  = local.log_search_alert_rule_networking_services_health_status_unavailable.operator
  resource_id_column                        = local.log_search_alert_rule_networking_services_health_status_unavailable.resource_id_column
  metric_measure_column                     = local.log_search_alert_rule_networking_services_health_status_unavailable.metric_measure_column
  dimension_name                            = local.log_search_alert_rule_networking_services_health_status_unavailable.dimension_name
  dimension_operator                        = local.log_search_alert_rule_networking_services_health_status_unavailable.dimension_operator
  dimension_values                          = local.log_search_alert_rule_networking_services_health_status_unavailable.dimension_values
  minimum_failing_periods_to_trigger_alert = local.log_search_alert_rule_networking_services_health_status_unavailable.minimum_failing_periods_to_trigger_alert
  number_of_evaluation_periods              = local.log_search_alert_rule_networking_services_health_status_unavailable.number_of_evaluation_periods
  auto_mitigation_enabled                   = local.log_search_alert_rule_networking_services_health_status_unavailable.auto_mitigation_enabled
  workspace_alerts_storage_enabled          = local.log_search_alert_rule_networking_services_health_status_unavailable.workspace_alerts_storage_enabled
  description                               = local.log_search_alert_rule_networking_services_health_status_unavailable.description
  display_name                              = local.log_search_alert_rule_networking_services_health_status_unavailable.display_name
  enabled                                   = local.log_search_alert_rule_networking_services_health_status_unavailable.enabled
  query_time_range_override                 = local.log_search_alert_rule_networking_services_health_status_unavailable.query_time_range_override
  skip_query_validation                     = local.log_search_alert_rule_networking_services_health_status_unavailable.skip_query_validation
  action_groups                             = local.log_search_alert_rule_networking_services_health_status_unavailable.action_groups
  custom_properties                         = local.log_search_alert_rule_networking_services_health_status_unavailable.custom_properties
  identity_type                             = local.log_search_alert_rule_networking_services_health_status_unavailable.identity_type
  identity_ids                              = local.log_search_alert_rule_networking_services_health_status_unavailable.identity_ids
  tags                                      = local.log_search_alert_rule_networking_services_health_status_unavailable.tags
}


module "log_search_alert_rule_subnet_change" {
  source = "./modules/log_search_alert_rule"
  
  name                                      = local.log_search_alert_rule_subnet_change.name
  resource_group_name                       = local.log_search_alert_rule_subnet_change.resource_group_name
  location                                  = local.log_search_alert_rule_subnet_change.location
  evaluation_frequency                      = local.log_search_alert_rule_subnet_change.evaluation_frequency
  window_duration                           = local.log_search_alert_rule_subnet_change.window_duration
  scopes                                    = local.log_search_alert_rule_subnet_change.scopes
  severity                                  = local.log_search_alert_rule_subnet_change.severity
  query                                     = local.log_search_alert_rule_subnet_change.query
  time_aggregation_method                   = local.log_search_alert_rule_subnet_change.time_aggregation_method
  threshold                                 = local.log_search_alert_rule_subnet_change.threshold
  operator                                  = local.log_search_alert_rule_subnet_change.operator
  resource_id_column                        = local.log_search_alert_rule_subnet_change.resource_id_column
  metric_measure_column                     = local.log_search_alert_rule_subnet_change.metric_measure_column
  dimension_name                            = local.log_search_alert_rule_subnet_change.dimension_name
  dimension_operator                        = local.log_search_alert_rule_subnet_change.dimension_operator
  dimension_values                          = local.log_search_alert_rule_subnet_change.dimension_values
  minimum_failing_periods_to_trigger_alert = local.log_search_alert_rule_subnet_change.minimum_failing_periods_to_trigger_alert
  number_of_evaluation_periods              = local.log_search_alert_rule_subnet_change.number_of_evaluation_periods
  auto_mitigation_enabled                   = local.log_search_alert_rule_subnet_change.auto_mitigation_enabled
  workspace_alerts_storage_enabled          = local.log_search_alert_rule_subnet_change.workspace_alerts_storage_enabled
  description                               = local.log_search_alert_rule_subnet_change.description
  display_name                              = local.log_search_alert_rule_subnet_change.display_name
  enabled                                   = local.log_search_alert_rule_subnet_change.enabled
  query_time_range_override                 = local.log_search_alert_rule_subnet_change.query_time_range_override
  skip_query_validation                     = local.log_search_alert_rule_subnet_change.skip_query_validation
  action_groups                             = local.log_search_alert_rule_subnet_change.action_groups
  custom_properties                         = local.log_search_alert_rule_subnet_change.custom_properties
  identity_type                             = local.log_search_alert_rule_subnet_change.identity_type
  identity_ids                              = local.log_search_alert_rule_subnet_change.identity_ids
  tags                                      = local.log_search_alert_rule_subnet_change.tags
}

module "log_search_alert_rule_subnet_change_02" {
  source = "./modules/log_search_alert_rule"
  
  name                                      = local.log_search_alert_rule_subnet_change_02.name
  resource_group_name                       = local.log_search_alert_rule_subnet_change_02.resource_group_name
  location                                  = local.log_search_alert_rule_subnet_change_02.location
  evaluation_frequency                      = local.log_search_alert_rule_subnet_change_02.evaluation_frequency
  window_duration                           = local.log_search_alert_rule_subnet_change_02.window_duration
  scopes                                    = local.log_search_alert_rule_subnet_change_02.scopes
  severity                                  = local.log_search_alert_rule_subnet_change_02.severity
  query                                     = local.log_search_alert_rule_subnet_change_02.query
  time_aggregation_method                   = local.log_search_alert_rule_subnet_change_02.time_aggregation_method
  threshold                                 = local.log_search_alert_rule_subnet_change_02.threshold
  operator                                  = local.log_search_alert_rule_subnet_change_02.operator
  resource_id_column                        = local.log_search_alert_rule_subnet_change_02.resource_id_column
  metric_measure_column                     = local.log_search_alert_rule_subnet_change_02.metric_measure_column
  dimension_name                            = local.log_search_alert_rule_subnet_change_02.dimension_name
  dimension_operator                        = local.log_search_alert_rule_subnet_change_02.dimension_operator
  dimension_values                          = local.log_search_alert_rule_subnet_change_02.dimension_values
  minimum_failing_periods_to_trigger_alert = local.log_search_alert_rule_subnet_change_02.minimum_failing_periods_to_trigger_alert
  number_of_evaluation_periods              = local.log_search_alert_rule_subnet_change_02.number_of_evaluation_periods
  auto_mitigation_enabled                   = local.log_search_alert_rule_subnet_change_02.auto_mitigation_enabled
  workspace_alerts_storage_enabled          = local.log_search_alert_rule_subnet_change_02.workspace_alerts_storage_enabled
  description                               = local.log_search_alert_rule_subnet_change_02.description
  display_name                              = local.log_search_alert_rule_subnet_change_02.display_name
  enabled                                   = local.log_search_alert_rule_subnet_change_02.enabled
  query_time_range_override                 = local.log_search_alert_rule_subnet_change_02.query_time_range_override
  skip_query_validation                     = local.log_search_alert_rule_subnet_change_02.skip_query_validation
  action_groups                             = local.log_search_alert_rule_subnet_change_02.action_groups
  custom_properties                         = local.log_search_alert_rule_subnet_change_02.custom_properties
  identity_type                             = local.log_search_alert_rule_subnet_change_02.identity_type
  identity_ids                              = local.log_search_alert_rule_subnet_change_02.identity_ids
  tags                                      = local.log_search_alert_rule_subnet_change_02.tags
}

module "log_search_alert_rule_unauthorized_ip_access_attempt" {
  source = "./modules/log_search_alert_rule"
  
  name                                      = local.log_search_alert_rule_unauthorized_ip_access_attempt.name
  resource_group_name                       = local.log_search_alert_rule_unauthorized_ip_access_attempt.resource_group_name
  location                                  = local.log_search_alert_rule_unauthorized_ip_access_attempt.location
  evaluation_frequency                      = local.log_search_alert_rule_unauthorized_ip_access_attempt.evaluation_frequency
  window_duration                           = local.log_search_alert_rule_unauthorized_ip_access_attempt.window_duration
  scopes                                    = local.log_search_alert_rule_unauthorized_ip_access_attempt.scopes
  severity                                  = local.log_search_alert_rule_unauthorized_ip_access_attempt.severity
  query                                     = local.log_search_alert_rule_unauthorized_ip_access_attempt.query
  time_aggregation_method                   = local.log_search_alert_rule_unauthorized_ip_access_attempt.time_aggregation_method
  threshold                                 = local.log_search_alert_rule_unauthorized_ip_access_attempt.threshold
  operator                                  = local.log_search_alert_rule_unauthorized_ip_access_attempt.operator
  resource_id_column                        = local.log_search_alert_rule_unauthorized_ip_access_attempt.resource_id_column
  metric_measure_column                     = local.log_search_alert_rule_unauthorized_ip_access_attempt.metric_measure_column
  dimension_name                            = local.log_search_alert_rule_unauthorized_ip_access_attempt.dimension_name
  dimension_operator                        = local.log_search_alert_rule_unauthorized_ip_access_attempt.dimension_operator
  dimension_values                          = local.log_search_alert_rule_unauthorized_ip_access_attempt.dimension_values
  minimum_failing_periods_to_trigger_alert = local.log_search_alert_rule_unauthorized_ip_access_attempt.minimum_failing_periods_to_trigger_alert
  number_of_evaluation_periods              = local.log_search_alert_rule_unauthorized_ip_access_attempt.number_of_evaluation_periods
  auto_mitigation_enabled                   = local.log_search_alert_rule_unauthorized_ip_access_attempt.auto_mitigation_enabled
  workspace_alerts_storage_enabled          = local.log_search_alert_rule_unauthorized_ip_access_attempt.workspace_alerts_storage_enabled
  description                               = local.log_search_alert_rule_unauthorized_ip_access_attempt.description
  display_name                              = local.log_search_alert_rule_unauthorized_ip_access_attempt.display_name
  enabled                                   = local.log_search_alert_rule_unauthorized_ip_access_attempt.enabled
  query_time_range_override                 = local.log_search_alert_rule_unauthorized_ip_access_attempt.query_time_range_override
  skip_query_validation                     = local.log_search_alert_rule_unauthorized_ip_access_attempt.skip_query_validation
  action_groups                             = local.log_search_alert_rule_unauthorized_ip_access_attempt.action_groups
  custom_properties                         = local.log_search_alert_rule_unauthorized_ip_access_attempt.custom_properties
  identity_type                             = local.log_search_alert_rule_unauthorized_ip_access_attempt.identity_type
  identity_ids                              = local.log_search_alert_rule_unauthorized_ip_access_attempt.identity_ids
  tags                                      = local.log_search_alert_rule_unauthorized_ip_access_attempt.tags
}

module "log_search_alert_rule_vault_access_denied" {
  source = "./modules/log_search_alert_rule"
  
  name                                      = local.log_search_alert_rule_vault_access_denied.name
  resource_group_name                       = local.log_search_alert_rule_vault_access_denied.resource_group_name
  location                                  = local.log_search_alert_rule_vault_access_denied.location
  evaluation_frequency                      = local.log_search_alert_rule_vault_access_denied.evaluation_frequency
  window_duration                           = local.log_search_alert_rule_vault_access_denied.window_duration
  scopes                                    = local.log_search_alert_rule_vault_access_denied.scopes
  severity                                  = local.log_search_alert_rule_vault_access_denied.severity
  query                                     = local.log_search_alert_rule_vault_access_denied.query
  time_aggregation_method                   = local.log_search_alert_rule_vault_access_denied.time_aggregation_method
  threshold                                 = local.log_search_alert_rule_vault_access_denied.threshold
  operator                                  = local.log_search_alert_rule_vault_access_denied.operator
  resource_id_column                        = local.log_search_alert_rule_vault_access_denied.resource_id_column
  metric_measure_column                     = local.log_search_alert_rule_vault_access_denied.metric_measure_column
  dimension_name                            = local.log_search_alert_rule_vault_access_denied.dimension_name
  dimension_operator                        = local.log_search_alert_rule_vault_access_denied.dimension_operator
  dimension_values                          = local.log_search_alert_rule_vault_access_denied.dimension_values
  minimum_failing_periods_to_trigger_alert = local.log_search_alert_rule_vault_access_denied.minimum_failing_periods_to_trigger_alert
  number_of_evaluation_periods              = local.log_search_alert_rule_vault_access_denied.number_of_evaluation_periods
  auto_mitigation_enabled                   = local.log_search_alert_rule_vault_access_denied.auto_mitigation_enabled
  workspace_alerts_storage_enabled          = local.log_search_alert_rule_vault_access_denied.workspace_alerts_storage_enabled
  description                               = local.log_search_alert_rule_vault_access_denied.description
  display_name                              = local.log_search_alert_rule_vault_access_denied.display_name
  enabled                                   = local.log_search_alert_rule_vault_access_denied.enabled
  query_time_range_override                 = local.log_search_alert_rule_vault_access_denied.query_time_range_override
  skip_query_validation                     = local.log_search_alert_rule_vault_access_denied.skip_query_validation
  action_groups                             = local.log_search_alert_rule_vault_access_denied.action_groups
  custom_properties                         = local.log_search_alert_rule_vault_access_denied.custom_properties
  identity_type                             = local.log_search_alert_rule_vault_access_denied.identity_type
  identity_ids                              = local.log_search_alert_rule_vault_access_denied.identity_ids
  tags                                      = local.log_search_alert_rule_vault_access_denied.tags
}

module "log_search_alert_rule_vault_throttling_events" {
  source = "./modules/log_search_alert_rule"
  
  name                                      = local.log_search_alert_rule_vault_throttling_events.name
  resource_group_name                       = local.log_search_alert_rule_vault_throttling_events.resource_group_name
  location                                  = local.log_search_alert_rule_vault_throttling_events.location
  evaluation_frequency                      = local.log_search_alert_rule_vault_throttling_events.evaluation_frequency
  window_duration                           = local.log_search_alert_rule_vault_throttling_events.window_duration
  scopes                                    = local.log_search_alert_rule_vault_throttling_events.scopes
  severity                                  = local.log_search_alert_rule_vault_throttling_events.severity
  query                                     = local.log_search_alert_rule_vault_throttling_events.query
  time_aggregation_method                   = local.log_search_alert_rule_vault_throttling_events.time_aggregation_method
  threshold                                 = local.log_search_alert_rule_vault_throttling_events.threshold
  operator                                  = local.log_search_alert_rule_vault_throttling_events.operator
  resource_id_column                        = local.log_search_alert_rule_vault_throttling_events.resource_id_column
  metric_measure_column                     = local.log_search_alert_rule_vault_throttling_events.metric_measure_column
  dimension_name                            = local.log_search_alert_rule_vault_throttling_events.dimension_name
  dimension_operator                        = local.log_search_alert_rule_vault_throttling_events.dimension_operator
  dimension_values                          = local.log_search_alert_rule_vault_throttling_events.dimension_values
  minimum_failing_periods_to_trigger_alert = local.log_search_alert_rule_vault_throttling_events.minimum_failing_periods_to_trigger_alert
  number_of_evaluation_periods              = local.log_search_alert_rule_vault_throttling_events.number_of_evaluation_periods
  auto_mitigation_enabled                   = local.log_search_alert_rule_vault_throttling_events.auto_mitigation_enabled
  workspace_alerts_storage_enabled          = local.log_search_alert_rule_vault_throttling_events.workspace_alerts_storage_enabled
  description                               = local.log_search_alert_rule_vault_throttling_events.description
  display_name                              = local.log_search_alert_rule_vault_throttling_events.display_name
  enabled                                   = local.log_search_alert_rule_vault_throttling_events.enabled
  query_time_range_override                 = local.log_search_alert_rule_vault_throttling_events.query_time_range_override
  skip_query_validation                     = local.log_search_alert_rule_vault_throttling_events.skip_query_validation
  action_groups                             = local.log_search_alert_rule_vault_throttling_events.action_groups
  custom_properties                         = local.log_search_alert_rule_vault_throttling_events.custom_properties
  identity_type                             = local.log_search_alert_rule_vault_throttling_events.identity_type
  identity_ids                              = local.log_search_alert_rule_vault_throttling_events.identity_ids
  tags                                      = local.log_search_alert_rule_vault_throttling_events.tags
}

module "log_search_alert_rule_virtual_network_update_deletion" {
  source = "./modules/log_search_alert_rule"
  
  name                                      = local.log_search_alert_rule_virtual_network_update_deletion.name
  resource_group_name                       = local.log_search_alert_rule_virtual_network_update_deletion.resource_group_name
  location                                  = local.log_search_alert_rule_virtual_network_update_deletion.location
  evaluation_frequency                      = local.log_search_alert_rule_virtual_network_update_deletion.evaluation_frequency
  window_duration                           = local.log_search_alert_rule_virtual_network_update_deletion.window_duration
  scopes                                    = local.log_search_alert_rule_virtual_network_update_deletion.scopes
  severity                                  = local.log_search_alert_rule_virtual_network_update_deletion.severity
  query                                     = local.log_search_alert_rule_virtual_network_update_deletion.query
  time_aggregation_method                   = local.log_search_alert_rule_virtual_network_update_deletion.time_aggregation_method
  threshold                                 = local.log_search_alert_rule_virtual_network_update_deletion.threshold
  operator                                  = local.log_search_alert_rule_virtual_network_update_deletion.operator
  resource_id_column                        = local.log_search_alert_rule_virtual_network_update_deletion.resource_id_column
  metric_measure_column                     = local.log_search_alert_rule_virtual_network_update_deletion.metric_measure_column
  dimension_name                            = local.log_search_alert_rule_virtual_network_update_deletion.dimension_name
  dimension_operator                        = local.log_search_alert_rule_virtual_network_update_deletion.dimension_operator
  dimension_values                          = local.log_search_alert_rule_virtual_network_update_deletion.dimension_values
  minimum_failing_periods_to_trigger_alert = local.log_search_alert_rule_virtual_network_update_deletion.minimum_failing_periods_to_trigger_alert
  number_of_evaluation_periods              = local.log_search_alert_rule_virtual_network_update_deletion.number_of_evaluation_periods
  auto_mitigation_enabled                   = local.log_search_alert_rule_virtual_network_update_deletion.auto_mitigation_enabled
  workspace_alerts_storage_enabled          = local.log_search_alert_rule_virtual_network_update_deletion.workspace_alerts_storage_enabled
  description                               = local.log_search_alert_rule_virtual_network_update_deletion.description
  display_name                              = local.log_search_alert_rule_virtual_network_update_deletion.display_name
  enabled                                   = local.log_search_alert_rule_virtual_network_update_deletion.enabled
  query_time_range_override                 = local.log_search_alert_rule_virtual_network_update_deletion.query_time_range_override
  skip_query_validation                     = local.log_search_alert_rule_virtual_network_update_deletion.skip_query_validation
  action_groups                             = local.log_search_alert_rule_virtual_network_update_deletion.action_groups
  custom_properties                         = local.log_search_alert_rule_virtual_network_update_deletion.custom_properties
  identity_type                             = local.log_search_alert_rule_virtual_network_update_deletion.identity_type
  identity_ids                              = local.log_search_alert_rule_virtual_network_update_deletion.identity_ids
  tags                                      = local.log_search_alert_rule_virtual_network_update_deletion.tags
}

module "log_search_alert_rule_virtual_network_update_deletion_02" {
  source = "./modules/log_search_alert_rule"
  
  name                                      = local.log_search_alert_rule_virtual_network_update_deletion_02.name
  resource_group_name                       = local.log_search_alert_rule_virtual_network_update_deletion_02.resource_group_name
  location                                  = local.log_search_alert_rule_virtual_network_update_deletion_02.location
  evaluation_frequency                      = local.log_search_alert_rule_virtual_network_update_deletion_02.evaluation_frequency
  window_duration                           = local.log_search_alert_rule_virtual_network_update_deletion_02.window_duration
  scopes                                    = local.log_search_alert_rule_virtual_network_update_deletion_02.scopes
  severity                                  = local.log_search_alert_rule_virtual_network_update_deletion_02.severity
  query                                     = local.log_search_alert_rule_virtual_network_update_deletion_02.query
  time_aggregation_method                   = local.log_search_alert_rule_virtual_network_update_deletion_02.time_aggregation_method
  threshold                                 = local.log_search_alert_rule_virtual_network_update_deletion_02.threshold
  operator                                  = local.log_search_alert_rule_virtual_network_update_deletion_02.operator
  resource_id_column                        = local.log_search_alert_rule_virtual_network_update_deletion_02.resource_id_column
  metric_measure_column                     = local.log_search_alert_rule_virtual_network_update_deletion_02.metric_measure_column
  dimension_name                            = local.log_search_alert_rule_virtual_network_update_deletion_02.dimension_name
  dimension_operator                        = local.log_search_alert_rule_virtual_network_update_deletion_02.dimension_operator
  dimension_values                          = local.log_search_alert_rule_virtual_network_update_deletion_02.dimension_values
  minimum_failing_periods_to_trigger_alert = local.log_search_alert_rule_virtual_network_update_deletion_02.minimum_failing_periods_to_trigger_alert
  number_of_evaluation_periods              = local.log_search_alert_rule_virtual_network_update_deletion_02.number_of_evaluation_periods
  auto_mitigation_enabled                   = local.log_search_alert_rule_virtual_network_update_deletion_02.auto_mitigation_enabled
  workspace_alerts_storage_enabled          = local.log_search_alert_rule_virtual_network_update_deletion_02.workspace_alerts_storage_enabled
  description                               = local.log_search_alert_rule_virtual_network_update_deletion_02.description
  display_name                              = local.log_search_alert_rule_virtual_network_update_deletion_02.display_name
  enabled                                   = local.log_search_alert_rule_virtual_network_update_deletion_02.enabled
  query_time_range_override                 = local.log_search_alert_rule_virtual_network_update_deletion_02.query_time_range_override
  skip_query_validation                     = local.log_search_alert_rule_virtual_network_update_deletion_02.skip_query_validation
  action_groups                             = local.log_search_alert_rule_virtual_network_update_deletion_02.action_groups
  custom_properties                         = local.log_search_alert_rule_virtual_network_update_deletion_02.custom_properties
  identity_type                             = local.log_search_alert_rule_virtual_network_update_deletion_02.identity_type
  identity_ids                              = local.log_search_alert_rule_virtual_network_update_deletion_02.identity_ids
  tags                                      = local.log_search_alert_rule_virtual_network_update_deletion_02.tags
}




module "log_search_alert_rule_high_storage_utilization" {
  source                                    = "./modules/log_search_alert_rule"
  name                                      = local.log_search_alert_rule_high_storage_utilization.name
  resource_group_name                       = local.log_search_alert_rule_high_storage_utilization.resource_group_name
  location                                  = local.log_search_alert_rule_high_storage_utilization.location
  evaluation_frequency                      = local.log_search_alert_rule_high_storage_utilization.evaluation_frequency
  window_duration                           = local.log_search_alert_rule_high_storage_utilization.window_duration
  scopes                                    = local.log_search_alert_rule_high_storage_utilization.scopes
  severity                                  = local.log_search_alert_rule_high_storage_utilization.severity
  query                                     = local.log_search_alert_rule_high_storage_utilization.query
  time_aggregation_method                   = local.log_search_alert_rule_high_storage_utilization.time_aggregation_method
  threshold                                 = local.log_search_alert_rule_high_storage_utilization.threshold
  operator                                  = local.log_search_alert_rule_high_storage_utilization.operator
  resource_id_column                        = local.log_search_alert_rule_high_storage_utilization.resource_id_column
  metric_measure_column                     = local.log_search_alert_rule_high_storage_utilization.metric_measure_column
  dimension_name                            = local.log_search_alert_rule_high_storage_utilization.dimension_name
  dimension_operator                        = local.log_search_alert_rule_high_storage_utilization.dimension_operator
  dimension_values                          = local.log_search_alert_rule_high_storage_utilization.dimension_values
  minimum_failing_periods_to_trigger_alert  = local.log_search_alert_rule_high_storage_utilization.minimum_failing_periods_to_trigger_alert
  number_of_evaluation_periods              = local.log_search_alert_rule_high_storage_utilization.number_of_evaluation_periods
  auto_mitigation_enabled                   = local.log_search_alert_rule_high_storage_utilization.auto_mitigation_enabled
  workspace_alerts_storage_enabled          = local.log_search_alert_rule_high_storage_utilization.workspace_alerts_storage_enabled
  description                               = local.log_search_alert_rule_high_storage_utilization.description
  display_name                              = local.log_search_alert_rule_high_storage_utilization.display_name
  enabled                                   = local.log_search_alert_rule_high_storage_utilization.enabled
  query_time_range_override                 = local.log_search_alert_rule_high_storage_utilization.query_time_range_override
  skip_query_validation                     = local.log_search_alert_rule_high_storage_utilization.skip_query_validation
  action_groups                             = local.log_search_alert_rule_high_storage_utilization.action_groups
  custom_properties                         = local.log_search_alert_rule_high_storage_utilization.custom_properties
  identity_type                             = local.log_search_alert_rule_high_storage_utilization.identity_type
  identity_ids                              = local.log_search_alert_rule_high_storage_utilization.identity_ids
  tags                                      = local.log_search_alert_rule_high_storage_utilization.tags
}

module "log_search_alert_rule_iops_consumed_percentage" {
  source                                    = "./modules/log_search_alert_rule"
  name                                      = local.log_search_alert_rule_iops_consumed_percentage.name
  resource_group_name                       = local.log_search_alert_rule_iops_consumed_percentage.resource_group_name
  location                                  = local.log_search_alert_rule_iops_consumed_percentage.location
  evaluation_frequency                      = local.log_search_alert_rule_iops_consumed_percentage.evaluation_frequency
  window_duration                           = local.log_search_alert_rule_iops_consumed_percentage.window_duration
  scopes                                    = local.log_search_alert_rule_iops_consumed_percentage.scopes
  severity                                  = local.log_search_alert_rule_iops_consumed_percentage.severity
  query                                     = local.log_search_alert_rule_iops_consumed_percentage.query
  time_aggregation_method                   = local.log_search_alert_rule_iops_consumed_percentage.time_aggregation_method
  threshold                                 = local.log_search_alert_rule_iops_consumed_percentage.threshold
  operator                                  = local.log_search_alert_rule_iops_consumed_percentage.operator
  resource_id_column                        = local.log_search_alert_rule_iops_consumed_percentage.resource_id_column
  metric_measure_column                     = local.log_search_alert_rule_iops_consumed_percentage.metric_measure_column
  dimension_name                            = local.log_search_alert_rule_iops_consumed_percentage.dimension_name
  dimension_operator                        = local.log_search_alert_rule_iops_consumed_percentage.dimension_operator
  dimension_values                          = local.log_search_alert_rule_iops_consumed_percentage.dimension_values
  minimum_failing_periods_to_trigger_alert  = local.log_search_alert_rule_iops_consumed_percentage.minimum_failing_periods_to_trigger_alert
  number_of_evaluation_periods              = local.log_search_alert_rule_iops_consumed_percentage.number_of_evaluation_periods
  auto_mitigation_enabled                   = local.log_search_alert_rule_iops_consumed_percentage.auto_mitigation_enabled
  workspace_alerts_storage_enabled          = local.log_search_alert_rule_iops_consumed_percentage.workspace_alerts_storage_enabled
  description                               = local.log_search_alert_rule_iops_consumed_percentage.description
  display_name                              = local.log_search_alert_rule_iops_consumed_percentage.display_name
  enabled                                   = local.log_search_alert_rule_iops_consumed_percentage.enabled
  query_time_range_override                 = local.log_search_alert_rule_iops_consumed_percentage.query_time_range_override
  skip_query_validation                     = local.log_search_alert_rule_iops_consumed_percentage.skip_query_validation
  action_groups                             = local.log_search_alert_rule_iops_consumed_percentage.action_groups
  custom_properties                         = local.log_search_alert_rule_iops_consumed_percentage.custom_properties
  identity_type                             = local.log_search_alert_rule_iops_consumed_percentage.identity_type
  identity_ids                              = local.log_search_alert_rule_iops_consumed_percentage.identity_ids
  tags                                      = local.log_search_alert_rule_iops_consumed_percentage.tags
}

module "log_search_alert_rule_key_expiry_imminent" {
  source                                    = "./modules/log_search_alert_rule"
  name                                      = local.log_search_alert_rule_key_expiry_imminent.name
  resource_group_name                       = local.log_search_alert_rule_key_expiry_imminent.resource_group_name
  location                                  = local.log_search_alert_rule_key_expiry_imminent.location
  evaluation_frequency                      = local.log_search_alert_rule_key_expiry_imminent.evaluation_frequency
  window_duration                           = local.log_search_alert_rule_key_expiry_imminent.window_duration
  scopes                                    = local.log_search_alert_rule_key_expiry_imminent.scopes
  severity                                  = local.log_search_alert_rule_key_expiry_imminent.severity
  query                                     = local.log_search_alert_rule_key_expiry_imminent.query
  time_aggregation_method                   = local.log_search_alert_rule_key_expiry_imminent.time_aggregation_method
  threshold                                 = local.log_search_alert_rule_key_expiry_imminent.threshold
  operator                                  = local.log_search_alert_rule_key_expiry_imminent.operator
  resource_id_column                        = local.log_search_alert_rule_key_expiry_imminent.resource_id_column
  metric_measure_column                     = local.log_search_alert_rule_key_expiry_imminent.metric_measure_column
  dimension_name                            = local.log_search_alert_rule_key_expiry_imminent.dimension_name
  dimension_operator                        = local.log_search_alert_rule_key_expiry_imminent.dimension_operator
  dimension_values                          = local.log_search_alert_rule_key_expiry_imminent.dimension_values
  minimum_failing_periods_to_trigger_alert  = local.log_search_alert_rule_key_expiry_imminent.minimum_failing_periods_to_trigger_alert
  number_of_evaluation_periods              = local.log_search_alert_rule_key_expiry_imminent.number_of_evaluation_periods
  auto_mitigation_enabled                   = local.log_search_alert_rule_key_expiry_imminent.auto_mitigation_enabled
  workspace_alerts_storage_enabled          = local.log_search_alert_rule_key_expiry_imminent.workspace_alerts_storage_enabled
  description                               = local.log_search_alert_rule_key_expiry_imminent.description
  display_name                              = local.log_search_alert_rule_key_expiry_imminent.display_name
  enabled                                   = local.log_search_alert_rule_key_expiry_imminent.enabled
  query_time_range_override                 = local.log_search_alert_rule_key_expiry_imminent.query_time_range_override
  skip_query_validation                     = local.log_search_alert_rule_key_expiry_imminent.skip_query_validation
  action_groups                             = local.log_search_alert_rule_key_expiry_imminent.action_groups
  custom_properties                         = local.log_search_alert_rule_key_expiry_imminent.custom_properties
  identity_type                             = local.log_search_alert_rule_key_expiry_imminent.identity_type
  identity_ids                              = local.log_search_alert_rule_key_expiry_imminent.identity_ids
  tags                                      = local.log_search_alert_rule_key_expiry_imminent.tags
}
