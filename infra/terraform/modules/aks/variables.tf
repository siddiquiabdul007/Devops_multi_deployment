variable "location" {
  type        = string
  description = "Azure region where resources will be created"
}

variable "prefix" {
  type        = string
  description = "Prefix for resource names"
}

variable "env" {
  type        = string
  description = "Environment (e.g., dev, prod)"
}

variable "node_count" {
  type        = number
  description = "Number of nodes in the AKS default node pool"
  default     = 2
}

variable "vm_size" {
  type        = string
  description = "VM size for the AKS default node pool"
  default     = "Standard_DS2_v2"
}
