# exer 7 v2 deploy with azure k8s terraform k8s infrastructure, 27/1.

# Configure the Azure provider
provider "azurerm" {
  features {}
}

terraform {
  backend "s3" {
    bucket         = "docker-gifs-project"
    key            = "omri-azure-tfstate/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}

# Define the AKS cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-cluster-omri"        # Name of your AKS cluster
  location            = "East US"                # Replace with the region where your cluster is deployed
  resource_group_name = "azure-aks-rg"           # Resource group containing your cluster

  dns_prefix          = "aks-cluster-omri-dns"   # Prefix for the AKS cluster's FQDN

  automatic_upgrade_channel    = "patch"
  azure_policy_enabled         = true
  image_cleaner_enabled        = true
  image_cleaner_interval_hours = 168
  oidc_issuer_enabled = true
  workload_identity_enabled    = true


  # Default node pool
  default_node_pool {
    name       = "agentpool"                     # Node pool name (updated from "default")
    vm_size    = "Standard_DS2_v2"               # Size of the VMs in the node pool
    node_count = 2                              # Number of nodes (updated from 2 to 3)
    auto_scaling_enabled = true
    max_count = 2
    min_count = 2
    upgrade_settings {
      drain_timeout_in_minutes = 0
      max_surge = "10%"
      node_soak_duration_in_minutes = 0
    }
  }
  
  maintenance_window_auto_upgrade {
    day_of_month = 0
    day_of_week  = "Sunday"
    duration     = 4
    frequency    = "Weekly"
    interval     = 1
    start_date = "2025-01-26T00:00:00Z"
    start_time = "00:00"
    utc_offset = "+00:00"
  }

  maintenance_window_node_os {
    day_of_month = 0
    day_of_week  = "Sunday"
    duration     = 4
    frequency    = "Weekly"
    interval     = 1
    start_date = "2025-01-26T00:00:00Z"
    start_time = "00:00"
    utc_offset = "+00:00"
  }

  workload_autoscaler_profile {
    keda_enabled = true
    vertical_pod_autoscaler_enabled = false
  }

  # Identity settings
  identity {
    type = "SystemAssigned"                      # Use a system-assigned managed identity
  }

}
