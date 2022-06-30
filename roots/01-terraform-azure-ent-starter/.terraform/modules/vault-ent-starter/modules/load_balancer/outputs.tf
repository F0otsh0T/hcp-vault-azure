output "backend_address_pool_id" {
#  TF-Module@vault-ent-starter/azure:v0.1.1 + TF-Provider@azurerm:v3.11.0 ERROR
#  Line 4 below fails with azurerm:v3.11.0
#  value = azurerm_application_gateway.vault.backend_address_pool[0].id
#  https://github.com/hashicorp/terraform-provider-azurerm/issues/16855
  value = tolist(azurerm_application_gateway.vault.backend_address_pool)[0].id
#  value = tolist(azurerm_application_gateway.network.backend_address_pool).0.id
}
