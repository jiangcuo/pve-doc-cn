# 磁盘健康检查

尽管建议使用可靠且冗余的存储，但监视本地磁盘的运行状况会很有帮助。

从 Proxmox VE 4.3 开始，集成 smartmontools 。这是用于监视和控制本地硬盘的 S.M.A.R.T. 系统的工具

您可以通过发出以下命令来获取磁盘的状态：

```
# smartctl -a /dev/sdX

```
其中 /dev/sdX 是指向其中一个本地磁盘的路径。如果输出显示：
```
SMART support is: Disabled

```
您可以使用以下命令启用它：
```
# smartctl -s on /dev/sdX

```

有关如何使用 `smartctl` 的更多信息，请参阅 `man smartctl`。

默认情况下，`smartmontools` 守护程序 `smartd` 处于活动状态并处于启用状态，并且每 30 分钟扫描一次 /dev/sdX 和 /dev/hdX 下的磁盘以查找错误和警告，并在检测到问题时向 root 发送电子邮件。

有关如何配置 `smartd` 的更多信息，请参阅 `man smartd` 和`man smartd.conf`。

如果将硬盘与硬件 raid 控制器配合使用，最好使用raid监控工具。有关此内容的更多信息，请咨询 RAID 控制器的供应商。

