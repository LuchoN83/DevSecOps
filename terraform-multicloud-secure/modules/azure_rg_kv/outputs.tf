output "resource_group_name" {
  value       = azurerm_resource_group.rg.name
  description = "Resource Group creado."
}

output "key_vault_uri" {
  value       = azurerm_key_vault.kv.vault_uri
  description = "URI del Key Vault."
}
