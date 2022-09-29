resource "azurerm_virtual_network" "vnet01" {
  name                = "vnet01"
  resource_group_name = var.resource_group
  location            = var.location
  address_space       = [var.vnetcidr]
}

resource "azurerm_subnet" "web-subnet" {
  name                 = "web-subnet"
  virtual_network_name = azurerm_virtual_network.vnet01.name
  resource_group_name  = var.resource_group
  address_prefixes     = [var.websubnetcidr]
}

resource "azurerm_subnet" "app-subnet" {
  name                 = "app-subnet"
  virtual_network_name = azurerm_virtual_network.vnet01.name
  resource_group_name  = var.resource_group
  address_prefixes     = [var.appsubnetcidr]
}

resource "azurerm_subnet" "db-subnet" {
  name                 = "db-subnet"
  virtual_network_name = azurerm_virtual_network.vnet01.name
  resource_group_name  = var.resource_group
  address_prefixes     = [var.dbsubnetcidr]
  private_endpoint_network_policies_enabled = true
}


# Create a DB Private DNS Zone
resource "azurerm_private_dns_zone" "endpoint-dns-private-zone" {
  name = "database.windows.net"
  resource_group_name = var.resource_group
}




# Create a Private DNS to VNET link
resource "azurerm_private_dns_zone_virtual_network_link" "dns-zone-to-vnet-link" {
  name = "sql-db-vnet-link"
  resource_group_name = var.resource_group
  private_dns_zone_name = azurerm_private_dns_zone.endpoint-dns-private-zone.name
  virtual_network_id = azurerm_virtual_network.vnet01.id
}
