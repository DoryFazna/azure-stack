resource "azurerm_availability_set" "web_availabilty_set" {
  name                = "web_availabilty_set"
  location            = var.location
  resource_group_name = var.resource_group
  platform_fault_domain_count = 2
}

resource "azurerm_public_ip" "mtc-ip1" {
  name                = "mtc-ip1"
  resource_group_name = var.resource_group
  location            = var.location
  allocation_method   = "Dynamic"

}
resource "azurerm_network_interface" "web-net-interface" {
    name = "web-network"
    resource_group_name = var.resource_group
    location = var.location

    ip_configuration{
        name = "web-webserver"
        subnet_id = var.web_subnet_id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.mtc-ip1.id
    }
}

resource "azurerm_linux_virtual_machine" "web-vm" {
   name                = "web-vm"
   location = var.location
   resource_group_name = var.resource_group
   network_interface_ids = [ azurerm_network_interface.web-net-interface.id ]
   availability_set_id = azurerm_availability_set.web_availabilty_set.id
   size                = "Standard_B1s"
   admin_username      = "adminuser"

   custom_data = filebase64("customdata-app.tpl")

   admin_ssh_key {
     username   = "adminuser"
     public_key = file("~/.ssh/mtcazurekey.pub")
   }

   os_disk {
     caching              = "ReadWrite"
     storage_account_type = "Standard_LRS"
   }

   source_image_reference {
     publisher = "Canonical"
     offer     = "UbuntuServer"
     sku       = "18.04-LTS"
     version   = "latest"
   }
 }
  


  
resource "azurerm_availability_set" "app_availabilty_set" {
  name                = "app_availabilty_set"
  location            = var.location
  resource_group_name = var.resource_group
  platform_fault_domain_count = 2
 }

 resource "azurerm_public_ip" "mtc-ip2" {
  name                = "mtc-ip2"
  resource_group_name = var.resource_group
  location            = var.location
  allocation_method   = "Dynamic"

}

resource "azurerm_network_interface" "app-net-interface" {
    name = "app-network"
    resource_group_name = var.resource_group
    location = var.location

    ip_configuration{
        name = "app-webserver"
        subnet_id = var.app_subnet_id
        private_ip_address_allocation = "Static"
        private_ip_address = "192.168.2.11"
        public_ip_address_id          = azurerm_public_ip.mtc-ip2.id
    }
}

resource "azurerm_linux_virtual_machine" "app-vm" {
   name                = "app-vm"
   location = var.location
   resource_group_name = var.resource_group
   network_interface_ids = [ azurerm_network_interface.app-net-interface.id ]
   availability_set_id = azurerm_availability_set.app_availabilty_set.id
   size                = "Standard_B1s"
   admin_username      = "adminuser"

   custom_data = filebase64("customdata-logic.tpl")

   admin_ssh_key {
     username   = "adminuser"
     public_key = file("~/.ssh/mtcazurekey.pub")
   }

   os_disk {
     caching              = "ReadWrite"
     storage_account_type = "Standard_LRS"
   }

   source_image_reference {
     publisher = "Canonical"
     offer     = "UbuntuServer"
     sku       = "18.04-LTS"
     version   = "latest"
   }
 }
