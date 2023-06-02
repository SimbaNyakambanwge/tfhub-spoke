#hub
resource "azurerm_virtual_network" "hubvnet" {
  name                = var.hub-vnet-name
  location            = azurerm_resource_group.hub_spoke_rg.location
  resource_group_name = azurerm_resource_group.hub_spoke_rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "topremsub" {
  name                 = "main-subnet"
  resource_group_name  = azurerm_resource_group.hub_spoke_rg.name
  virtual_network_name = azurerm_virtual_network.hubvnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
resource "azurerm_virtual_network_peering" "hubtospoke" {
  name                      = "hubtospoke1"
  resource_group_name       = azurerm_resource_group.hub_spoke_rg.name
  virtual_network_name      = azurerm_virtual_network.hubvnet.name
  remote_virtual_network_id = azurerm_virtual_network.spokevnet.id
}

resource "azurerm_virtual_network_peering" "hubtospoke2" {
  name                      = "hubtospoke2"
  resource_group_name       = azurerm_resource_group.hub_spoke_rg.name
  virtual_network_name      = azurerm_virtual_network.hubvnet.name
  remote_virtual_network_id = azurerm_virtual_network.spokevnet2.id
}

resource "azurerm_network_interface" "hubnic" {
  name                = "hub-nic"
  location            = azurerm_resource_group.hub_spoke_rg.location
  resource_group_name = azurerm_resource_group.hub_spoke_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.topremsub.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "hubvm" {
  name                = "hub-vm"
  resource_group_name = azurerm_resource_group.hub_spoke_rg.name
  location            = azurerm_resource_group.hub_spoke_rg.location
  size                = "Standard_B2s"
  admin_username      = var.username
  admin_password      = var.password
  network_interface_ids = [
   azurerm_network_interface.hubnic.id,
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

resource "azurerm_subnet" "azure-gateway-subnet" {
    name                 = "GatewaySubnet"
    resource_group_name  = var.resourcegroup_name
    virtual_network_name = var.hub-vnet-name
    address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "azure-vpn-gateway1-pip" {
    name                = "vpn-gateway-pip"
    location            = var.location
    resource_group_name = var.resourcegroup_name

    allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "azure-vpn-gateway" {
    name                = "az-vpn-gateway"
    location            = var.location
    resource_group_name = var.resourcegroup_name

    type     = "Vpn"
    vpn_type = "RouteBased"

    active_active = false
    enable_bgp    = false
    sku           = "VpnGw1"

    ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.azure-vpn-gateway1-pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.azure-gateway-subnet.id
    }
    depends_on = [azurerm_public_ip.azure-vpn-gateway1-pip]

}