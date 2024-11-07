# Create the Database
resource "random_integer" "psqladmin_suffix" {
  min = 1000
  max = 9999
}

resource "random_string" "psqladmin_password" {
  length = 16
}

resource "azurerm_key_vault_secret" "dbusername" {
  key_vault_id = azurerm_key_vault.kv01.id
  name         = "dbusername"
  value        = "psqladmin${random_integer.psqladmin_suffix.result}"
}

resource "azurerm_key_vault_secret" "dbpassword" {
  key_vault_id = azurerm_key_vault.kv01.id
  name         = "dbpassword"
  value        = random_string.psqladmin_password.result
}

resource "azurerm_private_dns_zone" "pgsql_private_dns" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "pgsql_private_dns_link" {
  name                  = "pgsqlPrivateDNSZone-db_subnet"
  private_dns_zone_name = azurerm_private_dns_zone.pgsql_private_dns.name
  virtual_network_id    = azurerm_virtual_network.atlassian_network.id
  resource_group_name   = azurerm_resource_group.rg.name
  depends_on            = [azurerm_subnet.db_subnet]
}

resource "azurerm_postgresql_flexible_server" "jiradbserver" {
  name                          = "pgsql${lower(random_string.stor_name.result)}"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  zone                          = "2"
  version                       = "12"
  public_network_access_enabled = false
  delegated_subnet_id           = azurerm_subnet.db_subnet.id
  private_dns_zone_id           = azurerm_private_dns_zone.pgsql_private_dns.id
  administrator_login           = "psqladmin${random_integer.psqladmin_suffix.result}"
  administrator_password        = random_string.psqladmin_password.result

  sku_name = "B_Standard_B1ms"
}

resource "azurerm_postgresql_flexible_server_database" "jiradb" {
  name      = "jiradb"
  server_id = azurerm_postgresql_flexible_server.jiradbserver.id
  collation = "en_US.utf8"
  charset   = "utf8"
}