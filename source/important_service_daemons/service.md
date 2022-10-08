# 17.1 pvedaemon – Proxmox VE API守护进程

该守护进程在127.0.0.1:85上提供了Proxmox VE API的调用接口。该进程以root权限运行，能够执行所有特权操作。
	
注意: 该守护进程仅监听本地地址，外部无法直接访问。守护进程pveproxy负责向外部提供API调用接口。

# 17.2 pveproxy – Proxmox VE API代理进程

该进程通过HTTPS在TCP 8006端口向外部提供Proxmox VE API调用接口。该进程以www-data权限运行，因此权限非常有限。更高权限的操作将由本地的pvedaemon进程执行。

指向其他节点的操作请求将自动发送到对应节点，也就是说你可以从Proxmox VE的一个节点管理整个集群。

## 17.2.1基于主机的访问控制
可以为pveproxy配置类似于“apache2”的访问控制列表。相关访问控制列表保存在`/etc/default/pveproxy`中。例如：

```
ALLOW_FROM="10.0.0.1-10.0.0.5,192.168.0.0/22"
DENY_FROM="all"
POLICY="allow"
```

IP地址可以用类似Net::IP的语法指定，而all是0/0的别名。
默认策略是allow。

| 匹配情况            | POLICY=deny | POLICY=allow  |
|-----------------|-------------|---------------|
| 仅有Allow匹配上      | 允许访问        | 允许访问          |
| 仅有Deny匹配上       | 拒绝访问        | 拒绝访问          |
| 均未匹配上           | 拒绝访问        | 允许访问          |
| 同时匹配到Allow和Deny | 拒绝访问        | 允许访问          |

## 17.2.2 监听的IP地址

`pveproxy`和`spcieproxy`使用通配符监听所有地址，包括ipv4和ipv6。

修改`/etc/default/pveproxy`文件，可以指定监听的ip，此ip必须在此节点上已配置好。

配置了`sysctl net.ipv6.bindv6only=1`将会使守护进程只监听ipv6，通常会出现其他问题。建议删掉此配置，或者将`LISTEN_IP`设置成`0.0.0.0`（只监听ipv4）。



## 17.2.3 SSL加密套件
可以在配置文件/etc/default/pveproxy中指定密码列表。例如：

```
CIPHERS="ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256"
```

以上是默认配置。可以查看openssl软件包中的man页面ciphers(1)获取更多可用选项。

此外，可以设置客户端使用/etc/default/pveproxy中的指定密码（默认使用列表中第一个可以同时为client和pveproxy接受的）
HONOR_CIPHER_ORDER=0

## 17.2.3 Diffie-Hellman参数

可以在配置文件/etc/default/pveproxy中指定Diffie-Hellman参数。只需将参数DHPARAMS设置为包含DH参数的PEM文件路径即可。例如：

```
DHPARAMS="/path/to/dhparams.pem"
```

如未设置该参数，将使用内置的skip2048参数。
	
注意
DH参数仅在协商使用基于DH密钥交换算法的加密套件时有效。

## 17.2.4其他HTTPS证书

Proxmox VE可以改用外部证书，或ACME证书。

Pveproxy默认使用证书`/etc/pve/local/pve-ssl.pem`和`/etc/pve/local/pve-ssl.key`，如果以上文件不存在，将改用`/etc/pve/local/pveproxy-ssl.pem`和`/etc/pve/local/pveproxy-ssl.key`。

详细信息可以查看第3章Proxmox VE服务器管理。

## 17.2.5压缩

在客户端支持的情况下，默认pveproxy使用gzip对HTTP流量进行压缩。可以在`/etc/default/pveproxy`中禁用该功能

```
COMPRESSION=0
```

# 17.3 pvestatd – Proxmox VE监控守护进程

该守护进程定时获取虚拟机、存储和容器的状态数据。结果将自动发送到集群中的所有节点。

# 17.4 spiceproxy – SPICE代理进程

SPICE（Simple Protocol for Independent Computing Environments）是一个开源远程计算解决方案，能够为远程桌面和设备（例如键盘、鼠标、音频）的提供客户端访问接口。主要使用场景是访问远程虚拟机和容器。

该守护进程监听TCP 3128端口，并通过HTTP代理将SPICE客户端的连接请求转发给相应的Proxmox VE虚拟机。该进程以www-data权限运行，权限非常有限。

## 17.4.1基于主机的访问控制

可以为spice配置类似于“apache2”的访问控制列表。相关访问控制列表保存在/etc/default/pveproxy中。详情可查看pveproxy文档。
