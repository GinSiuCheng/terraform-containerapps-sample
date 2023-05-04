variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "hub_name" {
  type    = string
  default = "hub"
}

variable "spoke_name" {
  type    = string
  default = "spoke"
}

variable "hub_address_space" {
  type    = string
  default = "10.0.0.0/16"
}

variable "hub_fw_subnet_prefix" {
  type    = string
  default = "10.0.0.0/24"
}

variable "hub_bastion_subnet_prefix" {
  type    = string
  default = "10.0.1.0/24"
}

variable "hub_default_subnet_prefix" {
  type    = string
  default = "10.0.2.0/24"
}

variable "spoke_address_space" {
  type    = string
  default = "10.1.0.0/16"
}

variable "spoke_default_subnet_prefix" {
  type    = string
  default = "10.1.0.0/24"
}

variable "spoke_pe_subnet_prefix" {
  type    = string
  default = "10.1.1.0/24"
}


variable "spoke_aca_subnet_prefix" {
  type    = string
  default = "10.1.2.0/23"
}

variable "la_name" {
  type = string
}

variable "sa_name" {
  type = string
}

variable "vm_username" {
  type = string
}

variable "vm_password" {
  type      = string
  sensitive = true
}

variable "vm_size" {
  type    = string
  default = "Standard_DS1_v2"
}

variable "my_ip" {
  type = string
}

variable "acr_name" {
  type = string
}

variable "aca_name" {
  type = string
}

variable "aca_env_name" {
  type = string
}