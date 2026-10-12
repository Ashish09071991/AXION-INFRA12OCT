output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "Name of the Virtual Network"
  value       = azurerm_virtual_network.vnet.name
}

output "appgw_subnet_id" {
  description = "Subnet ID for Application Gateway"
  value       = azurerm_subnet.snet_appgw.id
}

output "frontend_subnet_id" {
  description = "Subnet ID for Frontend tier"
  value       = azurerm_subnet.snet_frontend.id
}

output "backend_subnet_id" {
  description = "Subnet ID for Backend tier"
  value       = azurerm_subnet.snet_backend.id
}

output "database_subnet_id" {
  description = "Subnet ID for Database tier"
  value       = azurerm_subnet.snet_database.id
}

output "frontend_nsg_id" {
  description = "ID of the Frontend NSG"
  value       = azurerm_network_security_group.nsg_frontend.id
}

output "backend_nsg_id" {
  description = "ID of the Backend NSG"
  value       = azurerm_network_security_group.nsg_backend.id
}

output "database_nsg_id" {
  description = "ID of the Database NSG"
  value       = azurerm_network_security_group.nsg_database.id
}
