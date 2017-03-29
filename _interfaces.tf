variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "admin_username" {}
variable "admin_password" {}
variable "atlas_token" {}

output "Cloudsquanch Public IP" {
  value = "ssh://${azurerm_public_ip.cloudsquanch.ip_address}"
}
