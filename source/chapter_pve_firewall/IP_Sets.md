# 13.6 IP地址集合
IP地址集合可用来定义一组网络和主机。你可以在防火墙策略的source和dest属性中用“+名称”的格式引用IP地址集合。

如下策略将允许来自名为management的IP地址集合的HTTP访问

```
IN HTTP(ACCEPT) -source +management
```


## 13.6.1标准IP地址集合management

标准IP地址集合management仅限主机级别防火墙使用（不支持在虚拟机级别防火墙使用）。

系统对该IP地址集合开放日常管理所需的网络访问权限（PVE GUI，VNC，SPICE，SSH）。

本地集群网络地址将被自动添加到该IP地址集合（别名cluster_network），以便于集群内的主机相互通讯（multicast，ssh等）。

```
# /etc/pve/firewall/cluster.fw
[IPSET management]
192.168.2.10
192.168.2.10/24
```

## 13.6.2标准IP地址集合blacklist

标准IP地址集合blacklist中的地址对任何主机或虚拟机发起的访问请求都将被丢弃。

```
# /etc/pve/firewall/cluster.fw
[IPSET blacklist]
77.240.159.182
213.87.123.0/24
```

## 13.6.3标准IP地址集合ipfilter-net*

该类过滤器专门为虚拟机的虚拟网卡定义，主要用于防止IP地址欺骗。为虚拟网卡定义该IP地址集合后，从网卡发出的任何与ipfilter集合中IP地址不符的数据包都将被丢弃。

对于配置指定IP地址的容器，如果定义了该IP地址集合（或通过在虚拟机防火墙options选项卡勾选通用IP Filter激活），容器IP地址会被自动加入该IP地址集合。

```
/etc/pve/firewall/<VMID>.fw
[IPSET ipfilter-net0] # only allow specified IPs on net0
192.168.2.10
```