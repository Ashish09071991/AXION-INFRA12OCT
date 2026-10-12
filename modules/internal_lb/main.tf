resource "azurerm_lb" "ilb" {
  name                = var.lb_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  tags                = var.tags

  frontend_ip_configuration {
    name                          = "ilb-frontend-ip"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  name            = "${var.lb_name}-pool"
  loadbalancer_id = azurerm_lb.ilb.id
}

resource "azurerm_lb_probe" "health_probe" {
  name                = "${var.lb_name}-health-probe"
  loadbalancer_id     = azurerm_lb.ilb.id
  protocol            = "Tcp"
  port                = var.backend_port
  interval_in_seconds = 15
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "lb_rule" {
  name                           = "${var.lb_name}-rule"
  loadbalancer_id                = azurerm_lb.ilb.id
  protocol                       = "Tcp"
  frontend_port                  = var.backend_port
  backend_port                   = var.backend_port
  frontend_ip_configuration_name = "ilb-frontend-ip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend_pool.id]
  probe_id                       = azurerm_lb_probe.health_probe.id
}
