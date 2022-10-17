# 13.2配置文件

防火墙相关的配置文件全部保存在Proxmox VE集群文件系统中，所以能够自动在所有节点间同步复制，而防火墙管理服务pve-firewall将在防火墙策略改变后自动更新底层iptables策略。

你可以在WebGUI界面完成所有的防火墙配置（例如通过，数据中心→防火墙，或者通过，节点→防火墙），或者也可以直接用你喜欢的编辑器编辑配置文件。

防火墙配置文件按小节把键-值策略对组织起来。以#字符开头的行和空行被当作注释处理。每个小节开头第一行格式都是“[小节名]”。

## 13.2.1集群级别的防火墙配置

作用域为整个集群的防火墙配置保存在

``/etc/pve/firewall/cluster.fw``

该配置文件由以下小节构成：

```
[OPTIONS]
该小节用于设置整个集群的防火墙配置项。

ebtables: <boolean> (default = 1)
集群范围内启用ebtables。

enable: <integer> (0 -N)
启用/禁用集群范围的防火墙。

log_ratelimit: [enable=]<1|0> [,burst=<integer>] [,rate=<rate>]
设置日志记录速度阀值。

burst=<integer> (0 - N) (default = 5)
将被记录的初始突发包。

enable=<boolean> (default = 1)
启用或禁用阀值

rate=<rate> (default = 1/second)
突发缓冲区重新填充频度。

policy_in: <ACCEPT | DROP | REJECT>
流入方向的防火墙策略。

policy_out: <ACCEPT | DROP | REJECT>
流出方向的防火墙策略。

[RULES]
该小节用于设置所有节点公共的防火墙策略。

[IPSET <name>]
整个集群范围内有效的IP集合定义。

[GROUP <name>]
整个集群范围内有效的组定义。

[ALIASES]
整个集群范围内有效的别名定义
```

### 启用防火墙

防火墙默认是被完全禁用的。你可以按如下方式设置启用参数项：

```
[OPTIONS]
# enable firewall (cluster wide setting, default is disabled)
enable: 1
```

- 重要

  启用防火墙后，默认所有主机的通信都将被阻断。唯一例外是集群网络内的WebGUI（端口8006）和ssh（端口22）访问可以继续使用。

如果你希望远程管理Proxmox VE服务器，你需要首先配置防火墙策略，允许远程IP访问WebGUI（端口8006）。根据需要，你还可以开通ssh（端口22）或SPICE（端口3128）的访问权限。


- 注意

  请在启用防火墙前先打开到Proxmox VE服务器的一个SSH连接，这样即使策略配置有误，也还可以通过该连接访问服务器。

为简化配置，你可以创建一个名为“管理地址”的IPSet，并把所有的远程管理终端IP地址添加进去。这样就可以创建策略允许所有的远程地址访问WebGUI。



## 13.2.2主机级别的防火墙配置

主机级别的防火墙配置保存在

```
/etc/pve/nodes/<nodename>/host.fw
```

该文件中的配置可以覆盖cluster.fw中的配置。你可以提升报警日志级别，设置netfilter相关参数。该配置文件由以下小节构成：

```
[OPTIONS]
该小节用于设置当前主机的防火墙配置项。

enable: <boolean>
启用/禁用主机防火墙策略。

log_level_in: <alert | crit | debug | emerg | err | info | nolog | notice | warning>
流入方向的防火墙日志级别。

log_level_out: <alert | crit | debug | emerg | err | info | nolog | notice | warning>
流出方向的防火墙日志级别。

log_nf_conntrack: <boolean> (default = 0)
启用记录连接跟踪信息。

ndp: <boolean>
启用NDP。 

nf_conntrack_allow_invalid: <boolean> (default = 0)
在跟踪连接时允许记录不合法的包。

nf_conntrack_max: <integer> (32768 -N)
最大的跟踪连接数量。

nf_conntrack_tcp_timeout_established: <integer> (7875 -N)
反向连接建立超时时间。

nosmurfs: <boolean>
启用SMURFS过滤器。

smurf_log_level: <alert | crit | debug | emerg | err | info | nolog | notice | warning>
SMURFS过滤器日志级别。

tcp_flags_log_level: <alert | crit | debug | emerg | err | info | nolog | notice | warning>
非法TCP标志过滤器日志级别。

tcpflags: <boolean>
启用非法TCP标志组合过滤器。

[RULES]
该小节用于设置当前主机的防火墙策略。
```

## 13.2.3虚拟机和容器级别的防火墙配置

虚拟机和容器级别的防火墙配置保存在

```
/etc/pve/firewall/<VMID>.fw
```

其内容由以下数据构成：
```
[OPTIONS]
该小节用于设置当前虚拟机或容器的防火墙配置项。

dhcp: <boolean>
启用DHCP。

enable: <boolean>
启用/禁用防火墙策略。

ipfilter: <boolean>
启用默认IP地址过滤器。相当于为每个网卡接口增加一个空白的ipfilter-net<id>地址集合。
该IP地址集合隐式包含了一些默认控制，例如限制IPv6链路本地地址为网卡MAC生成的地址。对于容器，配置的IP地址将被隐式添加进去。

log_level_in: <alert | crit | debug | emerg | err | info | nolog | notice | warning>
流入方向的防火墙日志级别。

log_level_out: <alert | crit | debug | emerg | err | info | nolog | notice | warning>
流出方向的防火墙日志级别。

macfilter: <boolean>
启用/禁用MAC地址过滤器。

ndp: <boolean>
启用NDP。

policy_in: <ACCEPT | DROP | REJECT>
流入方向的防火墙策略。

policy_out: <ACCEPT | DROP | REJECT>
流出方向的防火墙策略。

radv: <boolean>
允许发出路由通知。

[RULES]
该小节用于设置当前虚拟机或容器的防火墙策略。

[IPSET <name>]
IP集合定义。

[ALIASES]
IP地址别名定义。

```

**启用虚拟机或容器上的防火墙**

每个虚拟网卡设备都有一个防火墙启用标识。你可以控制每个网卡的防火墙启用状态。在设置启用虚拟机防火墙后，你必须设置网卡上的防火墙启用标识才可以真正启用防火墙。
