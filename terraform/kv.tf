resource "azurerm_key_vault" "kv" {
  location                   = azurerm_resource_group.azdo-agent.location
  name                       = "destinationkv"
  resource_group_name        = azurerm_resource_group.azdo-agent.name
  sku_name                   = "standard"
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  enable_rbac_authorization  = true
  purge_protection_enabled   = false
  soft_delete_retention_days = 7
  public_network_access_enabled = false
}

resource "azurerm_role_assignment" "kvsecretofficer" {
  principal_id = data.azurerm_client_config.current.object_id
  scope = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"
}

resource "azurerm_role_assignment" "sckvsecretofficer" {
  principal_id = "49089378-3b8e-4dbe-8b19-9f31d3c7645a"
  scope = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"
}

resource "azurerm_key_vault_secret" "secret" {
  depends_on = [
    azurerm_role_assignment.kvsecretofficer
  ]
  key_vault_id = azurerm_key_vault.kv.id
  name         = "secret"
  value        = "access"
}

resource "azurerm_private_endpoint" "pe" {
  location                      = azurerm_resource_group.azdo-agent.location
  name                          = "kv-pe"
  resource_group_name           = azurerm_resource_group.azdo-agent.name
  subnet_id                     = azurerm_subnet.destination.id
  private_service_connection {
    is_manual_connection           = false
    name                           = "kv-pe"
    private_connection_resource_id = azurerm_key_vault.kv.id
    subresource_names = [
      "vault"
    ]
  }
  private_dns_zone_group {
    name                 = "kve-dns-zone-group"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.privdns.id
    ]
  }
}

resource "azurerm_private_dns_zone" "privdns" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.azdo-agent.name
}

#resource "azurerm_private_dns_zone_virtual_network_link" "dns_vnet_link" {
#  name                  = "kv-link"
#  resource_group_name   = azurerm_resource_group.azdo-agent.name
#  private_dns_zone_name = azurerm_private_dns_zone.privdns.name
#  virtual_network_id    = azurerm_virtual_network.vnet.id
#}