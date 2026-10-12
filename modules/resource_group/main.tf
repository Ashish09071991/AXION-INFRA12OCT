resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  tags = merge(
    {
      Project   = "Axion-Infrastructure"
      ManagedBy = "Terraform"
    },
    var.tags
  )
}
