# -----------------------------------------------------------------------------
# Production Environment: Automated SSH Key Generation
# -----------------------------------------------------------------------------
resource "tls_private_key" "ssh" {
  count     = var.ssh_public_key == "" ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "private_key" {
  count           = var.ssh_public_key == "" ? 1 : 0
  content         = tls_private_key.ssh[0].private_key_pem
  filename        = "${path.module}/id_rsa_prod"
  file_permission = "0600"
}

locals {
  admin_ssh_public_key = var.ssh_public_key != "" ? var.ssh_public_key : tls_private_key.ssh[0].public_key_openssh
}

# -----------------------------------------------------------------------------
# Child Module 1: Resource Group (Rg-axion-prod)
# -----------------------------------------------------------------------------
module "resource_group" {
  source              = "../../modules/resource_group"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# -----------------------------------------------------------------------------
# Child Module 2: Networking (VNet, Subnets, NSGs & Associations)
# -----------------------------------------------------------------------------
module "networking" {
  source                 = "../../modules/networking"
  resource_group_name    = module.resource_group.resource_group_name
  location               = module.resource_group.resource_group_location
  vnet_name              = var.vnet_name
  vnet_address_space     = var.vnet_address_space
  appgw_subnet_prefix    = var.appgw_subnet_prefix
  frontend_subnet_prefix = var.frontend_subnet_prefix
  backend_subnet_prefix  = var.backend_subnet_prefix
  database_subnet_prefix = var.database_subnet_prefix
  tags                   = var.tags

  depends_on = [module.resource_group]
}

# -----------------------------------------------------------------------------
# Child Module 3: Application Gateway (Standard_v2)
# -----------------------------------------------------------------------------
module "application_gateway" {
  source              = "../../modules/application_gateway"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  appgw_name          = "appgw-axion-${var.environment}"
  subnet_id           = module.networking.appgw_subnet_id
  capacity            = var.appgw_capacity
  tags                = var.tags

  depends_on = [module.networking]
}

# -----------------------------------------------------------------------------
# Child Module 4: Internal Load Balancer
# -----------------------------------------------------------------------------
module "internal_lb" {
  source              = "../../modules/internal_lb"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  lb_name             = "ilb-axion-backend-${var.environment}"
  subnet_id           = module.networking.backend_subnet_id
  tags                = var.tags

  depends_on = [module.networking]
}

# -----------------------------------------------------------------------------
# Child Module 5: Database Tier (1 Database VM with Attached Managed Disk)
# -----------------------------------------------------------------------------
module "database_tier" {
  source               = "../../modules/compute_database"
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  vm_name              = "vm-db-1-${var.environment}"
  subnet_id            = module.networking.database_subnet_id
  vm_size              = var.database_vm_size
  admin_username       = var.admin_username
  admin_ssh_public_key = local.admin_ssh_public_key
  data_disk_size_gb    = var.database_data_disk_size_gb
  tags                 = var.tags

  depends_on = [module.networking]
}

# -----------------------------------------------------------------------------
# Child Module 6: Backend Tier (2 Backend VMs registered to Internal LB)
# -----------------------------------------------------------------------------
module "backend_tier" {
  source                      = "../../modules/compute_backend"
  resource_group_name         = module.resource_group.resource_group_name
  location                    = module.resource_group.resource_group_location
  subnet_id                   = module.networking.backend_subnet_id
  instance_count              = var.backend_instance_count
  vm_size                     = var.backend_vm_size
  admin_username              = var.admin_username
  admin_ssh_public_key        = local.admin_ssh_public_key
  internal_lb_backend_pool_id = module.internal_lb.backend_pool_id
  database_private_ip         = module.database_tier.private_ip_address
  tags                        = var.tags

  depends_on = [module.networking, module.internal_lb, module.database_tier]
}

# -----------------------------------------------------------------------------
# Child Module 7: Frontend Tier (2 Frontend VMs registered to App Gateway)
# -----------------------------------------------------------------------------
module "frontend_tier" {
  source                = "../../modules/compute_frontend"
  resource_group_name   = module.resource_group.resource_group_name
  location              = module.resource_group.resource_group_location
  subnet_id             = module.networking.frontend_subnet_id
  instance_count        = var.frontend_instance_count
  vm_size               = var.frontend_vm_size
  admin_username        = var.admin_username
  admin_ssh_public_key  = local.admin_ssh_public_key
  appgw_backend_pool_id = module.application_gateway.backend_address_pool_id
  backend_lb_private_ip = module.internal_lb.private_ip_address
  tags                  = var.tags

  depends_on = [module.networking, module.application_gateway, module.internal_lb]
}
