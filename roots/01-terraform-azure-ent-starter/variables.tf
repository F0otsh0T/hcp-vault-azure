# variables.tf

variable "lb_backend_ca_cert" {
  description = "Load Balancer Backend CA Cert"
  sensitive   = true
  type        = string
}

variable "lb_private_ip_address" {
  default     = "10.0.2.253"
  description = "IP Address (in Vault Subnet) for Vault load balancer"
  type        = string
}

variable "lb_subnet_id" {
  description = "Virtual Network Subnet ID for Vault Load Balancer"
  type        = string
}

variable "leader_tls_servername" {
  default     = "vault.server.com"
  description = "One of the DNS Subject Alternative Names on the cert in key_vault_vm_tls_secret_id"
  type        = string
}

variable "vault_subnet_id" {
  description = "Virtual Network Subnet ID for Vault VMs"
  type        = string
}

variable "key_vault_id" {
  description = "Key Vault (containing Vault TLS bundle in Key Vault Certificate and Key Vault Secret form)"
  type        = string
}

variable "key_vault_ssl_cert_secret_id" {
  description = "Key Vault Certificate containing TLS Certificate for Load Balancer"
  type        = string
}

variable "key_vault_vm_tls_secret_id" {
  description = "Key Vault Secret containing TLS Certificate for Vault VMs"
  type        = string
}

variable "resource_group" {
  default     = null
  description = "Azure Resource Group object in which Resources will be deployed"
  type        = object({
    location = string
    name     = string
    id       = string
  })
}

variable "resource_name_prefix" {
  default     = "dev"
  description = "Prefix applied to Resource Names"
  type        = string
  # azurerm_key_vault name must not exceed 24 characters and has this as a prefix
  validation {
    condition     = length(var.resource_name_prefix) < 16 && (replace(var.resource_name_prefix, " ", "") == var.resource_name_prefix)
    error_message = "The resource_name_prefix value must be fewer than 16 characters and may not contain spaces."
  }
}

variable "ssh_public_key" {
  default     = "null"
  description = "(RSA) SSH Public Key (Authentication to Vault VM Servers)"
  sensitive   = true
  type        = string
}

variable "vault_application_security_group_ids" {
  description = "Application Security Group IDs for Vault VMs"
  type        = list(string)
}

variable "vault_license_filepath" {
  default     = "./vault.hclic"
  description = "Path to the Vault Enterprise License File"
  sensitive   = true
  type        = string
}








