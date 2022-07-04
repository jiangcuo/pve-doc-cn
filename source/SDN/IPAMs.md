# IPAM

IPAM(ip地址管理)工具用于在网络上管理和分配设备的ip地址。例如，它可用于在创建 vm/ct 时查找可用 IP 地址（尚未实现）。

IPAM可与 1 个或多个区域相关联，以便为此区域中定义的所有子网提供 IP 地址。

## 12.6.1. Proxmox VE IPAM 插件

这是 proxmox 群集的默认内部 IPAM，如果您没有外部 IPAM 软件

## 12.6.2. phpIPAM plugin

https://phpipam.net/

您需要在 phpipam 中创建一个应用程序，并添加一个具有管理员权限的 api 令牌

phpIPAM有如下选项：

- url
 
  REST-API地址: http://phpipam.domain.com/api/<appname>/

- 令牌
  
  API 访问 token

- 区段

  一个整数 ID。节是 phpIPAM 中的子网组。默认安装对客户使用 sectionid=1。

## 12.6.3. netbox IPAM 插件

NetBox 是一个 IP 地址管理 （IPAM） 和数据中心基础设施管理 （DCIM） 工具，有关详细信息，请参阅源代码存储库:https://github.com/netbox-community/netbox

您需要在netbox中创建一个 API 令牌.

> https://netbox.readthedocs.io/en/stable/api/authentication

NetBox有如下选项：

- url
  
  REST-API地址: http://yournetbox.domain.com/api

- 令牌

  API访问token


