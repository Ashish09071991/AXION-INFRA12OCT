output "lb_id" {
  description = "ID of the Internal Load Balancer"
  value       = azurerm_lb.ilb.id
}

output "lb_name" {
  description = "Name of the Internal Load Balancer"
  value       = azurerm_lb.ilb.name
}

output "backend_pool_id" {
  description = "ID of the Backend Address Pool"
  value       = azurerm_lb_backend_address_pool.backend_pool.id
}

output "private_ip_address" {
  description = "Private IP address of the Internal Load Balancer"
  value       = azurerm_lb.ilb.frontend_ip_configuration[0].private_ip_address
}
