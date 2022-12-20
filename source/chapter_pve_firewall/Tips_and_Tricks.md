# 13.10提示和窍门

## 13.10.1如何开放FTP

FTP是一个古老的协议，使用固定端口21和其他一些动态端口。所以，你需要配置一条开放端口21的策略，并加载ip_contrack_ftp内核模块。加载命令如下：

```
modprobe ip_conntrack_ftp
```

进一步还需要在/etc/modules中添加ip_contrack_ftp（以便系统重启后自动加载）。

## 13.10.2集成Suricata IPS

你也可以集成使用Suricata IPS（入侵防御系统）。

只有通过防火墙策略校验的数据包才会发送给IPS。

被防火墙拒绝/丢弃的数据包不会发送给IPS。

首先需要在Proxmox VE主机安装suricata：
```
# apt-get install suricata
# modprobe nfnetlink_queue
```

不要忘记在/etc/modules中添加nfnetlink_queue，以便系统下次重启后自动加载。

然后可以在指定虚拟机的防火墙上激活IPS： 
```
# /etc/pve/firewall/<VMID>.fw
[OPTIONS]
ips: 1
ips_queues: 0
```
ips_queues 配置项将为虚拟机绑定一个指定的cpu队列。

可用队列定义在如下配置文件中
```
# /etc/default/suricata
NFQUEUE=0
```