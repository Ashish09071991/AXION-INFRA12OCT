variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for Frontend VMs"
  type        = string
}

variable "instance_count" {
  description = "Number of frontend VM instances to create"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "Size / SKU of the Virtual Machines"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Admin username for the Virtual Machines"
  type        = string
  default     = "azureuser"
}

variable "admin_ssh_public_key" {
  description = "SSH public key content for VM authentication"
  type        = string
}

variable "appgw_backend_pool_id" {
  description = "ID of Application Gateway backend address pool to join"
  type        = string
}

variable "backend_lb_private_ip" {
  description = "Private IP of internal load balancer for backend API routing"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to attach to frontend compute resources"
  type        = map(string)
  default     = {}
}
