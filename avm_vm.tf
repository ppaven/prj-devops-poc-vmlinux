
# https://github.com/Azure/terraform-azurerm-avm-res-compute-virtualmachine
#
module "vm" {
  source = "Azure/avm-res-compute-virtualmachine/azurerm"
  #version = "0.15.1"

  name = lower("${module.naming.virtual_machine.name}01")

  admin_username                     = lower("admin${var.company_trig}")
  disable_password_authentication    = false
  enable_telemetry                   = false
  encryption_at_host_enabled         = false
  generate_admin_password_or_ssh_key = true
  location                           = azurerm_resource_group.rg.location
  resource_group_name                = azurerm_resource_group.rg.name
  os_type                            = "Linux"
  sku_size                           = "Standard_D2as_v5"
  zone                               = "3"

  generated_secrets_key_vault_secret_config = {
    key_vault_resource_id = module.avm_keyvault.resource_id
    name                  = lower("admin${var.company_trig}-password")
  }

  network_interfaces = {
    network_interface_1 = {
      name = lower(module.naming.network_interface.name_unique)
      ip_configurations = {
        ip_configuration_1 = {
          name                          = "${module.naming.network_interface.name_unique}-ipconfig1"
          private_ip_subnet_resource_id = azurerm_subnet.vm_subnet.id
          create_public_ip_address      = true
          public_ip_address_name        = module.naming.public_ip.name_unique
        }
      }
    }
  }

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  tags = var.tags
}

