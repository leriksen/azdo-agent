resource "azurerm_virtual_network" "vnet" {
  address_space       = [
    "10.78.0.0/16"
  ]
  location            = azurerm_resource_group.azdo-agent.location
  name                = "vnet"
  resource_group_name = azurerm_resource_group.azdo-agent.name
}

resource "azurerm_subnet" "source" {
  address_prefixes     = [
    "10.78.10.0/24"
  ]
  name                 = "source"
  resource_group_name  = azurerm_resource_group.azdo-agent.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_public_ip" "source" {
  allocation_method   = "Dynamic"
  location            = azurerm_resource_group.azdo-agent.location
  name                = "source"
  resource_group_name = azurerm_resource_group.azdo-agent.name
}

resource "azurerm_network_interface" "source" {
  name                = "source"
  location            = azurerm_resource_group.azdo-agent.location
  resource_group_name = azurerm_resource_group.azdo-agent.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.source.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.source.id
  }
}

resource "azurerm_subnet" "destination" {
  address_prefixes     = [
    "10.78.11.0/24"
  ]
  name                 = "destination"
  resource_group_name  = azurerm_resource_group.azdo-agent.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_public_ip" "destination" {
  allocation_method   = "Dynamic"
  location            = azurerm_resource_group.azdo-agent.location
  name                = "destination"
  resource_group_name = azurerm_resource_group.azdo-agent.name
}

resource "azurerm_network_interface" "destination" {
  name                = "destination"
  location            = azurerm_resource_group.azdo-agent.location
  resource_group_name = azurerm_resource_group.azdo-agent.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.destination.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.destination.id
  }
}
