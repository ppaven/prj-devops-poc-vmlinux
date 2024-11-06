resource "azurerm_virtual_network" "vnet" {
  address_space       = var.address_space
  location            = azurerm_resource_group.rg.location
  name                = lower(module.naming.virtual_network.name)
  resource_group_name = azurerm_resource_group.rg.name

  tags = var.tags
}

resource "azurerm_subnet" "vm_subnet" {
  address_prefixes     = var.address_snet
  name                 = lower("${module.naming.subnet.name}-VM")
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}