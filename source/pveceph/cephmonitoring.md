# 8.11. Ceph监控和故障排查

最好从安装Ceph后就开始持续监控Ceph的健康状态。可以通过ceph自带工具，也可以通过Proxmox VE API监控。
以下命令可以查看集群是否健康（HEALTH_OK），或是否存在警告（HEALTH_WARN）或错误（HEALTH_ERR）。如果集群状态不健康，以下命令还可以查看当前事件和活动情况概览。

```
# single time output
pve# ceph -s
# continuously output status changes (press CTRL+C to stop)
pve# ceph -w
```

如果要查看进一步详细信息，可以查看/var/log/ceph/下的日志文件，每个ceph服务都会在该目录下有一个日志文件。如果日志信息不够详细，还可以进一步调整日志记录级别。
可以在官网查看Ceph集群故障排查的进一步信息。

