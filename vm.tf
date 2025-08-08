# 部署虚拟机模块
module "vm" {
  source = "https://github.com/TIANRANF18/AZR_Module_VM.git"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  vms = {
    # Web 服务器
    web01 = {
      vm_name           = "web-srv-01"
      vm_size           = "Standard_B2s"
      admin_username    = "adminuser"
      ssh_public_key    = file("~/.ssh/id_rsa.pub")
      os_disk_type      = "StandardSSD_LRS"
      os_image_publisher = "Canonical"
      os_image_offer    = "0001-com-ubuntu-server-jammy"
      os_image_sku      = "22_04-lts-gen2"
      os_image_version  = "latest"
      subnet_id         = module.network.subnet_ids["web"]
      public_ip         = true
      tags = {
        Environment = "Production"
        Role        = "Web Server"
      }
    },
    
    # 应用服务器
    app01 = {
      vm_name           = "app-srv-01"
      vm_size           = "Standard_D2s_v3"
      admin_username    = "adminuser"
      ssh_public_key    = file("~/.ssh/id_rsa.pub")
      os_disk_type      = "Premium_LRS"
      os_image_publisher = "MicrosoftWindowsServer"
      os_image_offer    = "WindowsServer"
      os_image_sku      = "2022-datacenter-azure-edition"
      os_image_version  = "latest"
      subnet_id         = module.network.subnet_ids["app"]
      public_ip         = false
      data_disks = [
        {
          name         = "app-disk-01"
          disk_size_gb = 128
          lun          = 0
          caching      = "ReadWrite"
        }
      ]
      tags = {
        Environment = "Production"
        Role        = "Application Server"
      }
    },
    
    # 数据库服务器
    db01 = {
      vm_name           = "db-srv-01"
      vm_size           = "Standard_E4s_v3"
      admin_username    = "adminuser"
      ssh_public_key    = file("~/.ssh/id_rsa.pub")
      os_disk_type      = "Premium_LRS"
      os_image_publisher = "MicrosoftSQLServer"
      os_image_offer    = "sql2022-ws2022"
      os_image_sku      = "enterprise"
      os_image_version  = "latest"
      subnet_id         = module.network.subnet_ids["db"]
      public_ip         = false
      data_disks = [
        {
          name         = "db-data-01"
          disk_size_gb = 512
          lun          = 0
          caching      = "ReadOnly"
        },
        {
          name         = "db-log-01"
          disk_size_gb = 256
          lun          = 1
          caching      = "None"
        }
      ]
      tags = {
        Environment = "Production"
        Role        = "Database Server"
      }
    },
    
    # 可扩展添加更多VM
    # web02 = { ... }
  }
}

