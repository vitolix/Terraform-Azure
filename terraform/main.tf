# Main file
# Create resource group
resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = "rg-test-20240417"
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "vNetwork-test-20240417"
  address_space       = ["10.0.0.0/20"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name			= "internal"
  resource_group_name	= azurerm_resource_group.rg.name
  virtual_network_name	= azurerm_virtual_network.vnet.name
  address_prefixes	= ["10.0.2.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "public_ip" {
  for_each		= var.vm_map
  name			= "${each.value.name}-publicIP"
  location		= azurerm_resource_group.rg.location
  resource_group_name	= azurerm_resource_group.rg.name
  allocation_method	= "Dynamic"
}

# Create network interface
resource "azurerm_network_interface" "nic" {
  for_each		= var.vm_map
  name			= "${each.value.name}-nic"
  location		= azurerm_resource_group.rg.location
  resource_group_name	= azurerm_resource_group.rg.name

  ip_configuration {
    name				= "internal"
    subnet_id				= azurerm_subnet.subnet.id
    private_ip_address_allocation	= "Dynamic"
    public_ip_address_id		= azurerm_public_ip.public_ip[each.key].id
  }
}

# Create 3 virtual machines
resource "azurerm_linux_virtual_machine" "vm" {
  for_each		= var.vm_map
  name                  = each.value.name
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  size                  = each.value.size

  network_interface_ids = [azurerm_network_interface.nic[each.key].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name  = "hostname"
  admin_username = var.username
  admin_password = each.value.admin_password

  admin_ssh_key {
    username   = var.username
    public_key = jsondecode(azapi_resource_action.ssh_public_key_gen.output).publicKey
  }
}
