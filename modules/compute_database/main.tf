resource "azurerm_network_interface" "nic" {
  name                = "nic-database-1"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                  = var.vm_name
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  os_disk {
    name                 = "osdisk-database-1"
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
    # Update packages and prepare disk
    apt-get update -y
    apt-get install -y postgresql postgresql-contrib

    # Format and mount secondary data disk if present
    DATA_DEV="/dev/sdc"
    if [ -b "$DATA_DEV" ]; then
      mkfs.ext4 -F "$DATA_DEV"
      mkdir -p /datadrive
      mount "$DATA_DEV" /datadrive
      echo "$DATA_DEV /datadrive ext4 defaults,nofail 0 2" >> /etc/fstab
    fi

    systemctl enable postgresql
    systemctl start postgresql
  EOF
  )

  tags = merge(
    var.tags,
    {
      Tier = "Database"
    }
  )
}

# Dedicated Managed Data Disk for Database
resource "azurerm_managed_disk" "db_data_disk" {
  name                 = "disk-data-${var.vm_name}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_size_gb
  tags                 = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "db_disk_attach" {
  managed_disk_id    = azurerm_managed_disk.db_data_disk.id
  virtual_machine_id = azurerm_linux_virtual_machine.vm.id
  lun                = 0
  caching            = "ReadWrite"
}
