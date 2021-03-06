# 12.2 概述

Proxmox VE SDN使用灵活的软件控制配置，允许对虚拟来宾网络进行分离和细粒度控制。

隔离由区域组成，一个区域就是它自己的虚拟隔离网络区域。VPN是连接到区域的一种虚拟网络。根据专区使用的类型或插件的不同，它可能会有不同的行为，并提供不同的功能、优点或缺点。通常，vNet显示为带有VLAN或VXLAN标签的普通Linux网桥，但有些网桥也可以使用第3层路由进行控制。从群集范围的数据中心SDN管理界面提交配置后，将在每个节点上本地部署VNET。

## 12.2.1 主要配置

配置在数据中心(群集范围)级别完成，它将保存在共享配置文件系统中的配置文件中：/etc/pve/sdn

在Web界面上，SDN功能有4个主要部分用于配置

- SDN：SDN状态概述。

- 区域：创建和管理虚拟分离的网络区域。

- VNET：为虚拟机提供分区的每节点构造块。


还有一些选项

- 控制器: 适用于控制第3层路由的复杂设置

- 子网: 定义在vnet上的网段

- IPAM: 使用外部IP管理工具管理虚拟机IP

- DNS: 定义一个DNS服务器，使用其api注册虚拟机的主机名和IP。

## 12.2.2. SDN

这是主状态面板。在这里，您可以看到不同节点上区域的部署状态。这里有一个Apply按钮，用于推送和重新加载所有群集节点上的本地配置。




