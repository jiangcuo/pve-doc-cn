# 13.7服务及管理命令

防火墙在每个节点都运行了两个服务进程：

- pvefw-logger: NFLOG服务进程（替换ulogd）。

- pve-firewall: 更新iptables策略。

还提供了一个管理命令pve-firewall，可用于启停防火墙服务：
```
# pve-firewall start
# pve-firewall stop
```
或查看防火墙服务状态：
```
# pve-firewall status
```
如上命令将读取并编译所有的防火墙策略，如果发现配置错误，将会自动发出告警。
如果你需要查看生成的iptables策略，可以运行如下命令：
```
# iptables-save
```
