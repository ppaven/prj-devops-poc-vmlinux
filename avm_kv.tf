#
# https://github.com/Azure/terraform-azurerm-avm-res-keyvault-vault/tree/main

module "avm_keyvault" {
  source                      = "Azure/avm-res-keyvault-vault/azurerm"
#   version                     = "=0.7.1"
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  name                        = lower("${module.naming.key_vault.name}01")
  resource_group_name         = azurerm_resource_group.rg.name
  location                    = azurerm_resource_group.rg.location

  sku_name                    = "standard"
  soft_delete_retention_days  = "7"
  enabled_for_disk_encryption = false
  enabled_for_deployment      = true
  enabled_for_template_deployment   = true
  legacy_access_policies_enabled    = false

  network_acls = {
    default_action = "Allow"
    bypass         = "AzureServices"
    ip_rules       = ["${data.http.ip.response_body}/32"]
  }

  # role_assignments = {
  #   deployment_user_secrets = { #give the deployment user access to secrets
  #     role_definition_id_or_name = "Key Vault Administrator"
  #     principal_id               = data.azurerm_client_config.current.object_id
  #   }
  # }

  wait_for_rbac_before_key_operations = {
    create = "60s"
  }

  wait_for_rbac_before_secret_operations = {
    create = "60s"
  }

  tags = var.tags
  
}
