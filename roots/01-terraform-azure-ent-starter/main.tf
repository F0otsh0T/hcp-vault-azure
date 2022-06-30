# main.tf

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
  version = "0.1.1"

  # (Required when cert in 'key_vault_vm_tls_secret_id' is signed by a private CA) Certificate authority cert (PEM)
  lb_backend_ca_cert = file("./cacert.pem")

  # IP address (in Vault subnet) for Vault load balancer
  # (example value here is fine to use alongside the default values in the example vnet module)
  lb_private_ip_address = "10.0.2.253"

  # Virtual Network subnet for Vault load balancer
  lb_subnet_id = "/subscriptions/.../resourceGroups/myresourcegroupname/providers/Microsoft.Network/virtualNetworks/myvnetname/subnets/mylbsubnetname"

  # One of the DNS Subject Alternative Names on the cert in key_vault_vm_tls_secret_id
  leader_tls_servername = "vault.server.com"

  # Virtual Network subnet for Vault VMs
  vault_subnet_id = "/subscriptions/.../resourceGroups/myresourcegroupname/providers/Microsoft.Network/virtualNetworks/myvnetname/subnets/mysubnetname"

  # Key Vault (containing Vault TLS bundle in Key Vault Certificate and Key Vault Secret form)
  key_vault_id = "/subscriptions/.../resourceGroups/.../providers/Microsoft.KeyVault/vaults/..."

  # Key Vault Certificate containing TLS certificate for load balancer
  key_vault_ssl_cert_secret_id = "https://mykeyvaultname.vault.azure.net/secrets/dev-vault-cert/12ab12ab12ab12ab12ab12ab12ab12ab"

  # Key Vault Secret containing TLS certificate for Vault VMs
  key_vault_vm_tls_secret_id = "https://mykeyvaultname.vault.azure.net/secrets/mykeyvaultsecretname/12ab12ab12ab12ab12ab12ab12ab12ab"

  # Resource group object in which resources will be deployed
  resource_group = {
    id       = "/subscriptions/.../resourceGroups/myresourcegroupname"
    location = "eastus"
    name     = "myresourcegroupname"
  }

  # Prefix for resource names
  resource_name_prefix = "dev"

  # SSH public key (for authentication to Vault servers)
  ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADA..."

  # Application Security Group IDs for Vault VMs
  vault_application_security_group_ids = ["/subscriptions/.../resourceGroups/myresourcegroupname/providers/Microsoft.Network/applicationSecurityGroups/mysecuritygroupname"]

  # Path to the Vault Enterprise license file
  vault_license_filepath = "./vault.hclic"
}







