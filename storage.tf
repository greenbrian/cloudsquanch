resource "azurerm_storage_account" "cloudsquanch" {
  name                = "${random_id.storage_account.keepers.environment_name}${random_id.storage_account.hex}"
  resource_group_name = "${azurerm_resource_group.cloudsquanch.name}"
  location            = "centralus"
  account_type        = "Standard_LRS"

  tags {
    environment = "staging"
  }
}

resource "azurerm_storage_container" "cloudsquanch" {
  name                  = "vhds"
  resource_group_name   = "${azurerm_resource_group.cloudsquanch.name}"
  storage_account_name  = "${azurerm_storage_account.cloudsquanch.name}"
  container_access_type = "private"
}

resource "random_id" "storage_account" {
  keepers = {
    environment_name = "${replace("cloudsquanch","/[\\-_]*/","")}"
  }

  byte_length = 3
}

# trying to copy packer built vhd
resource "azurerm_storage_blob" "cloudsquanch" {
  name = "cloudsquanch_sb.vhd"

  resource_group_name    = "${azurerm_resource_group.cloudsquanch.name}"
  storage_account_name   = "${azurerm_storage_account.cloudsquanch.name}"
  storage_container_name = "${azurerm_storage_container.cloudsquanch.name}"
  source_uri             = "https://bgreencustomimages.blob.core.windows.net/system/Microsoft.Compute/Images/custom-images/packer-osDisk.4c21aa7b-9242-4100-81d7-f28edb33b211.vhd"
  type = "page"
  size = 5120
}
