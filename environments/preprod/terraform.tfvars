environment         = "preprod"
resource_group_name = "Rg-axion-preprod"
location            = "East US"

vnet_name              = "vnet-axion-preprod"
vnet_address_space     = ["10.10.0.0/16"]
appgw_subnet_prefix    = ["10.10.1.0/24"]
frontend_subnet_prefix = ["10.10.2.0/24"]
backend_subnet_prefix  = ["10.10.3.0/24"]
database_subnet_prefix = ["10.10.4.0/24"]

appgw_capacity          = 1
frontend_instance_count = 2
backend_instance_count  = 2

frontend_vm_size = "Standard_B1s"
backend_vm_size  = "Standard_B1s"
database_vm_size = "Standard_B2s"

database_data_disk_size_gb = 32

admin_username = "azureuser"
ssh_public_key = ""

tags = {
  Environment = "PreProd"
  Project     = "Axion"
  ManagedBy   = "Terraform"
}
