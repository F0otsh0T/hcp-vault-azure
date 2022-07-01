---
tags:
  - azure
  - hashicorp
  - hcp-vault
  - hcp-terraform
alias:
  - Using TF Module "vault-ent-starter/azure"

---
[[]]

# Using TF Module "vault-ent-starter/azure"




## 




## 




## Connect to Vault

#### Azure Bastion

1. Verify your **Azure** Bastion resource has attribute set ```sku = "Standard"``` (defaults to ```Basic``` otherwise). This can be done either through **Azure** Portal WebGUI or via **Terraform** @ ```~/roots/00-prereqs_quickstart/vnet/main.tf``` (reapply)
    ```HCL
    resource "azurerm_public_ip" "abs" {
        count = var.abs_address_prefix == null ? 0 : 1

        allocation_method   = "Static"
        location            = var.resource_group.location
        name                = "${var.resource_name_prefix}-vault-abs"
        resource_group_name = var.resource_group.name
        sku                 = "Standard"
        tags                = var.common_tags
    }
    ```
2. Go to your Bastion settings in the **Azure** Portal WebGUI and click on the check boxes for “Native Client Support” (https://docs.microsoft.com/en-us/azure/bastion/connect-native-client-windows#modify-host)
3. Find your VMSS Instance (VM) ID via AZ CLI command (References @ [Link 1](https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-instance-ids), [Link 2](https://docs.microsoft.com/en-us/cli/azure/vmss?view=azure-cli-latest#az-vmss-list), [Link 3](https://github.com/MicrosoftDocs/azure-docs/blob/main/articles/virtual-machine-scale-sets/virtual-machine-scale-sets-manage-cli.md#view-vms-in-a-scale-set))
    ```shell
    az vmss list-instances -g "resourceGroupName" -n "vmScaleSetNAme" > vmss-instances
    ```
4. Enable Bastion Tunnel via this [method](https://docs.microsoft.com/en-us/azure/bastion/connect-native-client-windows#connect-tunnel)
    ```shell
    az network bastion tunnel --name "<BastionName>" --resource-group "<ResourceGroupName>" --target-resource-id "<VMResourceId or VMSSInstanceResourceId>" --resource-port "<TargetVMPort>" --port "<LocalMachinePort>"
    ```
5. Connect "Native Clients" / SSH
    ```shell
    ssh -i ~/.ssh/id_rsa -L <LOCAL_PORT>:<lb_private_ip_address>:<REMOTE_PORT> azureuser@127.0.0.1 -p <LocalMachinePort>
    ```
6. Connect Browser to **Vault** GUI. SSH client can ```port-forward``` and act as sort of a **SOCKS** Proxy. Fire up your web browser and point it to ***https://127.0.0.1:<LOCAL_PORT>*** (where <LOCAL_PORT> is the same as you specified in the ```ssh``` command in **Step 5** above.)

## Vault Init and Unseal

```shell
$ vault status
Key                      Value
---                      -----
Recovery Seal Type       azurekeyvault
Initialized              false
Sealed                   true
Total Recovery Shares    0
Threshold                0
Unseal Progress          0/0
Unseal Nonce             n/a
Version                  1.8.1+ent
Storage Type             raft
HA Enabled               true

$ vault operator init -format=json -t 1 -n 1 | tee keys.json
{
  "unseal_keys_b64": [],
  "unseal_keys_hex": [],
  "unseal_shares": 1,
  "unseal_threshold": 1,
  "recovery_keys_b64": [
    "Loremipsumdolorsitametconsecteturadipiscinge",
    "litExpectoquequidadidquodquaerebamrespondeas",
    "ProfectusinexiliumTubulusstatimnecrespondere",
    "aususDuoRegesconstructiointerreteHicnihilfui",
    "tquodquaereremusSedilleutdixivitioseNonautem"
  ],
  "recovery_keys_hex": [
    "LoremipsumdolorsitametconsecteturadipiscingelitExpectoquequidadidq",
    "uodquaerebamrespondeasProfectusinexiliumTubulusstatimnecrespondere",
    "aususDuoRegesconstructiointerreteHicnihilfuitquodquaereremusSedill",
    "eutdixivitioseNonautemhocigiturneilludquidemAgeinquiesistaparvasun",
    "tQuemTiberinadescensiofestoillodietantogaudioaffecitquantoLSempere"
  ],
  "recovery_keys_shares": 5,
  "recovery_keys_threshold": 3,
  "root_token": "s.Loremipsumdolorsitametco"
}

$ vault status
Key                      Value
---                      -----
Recovery Seal Type       shamir
Initialized              true
Sealed                   false
Total Recovery Shares    5
Threshold                3
Version                  1.8.1+ent
Storage Type             raft
Cluster Name             vault-cluster-69d483f0
Cluster ID               99916931-5963-3683-e477-2957233a13e0
HA Enabled               true
HA Cluster               https://10.0.1.4:8201
HA Mode                  active
Active Since             2022-07-01T03:13:51.080720778Z
Raft Committed Index     1050
Raft Applied Index       1050
Last WAL                 9
```