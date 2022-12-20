# 7.4 命令行使用方法

建议你熟悉并掌握 Proxmox VE 中存储池和存储卷的概念，但实际应用中，你不一定非要在命令行界面去实践基于这些概念的底层操作。通常情况下，使用虚拟机和容器管理工具分配或删除存储卷更加方便。

尽管如此，Proxmox VE 还是提供了一个名为 pvesm（“Proxmox VE Storage Manager”）的命令行工具，可用于基本的存储服务管理操作。

## 7.4.1 示例

添加存储池
```
pvesm add <TYPE> <STORAGE_ID> <OPTIONS>
pvesm add dir <STORAGE_ID> --path <PATH>
pvesm add nfs <STORAGE_ID> --path <PATH> --server <SERVER> --export <EXPORT>
pvesm add lvm <STORAGE_ID> --vgname <VGNAME>
pvesm add iscsi <STORAGE_ID> --portal <HOST[:PORT]> --target <TARGET>
```

禁用存储池
```
pvesm set <STORAGE_ID> --disable 1
```

启用存储池
```
pvesm set <STORAGE_ID> --disable 0
```

修改/设置存储属性

```
pvesm set <STORAGE_ID> <OPTIONS>
pvesm set <STORAGE_ID> --shared 1
pvesm set local --format qcow2
pvesm set <STORAGE_ID> --content iso
```
删除存储池。
该操作并不删除任何数据，也不断开任何连接或卸载任何文件系统，而仅仅是删除配置文件中相关内容。
```
pvesm remove <STORAGE_ID>
```

分配存储卷

```
pvesm alloc <STORAGE_ID> <VMID> <name> <size> [--format <raw|qcow2>]
```

在 local 存储中分配 4GB 的存储卷。如果设置`<name>`为空，系统将自动生成存储卷名称。

```
pvesm alloc local  <VMID>  '' 4G
```

释放存储卷 (该操作将删除存储卷上的所有数据。)
```
pvesm free <VOLUME_ID>
```

列出存储池状态
```
pvesm status
```

列出存储池中的存储卷

```
pvesm list <STORAGE_ID> [--vmid <VMID>]
```

列出某个虚拟机拥有的存储卷
```
pvesm list <STORAGE_ID> --vmid <VMID>
```
列出 iso 镜像
```
pvesm list <STORAGE_ID> --iso
```
列出容器模板

```
pvesm list <STORAGE_ID> --vztmpl
```
显示某个存储卷的文件系统路径
```
pvesm path <VOLUME_ID>
```


将卷`local:103/vm-103-disk-0.qcow2` 导出到文件target。这主要在内部与 pvesm 导入一起使用。
流格式 qcow2+size 与 qcow2 格式不同。

因此，导出的文件不能简单地附加到 VM。这也适用于其他格式。

```
pvesm export local:103/vm-103-disk-0.qcow2 qcow2+size target --with-snapshots 1
```

