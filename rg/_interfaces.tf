variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}

output "azure_ubuntu_demo_rg" {
  value = "${azurerm_resource_group.cloudsquanch.name}"
}
