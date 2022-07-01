################################################################################
# VAULT ON AZURE
#
# @file
# @version 0.1
#
##########
# PREREQUISITES
#   - AZ CLI
#   - Vault CLI
#   - make
#   - jq
################################################################################

########################
# DEFAULTS
########################
default: help
ACTION ?= plan # Default Terraform Action

########################
# CLEAN
########################
.PHONY: clean
clean: #target ## Housekeeping.

########################
# CREATE PREREQUISITE AZURE RESOURCES FOR VAULT ENTERPRISE
########################
.PHONY: tf_az_prereqs
tf_az_prereqs: # target ## Terraform for Azure Prerequisite Resources Quickstart.
	$(call check_defined, ACTION, terraform action to perform)
	@cd roots/00-prereqs_quickstart && \
		terraform $(ACTION)

########################
# HARVEST VARIABLES NEEDED FOR NEXT TERRAFORM WORKSPACE
# SOME VARIABLES WILL REQUIRE MANUAL INPUT
########################
.PHONY: prereqs_harvest
prereqs_harvest: # target ## [WIP] Harvest vars from tf_az_prereqs to tf_az_vault.
	@cd roots/00-prereqs_quickstart && \
		printf "%s %s" 'lb_backend_ca_cert = $(shell cd roots/00-prereqs_quickstart && terraform show -json | jq '.values.outputs.lb_backend_ca_cert.value')' && echo '' && \
		echo 'lb_private_ip_address = "[**-=>>EDIT ME<<=-**<Not in TF State>: Manually enter IP E.g. 10.0.2.253>********************************]"' && \
		echo 'lb_subnet_id  = "$(shell cd roots/00-prereqs_quickstart && terraform show -json | jq -r '.values.outputs.lb_subnet_id.value')"' && \
		echo 'leader_tls_servername  = "$(shell cd roots/00-prereqs_quickstart && terraform show -json | jq -r '.values.outputs.leader_tls_servername.value')"' && \
		echo 'vault_subnet_id  = "$(shell cd roots/00-prereqs_quickstart && terraform show -json | jq -r '.values.outputs.vault_subnet_id.value')"' && \
		echo 'key_vault_id  = "$(shell cd roots/00-prereqs_quickstart && terraform show -json | jq -r '.values.outputs.key_vault_id.value')"' && \
		echo 'key_vault_ssl_cert_secret_id  = "$(shell cd roots/00-prereqs_quickstart && terraform show -json | jq -r '.values.outputs.key_vault_ssl_cert_secret_id.value')"' && \
		echo 'key_vault_vm_tls_secret_id  = "$(shell cd roots/00-prereqs_quickstart && terraform show -json | jq -r '.values.outputs.key_vault_vm_tls_secret_id.value')"' && \
		echo 'resource_group = {\n  location = "$(shell cd roots/00-prereqs_quickstart && terraform show -json | jq -r '.values.root_module.resources[0].values.location')"\n  name = "$(shell cd roots/00-prereqs_quickstart && terraform show -json | jq -r '.values.root_module.resources[0].values.name')"\n  id = "$(shell cd roots/00-prereqs_quickstart && terraform show -json | jq -r '.values.root_module.resources[0].values.id')"\n}' && \
		echo 'resource_name_prefix = "$(shell cd roots/00-prereqs_quickstart && terraform show -json | jq -r '.values.root_module.resources[0].values.name' | sed 's/\-vault//g')"' && \
		echo 'ssh_public_key = "[**-=>>EDIT ME<<=-**<Not in TF State: Input your RSA SSH Public Key to access VMs in VMSS>********************************]"' && \
		echo 'vault_application_security_group_ids  = $(shell cd roots/00-prereqs_quickstart && terraform show -json | jq '.values.outputs.vault_application_security_group_ids.value')' && \
		echo 'vault_license_filepath = "[**-=>>EDIT ME<<=-**<Not in TF State: Input Path to *.hclic File>********************************]"'

########################
# TEST TARGET
########################
.PHONY: test
test: # target ## [TEST] Test Target.
	@cd roots/00-prereqs_quickstart && \
		terraform show -json | jq '.values.outputs.lb_backend_ca_cert.value' && \
		terraform show -json | jq -r '.values.outputs.lb_subnet_id.value' && \
		terraform show -json | jq -r '.values.outputs.leader_tls_servername.value' && \
		terraform show -json | jq -r '.values.outputs.vault_subnet_id.value' && \
		terraform show -json | jq -r '.values.outputs.key_vault_id.value' && \
		terraform show -json | jq -r '.values.outputs.key_vault_ssl_cert_secret_id.value' && \
		terraform show -json | jq -r '.values.outputs.key_vault_vm_tls_secret_id.value' && \
		terraform show -json | jq -r '.values.root_module.resources[0].values.location' && \
		terraform show -json | jq -r '.values.root_module.resources[0].values.name' && \
		terraform show -json | jq -r '.values.root_module.resources[0].values.id' && \
		terraform show -json | jq '.values.outputs.vault_application_security_group_ids.value'

########################
# CREATE VAULT ENTERPRISE IN AZURE
########################
.PHONY: tf_az_vault
tf_az_vault: # target ## Terraform for Azure Vault Enterprise
	$(call check_defined, ACTION, terraform action to perform)
	@cd roots/01-terraform-azure-ent-starter && \
		terraform $(ACTION)

########################
# HELP
# REF GH @ jen20/hashidays-nyc/blob/master/terraform/GNUmakefile
########################
.PHONY: help
help: #target ## [DEFAULT] Display help for this Makefile.
	@echo "Valid make targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

check_defined = \
		$(strip $(foreach 1,$1, \
		$(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
		$(if $(value $1),, \
		$(error Undefined $1$(if $2, ($2))))