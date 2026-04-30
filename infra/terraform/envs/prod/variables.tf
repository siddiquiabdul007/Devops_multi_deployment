variable "location" {
  type        = string
  description = "Azure region"
}

variable "prefix" {
  type        = string
  description = "Prefix for resources"
}

variable "env" {
  type        = string
  description = "Environment name"
}

variable "node_count" {
  type        = number
  description = "AKS node count"
  default     = 3
}

variable "vm_size" {
  type        = string
  description = "VM size for AKS nodes"
  default     = "Standard_D2s_v3"
}