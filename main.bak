# Random string
resource "random_string" "stor_name" {
  length  = 8
  lower   = true
  special = false
}

# Create the resource group
resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = random_pet.rg_name.id
}

# Create the virtual network
resource "azurerm_virtual_network" "atlassian_network" {
  name                = "atlassianVnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet frontend
resource "azurerm_subnet" "atlassian_subnet_frontend" {
  name                 = "jiraFrontendSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.atlassian_network.name
  address_prefixes     = ["10.0.0.0/24"]
}

# Create subnet backend
resource "azurerm_subnet" "atlassian_subnet_backend" {
  name                 = "jiraBackendSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.atlassian_network.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
}

# Create PostgresSQL subnet 
resource "azurerm_subnet" "db_subnet" {
  name                 = "PostgreSQLSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.atlassian_network.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "pgsql"

    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

# Create the public IP
resource "azurerm_public_ip" "atlassian_network_public_ip" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "my_terraform_nsg" {
  name                = "atlassianNetworkSecurityGroup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create nework interface
resource "azurerm_network_interface" "jira_nic" {
  name                = "jiraNIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "jira_nic_configuration"
    subnet_id                     = azurerm_subnet.atlassian_subnet_backend.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.atlassian_network_public_ip.id
  }
}

# Create the VMSS
resource "azurerm_linux_virtual_machine" "jira_host_vm" {
  name                  = "myVM${random_pet.rg_name.id}"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.jira_nic.id]
  size                  = "Standard_DS2_v2"
  priority              = "Spot"
  eviction_policy       = "Deallocate"

  os_disk {
    name                 = "myOsDisk${random_pet.rg_name.id}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_id = var.source_image_id

  computer_name  = "jira-vm-01"
  admin_username = var.username
  admin_password = random_string.psqladmin_password.result

  identity {
    type = "SystemAssigned"
  }

  custom_data = base64encode(
    templatefile(
      "./templates/vm-cloud-init.tftpl",
      {
        pgsql_server_fqdn = azurerm_postgresql_flexible_server.jiradbserver.fqdn
        jira_db_name      = azurerm_postgresql_flexible_server_database.jiradb.name
        key_vault_uri     = azurerm_key_vault.kv01.vault_uri
        fs_name           = azurerm_storage_share.jira_FSShare.name
      }
    )
  )

  depends_on = [
    azurerm_postgresql_flexible_server.jiradbserver,
    azurerm_storage_share.jira_FSShare,
    azurerm_key_vault.kv01
  ]
}
