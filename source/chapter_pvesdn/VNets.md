# 12.4 VNets

VNet的基本形式只是一个Linux网桥，它将本地部署在节点上并用于虚拟机通信。

VNet属性包括：

- 名称：用于命名和标识vNet的8个字符的ID。

- 别名：可选的较长名称，如果ID不够。

- 区：此vNet的关联区域。

- 标签：唯一的VLAN或VXLAN ID。

- VLAN感知：允许在虚拟机或容器vNIC配置中添加额外的VLAN标签，或允许来宾操作系统管理VLAN的标签。

## 12.4.1. 子网

sub-net（子网）可以定义特定的 IP 网络（IPv4 或 IPv6）。对于每个 VNET，可以定义一个或多个子网。

子网可用于：

- 在特定VNet上限制IP地址

- 在第3层区域中的VNet上分配路由/网关

- 在第3层区域中的VNet上启用 SNAT

- 通过 IPAM 插件在虚拟来宾（VM 或 CT）上自动分配 IP

- 通过 DNS 插件进行 DNS 注册

如果 IPAM 服务器与子网区域相关联，则子网前缀将自动在 IPAM 中注册。

子网属性包括：

- 子网: 

  一个 cidr 网络地址。例如：10.0.0.0/8

- 网关

  网络默认网关的地址。在第 3 层区域（Simple/evpn 插件）上，它将部署到vnet。

- Snat
  
  可选配置，为此子网的第 3 层区域（简单/evpn 插件）启用 Snat。子网源IP将NAT到服务器传出接口/ip。在 evpn 区域上，它仅在 evpn 网关节点上完成。

- DNS域前缀

  可选配置。为域添加前缀，如<hostname>.prefix.<domian>





