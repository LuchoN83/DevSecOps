data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_key_vault" "kv" {
  name                          = var.kv_name
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  purge_protection_enabled      = true
  soft_delete_retention_days    = 7
  public_network_access_enabled = true

  # Da permisos al principal actual para administración básica
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions         = ["Get", "List", "Create", "Delete"]
    secret_permissions      = ["Get", "List", "Set", "Delete"]
    certificate_permissions = ["Get", "List", "Create", "Delete"]
    storage_permissions     = []
  }

  tags = var.tags
}