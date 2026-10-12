resource "azurerm_availability_set" "frontend_avset" {
  name                         = "avset-axion-frontend"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
  tags                         = var.tags
}

resource "azurerm_network_interface" "nic" {
  count               = var.instance_count
  name                = "nic-frontend-${count.index + 1}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# Attach Frontend NICs directly into Application Gateway Backend Pool
resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "appgw_assoc" {
  count                   = var.instance_count
  network_interface_id    = azurerm_network_interface.nic[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = var.appgw_backend_pool_id
}

resource "azurerm_linux_virtual_machine" "vm" {
  count                 = var.instance_count
  name                  = "vm-frontend-${count.index + 1}"
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = var.vm_size
  admin_username        = var.admin_username
  availability_set_id   = azurerm_availability_set.frontend_avset.id
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  os_disk {
    name                 = "osdisk-frontend-${count.index + 1}"
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

    cat <<'HTML' > /var/www/html/index.html
    <!DOCTYPE html>
    <html>
    <head>
      <title>Axion 3-Tier Architecture</title>
      <style>
        body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; background-color: #f4f6f9; }
        .card { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); display: inline-block; }
        h1 { color: #0078d4; }
        .tag { background: #e1dfdd; padding: 5px 10px; border-radius: 4px; font-weight: bold; }
      </style>
    </head>
    <body>
      <div class="card">
        <h1>Axion Cloud Architecture</h1>
        <p class="tag">Tier: Frontend Web Server ${count.index + 1}</p>
        <p>Hostname: $(hostname)</p>
        <p>Routed via Azure Application Gateway</p>
        <p>Backend LB Target: ${var.backend_lb_private_ip}</p>
      </div>
    </body>
    </html>
    HTML
  EOF
  )

  tags = merge(
    var.tags,
    {
      Tier = "Frontend"
    }
  )
}
