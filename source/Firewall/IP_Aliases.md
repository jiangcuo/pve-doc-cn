# 13.5. IP地址别名

IP地址别名能够让你为IP地址定义一个名称。之后可以通过名称来引用IP地址：

- 在IP集合内部

- 在防火墙的source和dest属性中

## 13.5.1标准IP地址别名local_network

该别名是系统自动定义的。可以使用如下命令查看分配的地址别名：
```
# pve-firewall localnet
local hostname: example
local IP address: 192.168.2.100
network auto detect: 192.168.0.0/20
using detected local_network: 192.168.0.0/
```

防火墙将利用该别名自动生成策略，开放Proxmox VE集群对网络的访问权限（corosync，API，SSH）。

用户可以修改cluster.fw中定义的别名。如果你在公共网络上有一台独立的Proxmox VE主机，最好明确指定本地IP地址的别名

# /etc/pve/firewall/cluster.fw
[ALIASES]
local_network 1.2.3.4 # use the single ip address

