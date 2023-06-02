#spoke2
resource "azurerm_virtual_network" "spokevnet2" {
  name                = var.spoke-vnet-name-2
  location            = azurerm_resource_group.hub_spoke_rg.location
  resource_group_name = azurerm_resource_group.hub_spoke_rg.name
  address_space       = ["10.2.0.0/16"]
}

resource "azurerm_subnet" "spokesub2" {
   name                 = "spoke2-subnet"
  resource_group_name  = azurerm_resource_group.hub_spoke_rg.name
  virtual_network_name = azurerm_virtual_network.spokevnet2.name
  address_prefixes     = ["10.2.1.0/24"]
}

resource "azurerm_virtual_network_peering" "spoke2tohub" {
  name                      = "spoke2tohub"
  resource_group_name       = azurerm_resource_group.hub_spoke_rg.name
  virtual_network_name      = azurerm_virtual_network.spokevnet2.name
  remote_virtual_network_id = azurerm_virtual_network.hubvnet.id
}

resource "azurerm_network_interface" "spoke2nic" {
  name                = "spoke2nic"
  location            = azurerm_resource_group.hub_spoke_rg.location
  resource_group_name = azurerm_resource_group.hub_spoke_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.spokesub2.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "spoke2vm" {
  name                = "spoke2-vm"
  resource_group_name = azurerm_resource_group.hub_spoke_rg.name
  location            = azurerm_resource_group.hub_spoke_rg.location
  size                = "Standard_B2s"
  admin_username      = var.username
  admin_password      = var.password
  network_interface_ids = [
    azurerm_network_interface.spoke2nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}