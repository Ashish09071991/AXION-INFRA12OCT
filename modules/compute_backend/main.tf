resource "azurerm_availability_set" "backend_avset" {
  name                         = "avset-axion-backend"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
  tags                         = var.tags
}

resource "azurerm_network_interface" "nic" {
  count               = var.instance_count
  name                = "nic-backend-${count.index + 1}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# Attach Backend NICs to Internal Load Balancer Backend Pool
resource "azurerm_network_interface_backend_address_pool_association" "ilb_assoc" {
  count                   = var.instance_count
  network_interface_id    = azurerm_network_interface.nic[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = var.internal_lb_backend_pool_id
}

resource "azurerm_linux_virtual_machine" "vm" {
  count                 = var.instance_count
  name                  = "vm-backend-${count.index + 1}"
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = var.vm_size
  admin_username        = var.admin_username
  availability_set_id   = azurerm_availability_set.backend_avset.id
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  os_disk {
    name                 = "osdisk-backend-${count.index + 1}"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    systemctl enable nginx
    systemctl start nginx

    cat <<'JSON' > /var/www/html/index.html
    {
      "status": "online",
      "service": "axion-backend-api",
      "server_instance": ${count.index + 1},
      "hostname": "$(hostname)",
      "database_target": "${var.database_private_ip}"
    }
    JSON
  EOF
  )

  tags = merge(
    var.tags,
    {
      Tier = "Backend"
    }
  )
}
