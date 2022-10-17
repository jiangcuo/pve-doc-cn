# 13.9防火墙日志记录
默认情况下，所有的防火墙策略都不产生日志记录。

如要启用日志记录，需要在Firewall→Options中设置出/入网络数据包的日志级别loglevel。

主机、客户机的日志级别可以分别设置。设置后，Proxmox VE的防火墙日志将被启用，并可以在Firewall→Log中查看。

需要注意，只有被标准策略丢弃或拒绝的数据包会产生日志记录（详见12.8节默认防火墙策略）。

防火墙日志级别loglevel并不影响产生日志数量。只用于改变日志记录的LOGID前缀，以便后续处理。

具体的loglevel取值如下表：

|loglevel	|LOGID|
|-|-|
|nolog	|—|
|emerg	|0|
|alert	|1|
|crit	|2|
|err	|3|
|warning	|4|
|notice	|5|
|info	|6|
|debug	|7|

典型的防火墙日志记录如下：
```
VMID LOGID CHAIN TIMESTAMP POLICY: PACKET_DETAILS
```
如为主机防火墙日志记录，VMID会被设置为0.

## 13.9.1用户自定义防火墙策略日志记录

如需让用户自定义防火墙策略生成日志记录，可以为每条策略分别设置日志级别。通过Firewall→Options可以为每条策略设置非常精细的日志级别
。
当然可以通过WebUI在创建或修改每条策略时设置或改变loglevel，也可以通过pvesh调用相应API进行设置。

此外，还可以通过修改防火墙日志文件调整日志级别，只要在相应策略后添加-log <loglevel>即可。

示例如下，以下两条命令效果是一样的，都不产生日志：
```
IN REJECT -p icmp -log nolog
IN REJECT -p icmp
```
但以下策略将产生debug级别日志。
```
IN REJECT -p icmp -log debug
```