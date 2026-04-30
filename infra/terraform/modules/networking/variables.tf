variable "prefix" {
  type        = string
  description = "Prefix for resources"
}

variable "env" {
  type        = string
  description = "Environment (dev/prod)"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "address_space" {
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "subnet_prefixes" {
  type        = list(string)
  default     = ["10.240.0.0/16"]
}
