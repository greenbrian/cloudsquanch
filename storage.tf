resource "azurerm_storage_account" "cloudsquanch" {
  name                = "${random_id.storage_account.keepers.environment_name}${random_id.storage_account.hex}"
  resource_group_name = "${data.terraform_remote_state.azure_ubuntu_demo_rg.azure_ubuntu_demo_rg}"
  location            = "centralus"
  account_type        = "Standard_LRS"

  tags {
    environment = "staging"
  }
}

resource "azurerm_storage_container" "cloudsquanch" {
  name                  = "vhds"
  resource_group_name   = "${data.terraform_remote_state.azure_ubuntu_demo_rg.azure_ubuntu_demo_rg}"
  storage_account_name  = "${azurerm_storage_account.cloudsquanch.name}"
  container_access_type = "private"
}

resource "random_id" "storage_account" {
  keepers = {
    environment_name = "${replace("cloudsquanch","/[\\-_]*/","")}"
  }

  byte_length = 3
}
