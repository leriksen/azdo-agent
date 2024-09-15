resource "azurerm_virtual_network" "vnet" {
  address_space       = [
    "10.77.0.0/16"
  ]
  location            = azurerm_resource_group.azdo-agent.location
  name                = "vnet"
  resource_group_name = azurerm_resource_group.azdo-agent.name
}

resource "azurerm_subnet" "public" {
  address_prefixes     = [
    "10.77.10.0/24"
  ]
  name                 = "public"
  resource_group_name  = azurerm_resource_group.azdo-agent.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_public_ip" "ip" {
  allocation_method   = "Dynamic"
  location            = azurerm_resource_group.azdo-agent.location
  name                = "public"
  resource_group_name = azurerm_resource_group.azdo-agent.name
  domain_name_label   = "ado"
}

resource "azurerm_network_interface" "nic" {
  name                = "nic"
  location            = azurerm_resource_group.azdo-agent.location
  resource_group_name = azurerm_resource_group.azdo-agent.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip.id
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "ado"
  location            = azurerm_resource_group.azdo-agent.location
  resource_group_name = azurerm_resource_group.azdo-agent.name
}

resource "azurerm_network_security_rule" "rules" {
  for_each                    = toset(module.global.ado_control_ports)
  name                        = "port_${each.value}"
  priority                    = 100 + index(module.global.ado_control_ports, each.value)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.azdo-agent.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_subnet_network_security_group_association" "nsg_to_subnet" {
  network_security_group_id = azurerm_network_security_group.nsg.id
  subnet_id                 = azurerm_subnet.public.id
}
