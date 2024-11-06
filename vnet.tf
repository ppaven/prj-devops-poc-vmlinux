resource "azurerm_virtual_network" "vnet" {
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  name                = lower(module.naming.virtual_network.name)
  resource_group_name = azurerm_resource_group.rg.name

  tags = var.tags
}

resource "azurerm_subnet" "vm_subnet" {
  address_prefixes     = ["10.0.1.0/24"]
  name                 = lower("${module.naming.subnet.name}-VM")
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}