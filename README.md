---
tags:
  - azure
  - hashicorp
  - hcp-vault
  - hcp-terraform
alias:
  - HashiCorp Vault in Azure

---
[[]]

# HashiCorp Vault in Azure

***CAVEAT***: Many of the issues documented here in the previous version of the `vault-ent-starter` module for Azure has been resolved in version **1.0.0** @ https://registry.terraform.io/modules/hashicorp/vault-ent-starter/azure/1.0.0

Utilizing off-the-shelf **TerraForm** providers and modules, stand up an instance of **Vault Enterprise** in **Azure**.

| TOOL | TYPE | NAME | VERSION / BRANCH | NOTES |
|------|------|------|---------|-------|
| Terraform | Module | [prereqs_quickstart](https://github.com/hashicorp/terraform-azure-vault-ent-starter/tree/main/examples/prereqs_quickstart) | main |  |
| Terraform | Provider | [azurerm](https://registry.terraform.io/providers/hashicorp/azurerm/3.11.0) | v3.11.0 | [GitHub](https://github.com/hashicorp/terraform-provider-azurerm/tree/v3.11.0) |
| Terraform | Module | [vault-ent-starter](https://registry.terraform.io/modules/hashicorp/vault-ent-starter/azure/0.1.1) | v0.1.1 | [GitHub](https://github.com/hashicorp/terraform-azure-vault-ent-starter/tree/v0.1.1) |

## Sequence

Based on the [vault-ent-starter/azure Module GitHub](https://github.com/hashicorp/terraform-azure-vault-ent-starter) documentation @ "[How to Use this Module](https://github.com/hashicorp/terraform-azure-vault-ent-starter#how-to-use-this-module)":

1. Ensure **Azure** credentials [in place](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure). 
2. Use [~/roots/00-prereqs_quickstart](roots/00-prereqs_quickstart/README.md) **Terraform** WorkSpace in this repo (or pull this directory from [GitHub](https://github.com/hashicorp/terraform-azure-vault-ent-starter/tree/main/examples/prereqs_quickstart)) to spin up **Azure** Resources to support Vault
   ```shell
   cd roots/00-prereqs_quickstart/

   terraform init

   terraform plan

   terraform apply

   ```
3. Use [~/roots/01-terraform-azure-ent-starter](roots/01-terraform-azure-ent-starter/README.md) **Terraform** WorkSpace to spin up **HashiCorp** **Vault** as the module has been corrected as per [~/ERRORS.md](ERRORS.md).
   ```shell
   cd roots/01-terraform-azure-ent-starter/

   terraform init

   terraform plan

   terraform apply
   
   ```

***OR***

Use [~/Makefile](Makefile) (Work-in-Progress)

###### Notes

Makefile default target is "**help**", and default "ACTION" is ```plan```
###### Terraform Plan and Apply Prerequsite Azure Resources
```shell
# terraform init
make -f Makefile tf_az_prereqs ACTION=init

# terraform init && terraform plan
make -f Makefile tf_az_prereqs ACTION=plan
# Check the plan

# terraform apply
make -f Makefile tf_az_prereqs ACTION=apply
```

###### Harvest (most) Variables from Prequisite Steps for Vault Enterprise

```shell
make -f Makefile prereqs_harvest > roots/01-terraform-azure-ent-starter/vault.auto.tfvars
```
Some of the variable values in the output @ ```~/roots/01-terraform-azure-ent-starter/vault.auto.tfvars``` will need your manual input as they are not all retrievable from the TFState in the Prerequisite ```~/roots/00-prereqs_quickstart``` WorkSpace

###### Instantiate Vault Enterprise in Azure

```shell
# terraform init
make -f Makefile tf_az_vault ACTION=init

# terraform init && terraform plan
make -f Makefile tf_az_vault ACTION=plan
# Check the plan

# terraform apply
make -f Makefile tf_az_vault ACTION=apply
```

## TF-Provider + TF-Module Errors

The combination of **Terraform** Module ```vault-ent-starter/azure``` (v0.1.1) **Terraform** Provider ```azurerm``` (v3.11.0) netted numerous failures either due to Provider / Module mismatch of required *inputs*/*outputs* **and/or** other Azure related foilbles.  These are documented in **[~/ERRORS.md](ERRORS.md)**.








## 









