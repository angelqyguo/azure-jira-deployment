# storage account for shared FS
# Create the File Share
## Create the File storage account
resource "azurerm_storage_account" "jira_storage" {
  name                     = lower("jirasa${random_string.stor_name.result}")
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Premium"
  account_replication_type = "LRS"
  account_kind             = "FileStorage"

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices", "Logging", "Metrics"]
    ip_rules = [
      "49.187.14.30",
      data.http.tfe_agent_public_ip.request_body
    ]
    virtual_network_subnet_ids = [
      azurerm_subnet.db_subnet.id,
      azurerm_subnet.atlassian_subnet_backend.id
    ]
  }

}

resource "azurerm_storage_share" "jira_FSShare" {
  name                 = "fslogix"
  quota                = 128
  storage_account_name = azurerm_storage_account.jira_storage.name
  depends_on           = [azurerm_storage_account.jira_storage]
}

resource "azurerm_key_vault_secret" "jira_storage_access_key" {
  key_vault_id = azurerm_key_vault.kv01.id
  name         = "jirastoragekey"
  value        = azurerm_storage_account.jira_storage.primary_access_key
}

resource "azurerm_key_vault_secret" "jira_storage_name" {
  key_vault_id = azurerm_key_vault.kv01.id
  name         = "jirastoragename"
  value        = lower("jirasa${random_string.stor_name.result}")
}