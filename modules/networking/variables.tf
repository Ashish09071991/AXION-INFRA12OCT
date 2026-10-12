variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
  default     = "vnet-axion"
}

variable "vnet_address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "appgw_subnet_prefix" {
  description = "Address prefix for Application Gateway Subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "frontend_subnet_prefix" {
  description = "Address prefix for Frontend Subnet"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "backend_subnet_prefix" {
  description = "Address prefix for Backend Subnet"
  type        = list(string)
  default     = ["10.0.3.0/24"]
}

variable "database_subnet_prefix" {
  description = "Address prefix for Database Subnet"
  type        = list(string)
  default     = ["10.0.4.0/24"]
}

variable "backend_port" {
  description = "Port exposed by backend instances"
  type        = number
  default     = 80
}

variable "database_port" {
  description = "Port exposed by database instance"
  type        = number
  default     = 5432
}

variable "tags" {
  description = "Tags to attach to networking resources"
  type        = map(string)
  default     = {}
}
