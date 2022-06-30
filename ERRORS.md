---
tags:
  - azure
  - hashicorp
  - hcp-vault
  - hcp-terraform
alias:
  - Interoperability issues with TF-Module & TF-Provider

---
[[]]

# Interoperability issues with TF-Module & TF-Provider

TF-Module @ **vault-ent-starter/azure**:v0.1.1 & TF-Provider @ **azurerm**:v3.11.0 had some issues when used together.

## VERSIONS

- **[prereqs_quickstart](roots/00-prereqs_quickstart)**:
  - Terraform: ">=0.15"
  - azurerm: ">=2.0"

- **[vault-ent-starter/azure](roots/01-terraform-azure-ent-starter)**: "~>0.1.1"
  - Terraform: ">=0.13"
  - azurerm: "~>3.11.0"

## ERRORS

#### 1. Upper/Lower Case

```shell
❯ terraform validate
╷
│ Error: expected key_permissions.0 to be one of [Backup Create Decrypt Delete Encrypt Get Import List Purge Recover Restore Sign UnwrapKey Update Verify WrapKey], got get
│ 
│   with module.vault-ent-starter.module.iam.azurerm_key_vault_access_policy.vault_msi,
│   on .terraform/modules/vault-ent-starter/modules/iam/main.tf line 20, in resource "azurerm_key_vault_access_policy" "vault_msi":
│   20:     "get",
│ 
╵
╷
│ Error: expected key_permissions.1 to be one of [Backup Create Decrypt Delete Encrypt Get Import List Purge Recover Restore Sign UnwrapKey Update Verify WrapKey], got unwrapKey
│ 
│   with module.vault-ent-starter.module.iam.azurerm_key_vault_access_policy.vault_msi,
│   on .terraform/modules/vault-ent-starter/modules/iam/main.tf line 21, in resource "azurerm_key_vault_access_policy" "vault_msi":
│   21:     "unwrapKey",
│ 
╵
╷
│ Error: expected key_permissions.2 to be one of [Backup Create Decrypt Delete Encrypt Get Import List Purge Recover Restore Sign UnwrapKey Update Verify WrapKey], got wrapKey
│ 
│   with module.vault-ent-starter.module.iam.azurerm_key_vault_access_policy.vault_msi,
│   on .terraform/modules/vault-ent-starter/modules/iam/main.tf line 22, in resource "azurerm_key_vault_access_policy" "vault_msi":
│   22:     "wrapKey",
│ 
╵
╷
│ Error: expected secret_permissions.0 to be one of [Backup Delete Get List Purge Recover Restore Set], got get
│ 
│   with module.vault-ent-starter.module.iam.azurerm_key_vault_access_policy.vault_msi,
│   on .terraform/modules/vault-ent-starter/modules/iam/main.tf line 26, in resource "azurerm_key_vault_access_policy" "vault_msi":
│   26:     "get",
│ 
╵
╷
│ Error: expected secret_permissions.0 to be one of [Backup Delete Get List Purge Recover Restore Set], got get
│ 
│   with module.vault-ent-starter.module.iam.azurerm_key_vault_access_policy.load_balancer_msi,
│   on .terraform/modules/vault-ent-starter/modules/iam/main.tf line 72, in resource "azurerm_key_vault_access_policy" "load_balancer_msi":
│   72:     "get",
│ 
╵
```

Fixed above errors by editing the downloaded (via ```terraform init```) **Terraform** Modules (@**[registry.terraform.io](https://registry.terraform.io/modules/hashicorp/vault-ent-starter/azure/0.1.1)**) file ```.terraform/modules/vault-ent-starter/modules/iam/main.tf``` and changing first letter to **Upper Case**.

#### 2. Missing Attributes

- ```azurerm_application_gateway.vault.identity.type```
- ```azurerm_application_gateway.vault.request_routing_rule.priority```

```shell
❯ terraform validate
╷
│ Error: Missing required argument
│ 
│   on .terraform/modules/vault-ent-starter/modules/load_balancer/main.tf line 47, in resource "azurerm_application_gateway" "vault":
│   47:   identity {
│ 
│ The argument "type" is required, but no definition was found.
╵
╷
│ Error: Missing required argument
│ 
│   on .terraform/modules/vault-ent-starter/modules/load_balancer/main.tf line 103, in resource "azurerm_application_gateway" "vault":
│  103:   request_routing_rule {
│ 
│ The argument "priority" is required, but no definition was found.
╵
```

In the ```.terraform/modules/vault-ent-starter/modules/load_balancer/main.tf``` file, added ```type = "UserAssigned"``` and ```priority = "1"``` into their respective stanzas:

```HCL
  identity {
    identity_ids = var.identity_ids
    type         = "UserAssigned"
  }

  .
  .
  .

  request_routing_rule {
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.backend_http_setting_name
    http_listener_name         = local.http_listener_name
    name                       = "${var.resource_name_prefix}-vault"
    rule_type                  = "Basic"
    priority                   = "1"
  }
```

#### 3. Output

```shell
❯ terraform validate
╷
│ Error: Cannot index a set value
│ 
│   on .terraform/modules/vault-ent-starter/modules/load_balancer/outputs.tf line 2, in output "backend_address_pool_id":
│    2:   value = azurerm_application_gateway.vault.backend_address_pool[0].id
│ 
│ Block type "backend_address_pool" is represented by a set of objects, and set elements
│ do not have addressable keys. To find elements matching specific criteria, use a "for"
│ expression with an "if" clause.
╵
```

###### Reference Links Related to this problem:

- https://github.com/hashicorp/terraform-provider-azurerm/issues/16855
- https://github.com/MicrosoftDocs/azure-dev-docs/issues/770
- https://github.com/MicrosoftDocs/azure-dev-docs/issues/752
- https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_application_gateway_backend_address_pool_association

Based on above information, changed ```.terraform/modules/vault-ent-starter/modules/load_balancer/outputs.tf``` to:

```HCL
output "backend_address_pool_id" {
#  value = azurerm_application_gateway.vault.backend_address_pool[0].id
  value = tolist(azurerm_application_gateway.vault.backend_address_pool)[0].id
#  
}
```

The **ID** harvested in this step really should be keyed from the ```name``` attribute of the ```backend_address_pool``` as there could be more than one pool and the **ID** you want may not be from the first pool. Assumption is there is only one pool as this is a freshly created but this may not always be true.

#### 4. Azure Permissions

It appears that **[vault-ent-starter/azure]()** requires ***```Owner```*** level permissions.  Probably worth exploring the use of Azure ***```service principal```*** here.

```shell
❯ terraform validate
╷
│ Error: authorization.RoleDefinitionsClient#CreateOrUpdate: Failure responding to request: StatusCode=403 -- Original Error: autorest/azure: Service returned an error. Status=403 Code="AuthorizationFailed" Message="The client 'user@fqdn' with object id 'Loremips-umdo-lors-itam-etconsectetu' does not have authorization to perform action 'Microsoft.Authorization/roleDefinitions/write' over scope '/subscriptions/radipisc-inge-litE-xpec-toquequidadi' or the scope is invalid. If access was recently granted, please refresh your credentials."
│ 
│   with module.vault-ent.module.iam.azurerm_role_definition.vault[0],
│   on .terraform/modules/vault-ent/modules/iam/main.tf line 30, in resource "azurerm_role_definition" "vault":
│   30: resource "azurerm_role_definition" "vault" {
│ 
╵
```

For now, was able to have ***```Owner```*** level permissions granted to me to move past this error

#### 5. Application Gateway Non-Zonal Public IP

This problem appears to be a combination of **Azure** Region / Availability Zone Foilbles and **Terraform** Module-Provider interoperability issues. Depending on your **Azure** Region, you may or may not have multiple Availability Zones (or any AZ's for that matter) and currently **Azure** "[doesn't expose an automated means of determining which Azure Region supports which Availability Zones...](https://github.com/hashicorp/terraform-provider-azurerm/issues/16470#issuecomment-1104889806)" - manually reference them here @ https://azure.microsoft.com/en-us/global-infrastructure/geographies/#geographies

###### Reference Links:

- https://github.com/hashicorp/terraform-provider-azurerm/issues/16470
- https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/3.0-upgrade-guide#behavioural-updates
- https://azure.microsoft.com/en-us/global-infrastructure/geographies/#geographies

```shell
❯ terraform validate
╷
│ Error: creating Application Gateway: (Name "mysupercoolapp" / Resource Group "mysupercoolapp"): network.ApplicationGatewaysClient#CreateOrUpdate: Failure sending request: StatusCode=400 -- Original Error: Code="ZonalApplicationGatewayCannotReferenceNoZonePublicIp" Message="Zonal Application Gateway /subscriptions/radipisc-inge-litE-xpec-toquequidadi/resourceGroups/mysupercoolapp/providers/Microsoft.Network/applicationGateways/mysupercoolapp with zones 2, 3, 1 cannot reference a non-zonal public ip /subscriptions/radipisc-inge-litE-xpec-toquequidadi/resourceGroups/mysupercoolapp/providers/Microsoft.Network/publicIPAddresses/mysupercoolapp-lb-public. The IP should use all zones used by the Application Gateway." Details=[]
│ 
│   with module.vault-ent.module.load_balancer.azurerm_application_gateway.vault,
│   on .terraform/modules/vault-ent/modules/load_balancer/main.tf line 21, in resource "azurerm_application_gateway" "vault":
│   21: resource "azurerm_application_gateway" "vault" {
│ 
╵
```

In this particular case, Region is ```eastus``` so there are 3 ```zones``` to account for - added ```zones = [1,2,3]``` to ```.terraform/modules/vault-ent/modules/load_balancer/main.tf```:

```HCL
resource "azurerm_public_ip" "vault_lb" {
  allocation_method   = "Static"
  location            = var.resource_group.location
  name                = "${var.resource_name_prefix}-vault-lb-public"
  resource_group_name = var.resource_group.name
  sku                 = "Standard"
  tags                = var.common_tags
  zones               = [1,2,3]
}
```
