variable "environment" {
  description = "Environment name"
  type        = string
  default     = "preprod"
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "Rg-axion-preprod"
}

variable "location" {
  description = "Azure Region for all resources"
  type        = string
  default     = "East US"
}

variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
  default     = "vnet-axion-preprod"
}

variable "vnet_address_space" {
  description = "CIDR block for the Virtual Network"
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "appgw_subnet_prefix" {
  description = "CIDR prefix for Application Gateway dedicated subnet"
  type        = list(string)
  default     = ["10.10.1.0/24"]
}

variable "frontend_subnet_prefix" {
  description = "CIDR prefix for Frontend tier subnet"
  type        = list(string)
  default     = ["10.10.2.0/24"]
}

variable "backend_subnet_prefix" {
  description = "CIDR prefix for Backend tier subnet"
  type        = list(string)
  default     = ["10.10.3.0/24"]
}

variable "database_subnet_prefix" {
  description = "CIDR prefix for Database tier subnet"
  type        = list(string)
  default     = ["10.10.4.0/24"]
}

variable "appgw_capacity" {
  description = "Instance capacity for Application Gateway in PreProd"
  type        = number
  default     = 1
}

variable "frontend_instance_count" {
  description = "Number of VMs in frontend tier (as per architecture diagram: 2)"
  type        = number
  default     = 2
}

variable "backend_instance_count" {
  description = "Number of VMs in backend tier (as per architecture diagram: 2)"
  type        = number
  default     = 2
}

variable "frontend_vm_size" {
  description = "Virtual Machine size for Frontend tier"
  type        = string
  default     = "Standard_B1s"
}

variable "backend_vm_size" {
  description = "Virtual Machine size for Backend tier"
  type        = string
  default     = "Standard_B1s"
}

variable "database_vm_size" {
  description = "Virtual Machine size for Database tier"
  type        = string
  default     = "Standard_B2s"
}

variable "database_data_disk_size_gb" {
  description = "Managed data disk size in GB for Database VM"
  type        = number
  default     = 32
}

variable "admin_username" {
  description = "Admin username for all Virtual Machines"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "Optional existing SSH public key. If empty, a secure SSH key will be automatically generated."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags applied to all infrastructure components"
  type        = map(string)
  default = {
    Environment = "PreProd"
    Project     = "Axion"
    ManagedBy   = "Terraform"
  }
}
