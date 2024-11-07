# Create KeyVault for storing secrets
resource "azurerm_key_vault" "kv01" {
  name                        = "azkv${random_string.stor_name.result}"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  enable_rbac_authorization   = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"
}

resource "azurerm_role_assignment" "vm_kv01_rbac" {
  scope                = azurerm_key_vault.kv01.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = azurerm_linux_virtual_machine.jira_host_vm.identity[0].principal_id
}