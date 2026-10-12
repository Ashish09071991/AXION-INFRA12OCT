variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for Backend VMs"
  type        = string
}

variable "instance_count" {
  description = "Number of backend VM instances to create"
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

variable "internal_lb_backend_pool_id" {
  description = "ID of Internal Load Balancer backend pool to register with"
  type        = string
}

variable "backend_port" {
  description = "Port the backend application listens on"
  type        = number
  default     = 80
}

variable "database_private_ip" {
  description = "Private IP of the Database VM"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to attach to backend compute resources"
  type        = map(string)
  default     = {}
}
