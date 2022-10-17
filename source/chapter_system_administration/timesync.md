# 3.4. 时间同步
Proxmox VE集群堆栈本身在很大程度上依赖于所有节点都具有精确同步的时间这一事实。如果所有节点上的本地时间不同步，其他一些组件（如 Ceph）也无法正常工作。

可以使用"网络时间协议"（NTP）实现节点之间的时间同步。从 Proxmox VE 7 开始，chrony 用作默认的 NTP 守护程序，而 Proxmox VE 6 使用 systemd-timesyncd。两者都预先配置为使用一组公共服务器。

如果您将系统升级到Proxmox VE 7，建议您手动安装chrony，ntp或openntpd。

## 3.4.1. 使用自定义 NTP 服务器
在某些情况下，可能需要使用非默认 NTP 服务器。例如，如果您的 Proxmox VE 节点由于限制性防火墙规则而无法访问公共互联网，则需要设置本地 NTP 服务器并告诉 NTP 守护程序使用它们。

### 对于使用chrony的系统
在 `/etc/chrony/chrony.conf` 中指定 `chrony` 应使用的服务器：
```
server ntp1.example.com iburst
server ntp2.example.com iburst
server ntp3.example.com iburst
```
重新启动时间：

```# systemctl restart chronyd```

检查日志以确认正在使用新配置的 NTP 服务器：

```
# journalctl --since -1h -u chrony
...
Aug 26 13:00:09 node1 systemd[1]: Started chrony, an NTP client/server.
Aug 26 13:00:15 node1 chronyd[4873]: Selected source 10.0.0.1 (ntp1.example.com)
Aug 26 13:00:15 node1 chronyd[4873]: System clock TAI offset set to 37 seconds
...
```

### 对于使用 systemd-timesyncd 的系统

在 `/etc/systemd/timesyncd.conf` 中指定 `systemd-timesyncd` 应使用的服务器：

```
[Time]
NTP=ntp1.example.com ntp2.example.com ntp3.example.com ntp4.example.com
```

然后，重新启动同步服务（`systemctl restart systemd-timesyncd`），并通过检查日志 （`journalctl ---since -1h -u systemd-timesyncd`） 来验证新配置的 NTP 服务器是否正在使用中：

```
...
Oct 07 14:58:36 node1 systemd[1]: Stopping Network Time Synchronization...
Oct 07 14:58:36 node1 systemd[1]: Starting Network Time Synchronization...
Oct 07 14:58:36 node1 systemd[1]: Started Network Time Synchronization.
Oct 07 14:58:36 node1 systemd-timesyncd[13514]: Using NTP server 10.0.0.1:123 (ntp1.example.com).
Oct 07 14:58:36 node1 systemd-timesyncd[13514]: interval/delta/delay/jitter/drift 64s/-0.002s/0.020s/0.000s/-31ppm
...
```
