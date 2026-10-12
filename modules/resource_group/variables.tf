variable "resource_group_name" {
  description = "The name of the Resource Group"
  type        = string
  default     = "Rg-axion"
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
  default     = "East US"
}

variable "tags" {
  description = "A mapping of tags to assign to the resource group"
  type        = map(string)
  default     = {}
}
