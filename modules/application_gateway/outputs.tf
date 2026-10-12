output "appgw_id" {
  description = "ID of the Application Gateway"
  value       = azurerm_application_gateway.appgw.id
}

output "appgw_name" {
  description = "Name of the Application Gateway"
  value       = azurerm_application_gateway.appgw.name
}

output "public_ip_address" {
  description = "Public IP Address of the Application Gateway"
  value       = azurerm_public_ip.appgw_pip.ip_address
}

output "public_ip_id" {
  description = "ID of the Public IP resource"
  value       = azurerm_public_ip.appgw_pip.id
}

output "backend_address_pool_id" {
  description = "ID of the Backend Address Pool for Frontend VMs"
  value       = one([for pool in azurerm_application_gateway.appgw.backend_address_pool : pool.id if pool.name == local.backend_address_pool_name])
}
