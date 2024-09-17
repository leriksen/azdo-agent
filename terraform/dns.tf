resource "azurerm_dns_zone" "dnszone" {
  name                = "australiasoutheast.cloudapp.azure.com"
  resource_group_name = azurerm_resource_group.azdo-agent.name
}

resource "azurerm_dns_a_record" "ado" {
  name                = "ado"
  zone_name           = azurerm_dns_zone.dnszone.name
  resource_group_name = azurerm_resource_group.azdo-agent.name
  ttl                 = 300
  records             = [
    azurerm_linux_virtual_machine.ado.public_ip_address
  ]
}