# resource "azurerm_key_vault" "kv" {
#   location                  = azurerm_resource_group.azdo-agent.location
#   name                      = "azdoagentkv01"
#   resource_group_name       = azurerm_resource_group.azdo-agent.name
#   sku_name                  = "standard"
#   tenant_id                 = data.azurerm_client_config.current.tenant_id
#   enable_rbac_authorization = true
# }
#
# resource "azurerm_role_assignment" "kv_data" {
#   principal_id = data.azurerm_client_config.current.object_id
#   scope        = azurerm_key_vault.kv.id
#   role_definition_name = "Key Vault Secrets Officer"
# }
#
# resource "azurerm_key_vault_secret" "token" {
#   depends_on = [
#     azurerm_role_assignment.kv_data
#   ]
#   key_vault_id = azurerm_key_vault.kv.id
#   name         = "token"
#   value        = var.token
# }