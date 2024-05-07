# Variables file
# test
variable "resource_group_location" {
  type        = string
  default     = "eastus"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "username" {
  type        = string
  description = "The username for the local account that will be created on the new VM."
  default     = "azureadmin"
}

variable "prefix" {
  type        = string
  default     = "win-vm-iis"
  description = "Prefix of the resource name"
}

# Create a map for the vm names
variable "vm_map" {
  type = map(object({
    name            = string
    size            = string
    admin_password  = string
  }))
  default = {
    "vm-1" = {
      admin_password  = "Password1"
      name            = "vm-1"
      size            = "Standard_DS1_v2"
    }
    "vm-2" = {
      admin_password  = "Password2"
      name            = "vm-2"
      size            = "Standard_B1s"
    }
    "vm-3" = {
      admin_password  = "Password3"
      name            = "vm-3"
      size            = "Standard_D2s_v3"
    }
  }
}
