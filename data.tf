data "azurerm_client_config" "current" {}

data "http" "tfe_agent_public_ip" {
  url = "https://api.ipify.org"
}