variable rg_aks_name {
  type    = string
  default = "rg-akskratos"
}

variable rg_aks_location {
  type    = string
  default = "East US 2"
}

variable nsg_aks_name {
  type    = string
  default = "nsg-akskratos"
}

variable vnet_aks_name {
  type    = string
  default = "vnet-akskratos"
}

variable vnet_aks_address_space {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable vnet_aks_dns_server {
  type    = list(string)
  default = ["10.0.0.4", "10.0.0.5"]
}

variable subnet_aks_name {
  type    = string
  default = "subnet-akskratos"
}

variable subnet_aks_address {
  type    = string
  default = "10.0.0.0/24"
}

variable tags {
  type    = map(string)
  default = {
    "env"        = "dev"
    "created_by" = "terraform"
  }
}