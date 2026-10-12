variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "appgw_name" {
  description = "Name of the Application Gateway"
  type        = string
  default     = "appgw-axion"
}

variable "subnet_id" {
  description = "Subnet ID dedicated for Application Gateway"
  type        = string
}

variable "sku_name" {
  description = "SKU Name for Application Gateway"
  type        = string
  default     = "Standard_v2"
}

variable "sku_tier" {
  description = "SKU Tier for Application Gateway"
  type        = string
  default     = "Standard_v2"
}

variable "capacity" {
  description = "Capacity / instance count for Application Gateway"
  type        = number
  default     = 2
}

variable "tags" {
  description = "Tags to attach to Application Gateway resources"
  type        = map(string)
  default     = {}
}
