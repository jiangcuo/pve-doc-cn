# 10.12虚拟机管理命令qm

命令qm是Proxmox VE提供的用于管理Qemu/KVM虚拟机的命令行工具。通过该命令，可以创建或销毁虚拟机，也可以控制虚拟机运行状态（启动/停止/挂起/恢复）。

此外，还可以利用qm设置虚拟机配置文件中的参数，创建或删除虚拟磁盘。


## 10.12.1命令行示例

用local存储中的iso文件，在local-lvm存储中创建一个虚拟机，配置4GB的IDE虚拟硬盘。

```
qm create 300 -ide0 local-lvm:4 -net0 e1000 -cdrom local:iso/proxmox -mailgateway_2.1.iso
```

启动新建虚拟机。

```
qm start 300
```

发出关机命令，并等待直到虚拟机关机。

```
qm shutdown 300 && qm wait 300
```

发出关机命令，并等待40秒。

```
qm shutdown 300 && qm wait 300 -timeout 40
```

删除VM总是会将其从访问控制列表和防火墙配置中移除，如果你想将虚拟机从备份任务、复制或者HA资源中移除，你还需要添加选项` --purge`

```
qm destroy 300 --purge
```

移动磁盘到不同的存储点。

```
qm move-disk 300 scsi0 other-storage
```

重新分配磁盘到另外的VM。这把源VM的`scsi1`重新配置到目标VM的`scsi3`。在移动过程中，会将磁盘重新按照目标VM的磁盘格式命令。


```
qm move-disk 300 scsi1 --target-vmid 400 --target-disk scsi3
```


