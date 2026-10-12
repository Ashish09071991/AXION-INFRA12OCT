output "vm_id" {
  description = "ID of the Database Virtual Machine"
  value       = azurerm_linux_virtual_machine.vm.id
}

output "vm_name" {
  description = "Name of the Database Virtual Machine"
  value       = azurerm_linux_virtual_machine.vm.name
}

output "private_ip_address" {
  description = "Private IP address of the Database Virtual Machine"
  value       = azurerm_network_interface.nic.private_ip_address
}

output "nic_id" {
  description = "NIC ID of the Database Virtual Machine"
  value       = azurerm_network_interface.nic.id
}

output "data_disk_id" {
  description = "ID of the attached Managed Data Disk"
  value       = azurerm_managed_disk.db_data_disk.id
}
