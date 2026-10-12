# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.vnet_address_space
  tags                = var.tags
}

# 1. Application Gateway Dedicated Subnet
resource "azurerm_subnet" "snet_appgw" {
  name                 = "snet-appgw"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.appgw_subnet_prefix
}

# 2. Frontend Subnet
resource "azurerm_subnet" "snet_frontend" {
  name                 = "snet-frontend"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.frontend_subnet_prefix
}

# 3. Backend Subnet
resource "azurerm_subnet" "snet_backend" {
  name                 = "snet-backend"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.backend_subnet_prefix
}

# 4. Database Subnet
resource "azurerm_subnet" "snet_database" {
  name                 = "snet-database"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.database_subnet_prefix
}

# -------------------------------------------------------------
# Network Security Groups (NSGs) & Security Rules
# -------------------------------------------------------------

# Application Gateway NSG
resource "azurerm_network_security_group" "nsg_appgw" {
  name                = "nsg-appgw"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  security_rule {
    name                       = "Allow-AppGW-Management"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65200-65535"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTP-HTTPS-Internet"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443"]
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-Azure-Load-Balancer"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }
}

# Frontend NSG: Accepts traffic only from Application Gateway Subnet
resource "azurerm_network_security_group" "nsg_frontend" {
  name                = "nsg-frontend"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  security_rule {
    name                       = "Allow-HTTP-From-AppGW"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = var.appgw_subnet_prefix[0]
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-SSH-Internal"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }
}

# Backend NSG: Accepts traffic only from Frontend Subnet and AzureLoadBalancer
resource "azurerm_network_security_group" "nsg_backend" {
  name                = "nsg-backend"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  security_rule {
    name                       = "Allow-Backend-From-Frontend"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = tostring(var.backend_port)
    source_address_prefix      = var.frontend_subnet_prefix[0]
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-Probe-From-AzureLoadBalancer"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = tostring(var.backend_port)
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-SSH-Internal"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }
}

# Database NSG: Accepts traffic only from Backend Subnet
resource "azurerm_network_security_group" "nsg_database" {
  name                = "nsg-database"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  security_rule {
    name                       = "Allow-DB-From-Backend"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = tostring(var.database_port)
    source_address_prefix      = var.backend_subnet_prefix[0]
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-SSH-Internal"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }
}

# -------------------------------------------------------------
# Subnet to NSG Associations
# -------------------------------------------------------------

resource "azurerm_subnet_network_security_group_association" "appgw" {
  subnet_id                 = azurerm_subnet.snet_appgw.id
  network_security_group_id = azurerm_network_security_group.nsg_appgw.id
}

resource "azurerm_subnet_network_security_group_association" "frontend" {
  subnet_id                 = azurerm_subnet.snet_frontend.id
  network_security_group_id = azurerm_network_security_group.nsg_frontend.id
}

resource "azurerm_subnet_network_security_group_association" "backend" {
  subnet_id                 = azurerm_subnet.snet_backend.id
  network_security_group_id = azurerm_network_security_group.nsg_backend.id
}

resource "azurerm_subnet_network_security_group_association" "database" {
  subnet_id                 = azurerm_subnet.snet_database.id
  network_security_group_id = azurerm_network_security_group.nsg_database.id
}
