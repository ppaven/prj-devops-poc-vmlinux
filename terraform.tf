terraform {
  backend "azurerm" {
    storage_account_name = "azccinfratfback"
    container_name       = "tfstate"
    # key                  = "poc.vml.tfstate"
    use_oidc = true
  }
}
