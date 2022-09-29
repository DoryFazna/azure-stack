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

resource "azurerm_network_interface" "app-net-interface" {
    name = "app-network"
    resource_group_name = var.resource_group
    location = var.location

    ip_configuration{
        name = "app-webserver"
        subnet_id = var.app_subnet_id
        private_ip_address_allocation = "Dynamic"
        //private_ip_address = "192.168.2.11"
        //public_ip_address_id          = azurerm_public_ip.mtc-ip2.id
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

resource "azurerm_network_interface" "app-net-interface2" {
    name = "app-network2"
    resource_group_name = var.resource_group
    location = var.location

    ip_configuration{
        name = "app-webserver"
        subnet_id = var.app_subnet_id
        private_ip_address_allocation = "Dynamic"
        //private_ip_address = "192.168.2.11"
        //public_ip_address_id          = azurerm_public_ip.mtc-ip2.id
    }
}

resource "azurerm_linux_virtual_machine" "app-vm2" {
   name                = "app-vm2"
   location = var.location
   resource_group_name = var.resource_group
   network_interface_ids = [ azurerm_network_interface.app-net-interface2.id ]
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



 #-------------------------- load balancers for web --------------------------

 resource "azurerm_lb" "mtc-lb" {
  name                = "mtc-lb"
  location            = var.location
  resource_group_name = var.resource_group
  

  frontend_ip_configuration {
    name                 = "FrontendIPForWebLoadBalancer"
    private_ip_address = "192.168.2.11"
    private_ip_address_allocation = "Static"
    subnet_id = var.app_subnet_id
  }

}


resource "azurerm_lb_backend_address_pool" "mtc-bp" {
  loadbalancer_id = azurerm_lb.mtc-lb.id
  name            = "mtc-bp"
  depends_on = [
    azurerm_lb.mtc-lb,
    azurerm_availability_set.app_availabilty_set
  ]
}

resource "azurerm_network_interface_backend_address_pool_association" "mtc-bp-asso1" {
  network_interface_id    = azurerm_network_interface.app-net-interface.id
  ip_configuration_name   = "app-webserver"
  backend_address_pool_id = azurerm_lb_backend_address_pool.mtc-bp.id
}

resource "azurerm_network_interface_backend_address_pool_association" "mtc-bp-asso2" {
  network_interface_id    = azurerm_network_interface.app-net-interface2.id
  ip_configuration_name   = "app-webserver"
  backend_address_pool_id = azurerm_lb_backend_address_pool.mtc-bp.id
}

resource "azurerm_lb_probe" "mtc-lbp" {
  loadbalancer_id = azurerm_lb.mtc-lb.id
  name            = "mtc-lbp"
  port            = 5001
  depends_on = [
    azurerm_lb.mtc-lb
  ]
}

resource "azurerm_lb_rule" "mtc-lbrule" {
  loadbalancer_id = azurerm_lb.mtc-lb.id
  name                           = "mtc-lbrule"
  protocol                       = "Tcp"
  frontend_port                  = 5001
  backend_port                   = 5001
  frontend_ip_configuration_name = "FrontendIPForWebLoadBalancer"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.mtc-bp.id]
  probe_id                       = azurerm_lb_probe.mtc-lbp.id
  depends_on = [
    azurerm_lb.mtc-lb,
    azurerm_availability_set.app_availabilty_set,
    azurerm_lb_probe.mtc-lbp

  ]
}
