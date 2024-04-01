resource "azurerm_linux_virtual_machine" "ado" {
  name                = "ado"
  
  resource_group_name = azurerm_resource_group.azdo-agent.name
  location            = azurerm_resource_group.azdo-agent.location
  
  size                = "Standard_B2ats_v2"

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  admin_username = "adminuser"
  admin_ssh_key {
    username   = "adminuser"
    public_key = var.ssh_pub

  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}