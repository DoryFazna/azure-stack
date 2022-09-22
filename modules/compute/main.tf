resource "azurerm_availability_set" "web_availabilty_set" {
  name                = "web_availabilty_set"
  location            = var.location
  resource_group_name = var.resource_group
  platform_fault_domain_count = 2
}

resource "azurerm_network_interface" "web-net-interface" {
    name = "web-network"
    resource_group_name = var.resource_group
    location = var.location

    ip_configuration{
        name = "web-webserver"
        subnet_id = var.web_subnet_id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_virtual_machine" "web-vm" {
  name = "web-vm"
  location = var.location
  resource_group_name = var.resource_group
  network_interface_ids = [ azurerm_network_interface.web-net-interface.id ]
  availability_set_id = azurerm_availability_set.web_availabilty_set.id

  //custom_data = filebase64("customdata-app.tpl")

  vm_size = "Standard_D2s_v3"
  delete_os_disk_on_termination = true
  
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name = "web-disk"
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name = var.web_host_name
    admin_username = var.web_username
    admin_password = var.web_os_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
  
  
  resource "azurerm_availability_set" "app_availabilty_set" {
  name                = "app_availabilty_set"
  location            = var.location
  resource_group_name = var.resource_group
  platform_fault_domain_count = 2
 }

resource "azurerm_network_interface" "app-net-interface" {
    name = "app-network"
    resource_group_name = var.resource_group
    location = var.location

    ip_configuration{
        name = "app-webserver"
        subnet_id = var.app_subnet_id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_virtual_machine" "app-vm" {
  name = "app-vm"
  location = var.location
  resource_group_name = var.resource_group
  network_interface_ids = [ azurerm_network_interface.app-net-interface.id ]
  availability_set_id = azurerm_availability_set.web_availabilty_set.id

  //custom_data = filebase64("customdata-logic.tpl")

  vm_size = "Standard_D2s_v3"
  delete_os_disk_on_termination = true
  
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name = "app-disk"
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name = var.app_host_name
    admin_username = var.app_username
    admin_password = var.app_os_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

# resource "azurerm_linux_virtual_machine" "web-vm" {
#   name                = "web-vm"
#   location = var.location
#   resource_group_name = var.resource_group
#   network_interface_ids = [ azurerm_network_interface.app-net-interface.id ]
#   availability_set_id = azurerm_availability_set.web_availabilty_set.id
#   size                = "Standard_B1s"
#   admin_username      = "adminuser"

#   custom_data = filebase64("customdata-app.tpl")

#   admin_ssh_key {
#     username   = "adminuser"
#     public_key = file("~/.ssh/mtcazurekey.pub")
#   }

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "UbuntuServer"
#     sku       = "18.04-LTS"
#     version   = "latest"
#   }
# }
  
  

