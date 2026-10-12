output "vm_ids" {
  description = "IDs of the Backend Virtual Machines"
  value       = azurerm_linux_virtual_machine.vm[*].id
}

output "vm_names" {
  description = "Names of the Backend Virtual Machines"
  value       = azurerm_linux_virtual_machine.vm[*].name
}

output "private_ip_addresses" {
  description = "Private IP addresses of Backend Virtual Machines"
  value       = azurerm_network_interface.nic[*].private_ip_address
}

output "nic_ids" {
  description = "NIC IDs of Backend Virtual Machines"
  value       = azurerm_network_interface.nic[*].id
}
