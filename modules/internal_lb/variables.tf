variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "lb_name" {
  description = "Name of the Internal Load Balancer"
  type        = string
  default     = "ilb-axion-backend"
}

variable "subnet_id" {
  description = "Subnet ID where the Internal Load Balancer frontend IP will be allocated (Backend Subnet)"
  type        = string
}

variable "backend_port" {
  description = "Port to balance across backend instances"
  type        = number
  default     = 80
}

variable "tags" {
  description = "Tags to attach to the load balancer"
  type        = map(string)
  default     = {}
}
