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
#   - curl
#   - PGP / pass
################################################################################

########################
# 
########################
default: help
ACTION ?= plan # Default Terraform Action

########################
# CLEAN
########################
.PHONY: clean
clean: #target ## Housekeeping.


.PHONY: tf_az_prereqs
tf_az_prereqs: # target ## Terraform for Azure Prerequisite Resources Quickstart.
	$(call check_defined, ACTION, terraform action to perform)
	@cd roots/00-prereqs_quickstart && \
		terraform init && \
		terraform $(ACTION)


.PHONY: prereqs_harvest
prereqs_harvest: # target ## [WIP] Harvest vars from tf_az_prereqs to tf_az_vault.
	@cd roots/00-prereqs_quickstart && \
		echo 'lb_backend_ca_cert = "$(shell cd roots/00-prereqs_quickstart && terraform show -json | jq -r '.values.outputs.lb_backend_ca_cert.value')"' && \
		echo 'lb_private_ip_address = "<Not in TF State>: Manually enter IP E.g. 10.0.2.253"' && \
		echo 'lb_subnet_id  = "$(shell cd roots/00-prereqs_quickstart && terraform show -json | jq -r '.values.outputs.lb_subnet_id.value')"' && \
		echo 'leader_tls_servername  = "$(shell cd roots/00-prereqs_quickstart && terraform show -json | jq -r '.values.outputs.leader_tls_servername.value')"' && \
		echo 'vault_subnet_id  = "$(shell cd roots/00-prereqs_quickstart && terraform show -json | jq -r '.values.outputs.vault_subnet_id.value')"' && \
		echo 'key_vault_id  = "$(shell cd roots/00-prereqs_quickstart && terraform show -json | jq -r '.values.outputs.key_vault_id.value')"' && \
		echo 'key_vault_ssl_cert_secret_id  = "$(shell cd roots/00-prereqs_quickstart && terraform show -json | jq -r '.values.outputs.key_vault_ssl_cert_secret_id.value')"' && \
		echo 'key_vault_vm_tls_secret_id  = "$(shell cd roots/00-prereqs_quickstart && terraform show -json | jq -r '.values.outputs.key_vault_vm_tls_secret_id.value')"' && \
		echo 'resource_group.location  = "$(shell cd roots/00-prereqs_quickstart && terraform show -json | jq -r '.values.root_module.resources[0].values.location')"' && \
		echo 'resource_group.name  = "$(shell cd roots/00-prereqs_quickstart && terraform show -json | jq -r '.values.root_module.resources[0].values.name')"' && \
		echo 'resource_group.id  = "$(shell cd roots/00-prereqs_quickstart && terraform show -json | jq -r '.values.root_module.resources[0].values.id')"' && \
		echo 'resource_group = {\n  location = "$(shell cd roots/00-prereqs_quickstart && terraform show -json | jq -r '.values.root_module.resources[0].values.location')"\n  name = "$(shell cd roots/00-prereqs_quickstart && terraform show -json | jq -r '.values.root_module.resources[0].values.name')"\n  id = "$(shell cd roots/00-prereqs_quickstart && terraform show -json | jq -r '.values.root_module.resources[0].values.id')"\n}' && \
		echo 'resource_name_prefix = "<Not in TF State>"' && \
		echo 'ssh_public_key = "<Not in TF State: Input your SSH Public Key to access VMs in VMSS>"' && \
		echo 'vault_application_security_group_ids  = $(shell cd roots/00-prereqs_quickstart && terraform show -json | jq -r '.values.outputs.vault_application_security_group_ids.value')' && \
		echo 'vault_license_filepath = "<Not in TF State: Input Path to *.hclic File>"'



.PHONY: test
test: # taget ## [TEST] Test Target.
	@cd roots/00-prereqs_quickstart && \
	terraform show -json | jq -r '.values.outputs.lb_backend_ca_cert.value' && \
	terraform show -json | jq -r '.values.outputs.lb_subnet_id.value' && \
	terraform show -json | jq -r '.values.outputs.leader_tls_servername.value' && \
	terraform show -json | jq -r '.values.outputs.vault_subnet_id.value' && \
	terraform show -json | jq -r '.values.outputs.key_vault_id.value' && \
	terraform show -json | jq -r '.values.outputs.key_vault_ssl_cert_secret_id.value' && \
	terraform show -json | jq -r '.values.outputs.key_vault_vm_tls_secret_id.value' && \
	terraform show -json | jq -r '.values.root_module.resources[0].values.location' && \
	terraform show -json | jq -r '.values.root_module.resources[0].values.name' && \
	terraform show -json | jq -r '.values.root_module.resources[0].values.id' && \
	terraform show -json | jq -r '.values.outputs.vault_application_security_group_ids.value'


.PHONY: tf_az_vault
tf_az_vault: # target ## Terraform for Azure Vault Enterprise
	$(call check_defined, ACTION, terraform action to perform)
	@cd roots/01-terraform-azure-ent-starter && \
		terraform init && \
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