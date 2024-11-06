locals {
  nsg_rules = {
    "rule01" = {
      name                       = "${module.naming.network_security_rule.name_unique}1"
      access                     = "Allow"
      destination_address_prefix = "*"
      destination_port_range     = "22"
      direction                  = "Inbound"
      priority                   = 100
      protocol                   = "Tcp"
      source_address_prefix      = data.http.ip.response_body
      source_port_range          = "*"
    }
    "rule02" = {
      name                       = "${module.naming.network_security_rule.name_unique}2"
      access                     = "Allow"
      destination_address_prefix = "*"
      destination_port_ranges    = ["80", "443"]
      direction                  = "Inbound"
      priority                   = 200
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
    }
  }
}

# Get current IP address for use in KV firewall rules
data "http" "ip" {
  url = "https://api.ipify.org/"
  retry {
    attempts     = 5
    max_delay_ms = 1000
    min_delay_ms = 500
  }
}

# This is the module call
module "nsg" {
  source              = "Azure/avm-res-network-networksecuritygroup/azurerm"
  resource_group_name = azurerm_resource_group.rg.name
  name                = lower("${module.naming.network_security_group.name}01")
  location            = azurerm_resource_group.rg.location

  security_rules = local.nsg_rules


  tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "nsg_on_int" {
  network_security_group_id = module.nsg.resource_id
  network_interface_id      = module.vm.network_interfaces["network_interface_1"].id
}