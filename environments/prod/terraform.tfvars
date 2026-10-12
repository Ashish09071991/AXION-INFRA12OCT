environment         = "prod"
resource_group_name = "Rg-axion-prod"
location            = "East US"

vnet_name              = "vnet-axion-prod"
vnet_address_space     = ["10.0.0.0/16"]
appgw_subnet_prefix    = ["10.0.1.0/24"]
frontend_subnet_prefix = ["10.0.2.0/24"]
backend_subnet_prefix  = ["10.0.3.0/24"]
database_subnet_prefix = ["10.0.4.0/24"]

appgw_capacity          = 2
frontend_instance_count = 2
backend_instance_count  = 2

frontend_vm_size = "Standard_B2s"
backend_vm_size  = "Standard_B2s"
database_vm_size = "Standard_B2s"

database_data_disk_size_gb = 64

admin_username = "azureuser"
ssh_public_key = ""

tags = {
  Environment = "Prod"
  Project     = "Axion"
  ManagedBy   = "Terraform"
}
