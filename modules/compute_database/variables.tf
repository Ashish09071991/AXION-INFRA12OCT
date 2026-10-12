variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for Database VM"
  type        = string
}

variable "vm_name" {
  description = "Name of the Database Virtual Machine"
  type        = string
  default     = "vm-database-1"
}

variable "vm_size" {
  description = "Size / SKU of the Database Virtual Machine"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Admin username for the Database VM"
  type        = string
  default     = "azureuser"
}

variable "admin_ssh_public_key" {
  description = "SSH public key content for VM authentication"
  type        = string
}

variable "data_disk_size_gb" {
  description = "Size of dedicated managed data disk in GB"
  type        = number
  default     = 32
}

variable "tags" {
  description = "Tags to attach to database compute resources"
  type        = map(string)
  default     = {}
}
