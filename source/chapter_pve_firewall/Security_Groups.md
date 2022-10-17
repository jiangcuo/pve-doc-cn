13.4安全组

安全组是一个防火墙策略的集合。安全组属于集群级别的防火墙对象，可用于所有的虚拟机防火墙策略。例如，你可以定义一个名为“webserver”的安全组，以开放http和https服务端口。

```
# /etc/pve/firewall/cluster.fw
[group webserver]
IN ACCEPT -p tcp -dport 80
IN ACCEPT -p tcp -dport 443
```

之后，就可以将该安全组添加到虚拟机防火墙策略中
```
# /etc/pve/firewall/<VMID>.fw
[RULES]
GROUP webserver
```