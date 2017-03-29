# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}

provider "atlas" {
    token = "${var.atlas_token}"
}

data "terraform_remote_state" "azure_ubuntu_demo_rg" {
  backend = "atlas"
  config {
    name = "bgreen/azure-ubuntu-demo-rg"
  }
}


resource "azurerm_virtual_network" "cloudsquanch" {
  name                = "cloudsquanch_vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "centralus"
  resource_group_name = "${data.terraform_remote_state.azure_ubuntu_demo_rg.azure_ubuntu_demo_rg}"
}

resource "azurerm_subnet" "cloudsquanch" {
  name                 = "cloudsquanch_subnet"
  resource_group_name  = "${data.terraform_remote_state.azure_ubuntu_demo_rg.azure_ubuntu_demo_rg}"
  virtual_network_name = "${azurerm_virtual_network.cloudsquanch.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "cloudsquanch" {
  name                         = "cloudsquanch_pubip"
  location                     = "centralus"
  resource_group_name          = "${data.terraform_remote_state.azure_ubuntu_demo_rg.azure_ubuntu_demo_rg}"
  public_ip_address_allocation = "static"

  tags {
    environment = "Production"
  }
}

resource "azurerm_network_interface" "cloudsquanch" {
  name                = "cloudsquanch_nic"
  location            = "centralus"
  resource_group_name = "${data.terraform_remote_state.azure_ubuntu_demo_rg.azure_ubuntu_demo_rg}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.cloudsquanch.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.cloudsquanch.id}"
  }
}


resource "azurerm_virtual_machine" "cloudsquanch" {
  name                  = "cloudsquanch_vm"
  location              = "centralus"
  resource_group_name   = "${data.terraform_remote_state.azure_ubuntu_demo_rg.azure_ubuntu_demo_rg}"
  network_interface_ids = ["${azurerm_network_interface.cloudsquanch.id}"]
  vm_size               = "Standard_A0"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name          = "myosdisk1"
    vhd_uri       = "${azurerm_storage_account.cloudsquanch.primary_blob_endpoint}${azurerm_storage_container.cloudsquanch.name}/myosdisk1.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags {
    environment = "staging"
  }
}
