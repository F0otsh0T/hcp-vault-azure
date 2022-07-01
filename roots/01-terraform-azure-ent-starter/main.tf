provider "azurerm" {
  features {
    virtual_machine_scale_set {
      # This can be enabled to sequentially replace instances when
      # application configuration updates (e.g. changed user_data)
      # are made
      roll_instances_when_required = false
    }
  }
}

module "vault-ent-starter" {
  source  = "hashicorp/vault-ent-starter/azure"
  version = "~>0.1.1"

# (Required when cert in 'key_vault_vm_tls_secret_id' is signed by a private CA) Certificate authority cert (PEM)
#  lb_backend_ca_cert = file("./cacert.pem")
  lb_backend_ca_cert = var.lb_backend_ca_cert

  # IP address (in Vault subnet) for Vault load balancer
  # (example value here is fine to use alongside the default values in the example vnet module)
  lb_private_ip_address = var.lb_private_ip_address

  # Virtual Network subnet for Vault load balancer
  lb_subnet_id = var.lb_subnet_id

  # One of the DNS Subject Alternative Names on the cert in key_vault_vm_tls_secret_id
  leader_tls_servername = var.leader_tls_servername

  # Virtual Network subnet for Vault VMs
  vault_subnet_id = var.vault_subnet_id

  # Key Vault (containing Vault TLS bundle in Key Vault Certificate and Key Vault Secret form)
  key_vault_id = var.key_vault_id

  # Key Vault Certificate containing TLS certificate for load balancer
  key_vault_ssl_cert_secret_id = var.key_vault_ssl_cert_secret_id

  # Key Vault Secret containing TLS certificate for Vault VMs
  key_vault_vm_tls_secret_id = var.key_vault_vm_tls_secret_id

  # Resource group object in which resources will be deployed
  resource_group = var.resource_group

  # Prefix for resource names
  resource_name_prefix = var.resource_name_prefix

  # RSA SSH Public Key (authentication to Vault servers)
  # Follow steps on private/public key creation (https://docs.microsoft.com/en-us/azure/virtual-machines/linux/mac-create-ssh-keys)
  ssh_public_key = var.ssh_public_key

  # Application Security Group IDs for Vault VMs
  vault_application_security_group_ids = var.vault_application_security_group_ids

  # Path to the Vault Enterprise license file
  vault_license_filepath = var.vault_license_filepath
}

