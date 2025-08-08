provider "azurerm" {
  features {}
}

# 创建资源组
resource "azurerm_resource_group" "main" {
  name     = "project1-prod-resources"
  location = "East US"
}

# 部署网络模块
module "network" {
  source = "../../modules/network"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  vnet_name           = "prod-vnet"
  vnet_address_space  = ["10.100.0.0/16"]
  public_ip_prefix    = "prod"

  subnets = {
    web = {
      name             = "web-subnet"
      address_prefixes = ["10.100.1.0/24"]
      nsg_rules = [
        {
          name                   = "allow-http"
          priority               = 100
          direction              = "Inbound"
          access                 = "Allow"
          protocol               = "Tcp"
          destination_port_range = "80"
        },
        {
          name                   = "allow-https"
          priority               = 110
          direction              = "Inbound"
          access                 = "Allow"
          protocol               = "Tcp"
          destination_port_range = "443"
        }
      ]
    },
    app = {
      name             = "app-subnet"
      address_prefixes = ["10.100.2.0/24"]
      nsg_rules = [
        {
          name                   = "allow-app"
          priority               = 100
          direction              = "Inbound"
          access                 = "Allow"
          protocol               = "Tcp"
          destination_port_range = "8080-8090"
        }
      ]
    },
    db = {
      name             = "db-subnet"
      address_prefixes = ["10.100.3.0/24"]
      nsg_rules = [
        {
          name                   = "allow-db"
          priority               = 100
          direction              = "Inbound"
          access                 = "Allow"
          protocol               = "Tcp"
          destination_port_range = "1433,3306"
          source_address_prefix  = "10.100.2.0/24"
        }
      ]
    }
  }
}


# 输出重要信息
output "web_server_public_ip" {
  value = module.virtual_machines.public_ip_addresses["web01"]
}

output "vnet_id" {
  value = module.network.vnet_id
}

output "subnet_ids" {
  value = module.network.subnet_ids
}