# 13.3防火墙策略

防火墙策略定义了网络通信方向（IN或OUT）和处理动作（ACCEPT，DENY，REJECT）。你也可以定义一个宏来预定义的策略和配置项，还可以在策略前插入字符“|”来禁用策略。
防火墙策略语法

```
[RULES]

DIRECTION ACTION [OPTIONS]
|DIRECTION ACTION [OPTIONS] # disabled rule

DIRECTION MACRO(ACTION) [OPTIONS] # use predefined macro
```

如下参数可用于完善策略匹配规则。
```
--dest <string>
设置数据包目的地址。可以设置为一个IP地址，一个IP集合（IP集合名称）或IP别名。也可以设置为一个IP地址范围如20.34.101.207-201.3.9.99，或一组IP地址和网络地址列表（使用逗号分隔开）。注意不要在列表中同时混合配置IPv4地址和IPv6地址。

--dport <string>
设置TCP/UDP目的端口。可像/etc/services一样设置为服务名称或端口号（0-65535），也可按照“\d+:\d+”格式设置为端口范围，如80:85，也可以设置为由逗号分隔开的端口和端口范围列表。

--iface <string>
设置网卡名称。可以设置为网络配置中的虚拟机和容器网卡名称（net\d+）。主机级别的防火墙策略可使用任意字符串。

--log <alert | crit | debug | emerg | err | info | nolog | notice | warning>
防火墙策略的日志级别。

--proto <string>
设置IP协议。你可以设置为协议名称（tcp/udp）或/etc/protocols中定义的协议编号。

--source <string>
设置数据包源地址。可以设置为一个IP地址，一个IP集合（IP集合名称）或IP别名。也可以设置为一个IP地址范围如20.34.101.207-201.3.9.99，或一组IP地址和网络地址列表（使用逗号分隔开）。注意不要在列表中同时混合配置IPv4地址和IPv6地址。

--sport <string>
设置TCP/UDP目的端口。可像/etc/services一样设置为服务名称或端口号（0-65535），也可按照“\d+:\d+”格式设置为端口范围，如80:85，也可以设置为由逗号分隔开的端口和端口范围列表。
```

以下是一些防火墙策略示例
```
[RULES]
IN SSH(ACCEPT) -i net0
IN SSH(ACCEPT) -i net0 # a comment
IN SSH(ACCEPT) -i net0 -source 192.168.2.192 # only allow SSH from 192.168.2.192
IN SSH(ACCEPT) -i net0 -source 10.0.0.1-10.0.0.10 # accept SSH for ip range
IN SSH(ACCEPT) -i net0 -source 10.0.0.1,10.0.0.2,10.0.0.3 #accept ssh for ip list
IN SSH(ACCEPT) -i net0 -source +mynetgroup # accept ssh for ipset mynetgroup
IN SSH(ACCEPT) -i net0 -source myserveralias #accept ssh for alias myserveralias

|IN SSH(ACCEPT) -i net0 # disabled rule

IN DROP # drop all incoming packages
OUT ACCEPT # accept all outgoing packages
```