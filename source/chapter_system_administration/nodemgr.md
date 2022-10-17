# 3.10. Proxmox 节点管理
Proxmox VE节点管理工具（```pvenode```）允许您控制节点特定的设置和资源。

目前，`pvenode `允许您设置节点的描述，对节点的客户机运行各种批量操作，查看节点的任务历史记录，以及管理节点的 SSL 证书，这些证书通过` pveproxy` 用于 API 和 Web GUI。

## 3.10.1. 网络唤醒

LAN 唤醒 （WoL） 允许您通过发送幻数据包来打开网络中处于睡眠状态的计算机。必须至少有一个 NIC 支持此功能，并且需要在计算机的固件 （BIOS/UEFI） 配置中启用相应的选项。选项名称可能从"启用局域网唤醒"到"通过 PCIE 设备打开电源"不等。如果您不确定，请查看主板的供应商手册。ethtool可用于检查<接口>的WoL配置，方法是运行：

```
ethtool <interface> | grep Wake-on
```
pvenode 允许您通过 WoL 唤醒集群中处于睡眠状态的节点，使用以下命令：
```
pvenode wakeonlan <node>
```
这将在 UDP 端口 9 上广播 WoL 幻数据包，其中包含从 wakeonlan 属性获取的`<node>`的 MAC 地址。可以使用以下命令设置特定于节点的 wakeonlan 属性：
```
pvenode config set -wakeonlan XX:XX:XX:XX:XX:XX
```
## 3.10.2. 任务历史

要对服务器问题（例如，失败的备份作业）进行故障排除时，通常查看之前的任务历史。

使用Proxmox VE，您可以通过`pvenode task`命令访问节点的任务历史记录。

您可以使用`list`表子命令获取节点已完成任务的筛选列表。例如，若要获取VM 100错误的相关任务的列表，命令为：

```
pvenode task list --errors --vmid 100
```

然后可以使用其 UPID 打印任务的日志：

```
pvenode task log UPID:pve1:00010D94:001CA6EA:6124E1B9:vzdump:100:root@pam:
```
## 3.10.3. 批量客户机电源管理

如果有许多 VM/容器，则可以使用 pvenode 的 `startall` 和 `stopall` 子命令在批量操作中启动和停止来宾。默认情况下，`pvenode startall` 将仅启动已设置为在启动时自动启动的 VM/容器（请参阅虚拟机的自动启动和关闭），但是，可以使用 `--force` 绕过此限制。这两个命令还具有 --vms 选项，该选项将停止/启动的客户机限制为指定的 VMID。

例如，要启动 VM 100、101 和 102，无论它们是否设置了 onboot，都可以使用：

```
pvenode startall --vms 100,101,102 --force
```

要停止这些来宾（以及可能正在运行的任何其他来宾），请使用以下命令：

```
pvenode stopall
```

## 3.10.4. 第一个客户机引导延迟

如果您的虚拟机/容器依赖于启动缓慢的外部资源（例如 NFS 服务器），您还可以设置在Proxmox VE开机后与第一个自动启动的虚拟机或容器之间的引导延迟（请参阅虚拟机的自动启动和关闭）。

您可以通过设置以下内容（其中 10 表示以秒为单位的延迟）来实现此目的：

```
pvenode config set --startall-onboot-delay 10
```

## 3.10.5. 批量客户迁移

如果升级情况需要您将所有来宾从一个节点迁移到另一个节点，pvenode 还提供了用于批量迁移的 migrateall 子命令。默认情况下，此命令会将系统上的每个客户机迁移到目标节点。但是，可以将其设置为仅迁移一组来宾。

例如，要将 VM 100、101 和 102 迁移到节点 pve2 并启用本地磁盘的实时迁移，可以运行：

```
pvenode migrateall pve2 --vms 100,101,102 --with-local-disks
```


