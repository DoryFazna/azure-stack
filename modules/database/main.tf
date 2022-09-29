resource "azurerm_mssql_server" "primary" {
    name = var.primary_database
    resource_group_name = var.resource_group
    location = var.location
    version = var.primary_database_version
    administrator_login = var.primary_database_admin
    administrator_login_password = var.primary_database_password
    public_network_access_enabled = false
}

resource "azurerm_mssql_database" "db" {
  name                = "db"
  //resource_group_name = var.resource_group
  //location            = var.location
  //server_name         = azurerm_mssql_server.primary.name
  server_id = azurerm_mssql_server.primary.id
}

resource "azurerm_private_endpoint" "ap-end" {
  name                = "priv-endpoint"
  location            = var.location
  resource_group_name = var.resource_group
  subnet_id           = var.app_subnet_id

  private_service_connection {
    name                           = "xprivateserviceconnection"
    private_connection_resource_id = azurerm_mssql_server.primary.id
    subresource_names              = [ "sqlServer" ]
    is_manual_connection           = false
  }
}

