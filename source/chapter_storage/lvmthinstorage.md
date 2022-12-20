# 7.12 基于LVM-thin的后端存储

存储池类型：lvm-thin

LVM是在逻辑卷创建时就按设置的卷容量大小预先分配所需空间。LVM-thin存储池是在向卷内写入数据时按实际写入数据量大小分配所需空间。LVM-thin所用的存储空间分配方式允许创建容量远大于物理存储空间的存储卷，因此也称为“薄模式”。

创建和管理LVM-thin存储池的命令和LVM命令完全一致（参见man lvmthin）。假定你已经有一个LVM卷组pve，如下命令可以创建一个名为data的新LVM-thin存储池（容量100G）：

```
lvcreate -L 100G -n data pve
lvconvert --type thin-pool pve/data
```
## 7.12.1配置方法

LVM-thin后端存储支持公共存储服务属性content、nodes、disable，以及如下的LVM特有属性：
- vgname

用于设置LVM的卷组（VG）名称。必须设置为已有卷组的名称。

- thinpool
LVM-thin存储池名称。

配置示例（`/etc/pve/storage.cfg`）
```
lvmthin: local-lvm
       thinpool data
       vgname pve
       content rootdir,images
```

## 7.12.2文件命名规范

LVM-thin后端存储的命名规范与ZFS后端存储基本一致。
vm-<VMID>-<NAME> 	//普通虚拟机镜像

## 7.12.3存储功能

LVM-thin属于块存储解决方案，同时支持快照和链接克隆功能。新创建的卷数据默认为全0。

必须强调，LVM-thin存储池不能被多个节点同时共享使用，只能用于节点本地存储。


表8.10 LVM-thin后端存储功能

|数据类型 |镜像格式 |支持共享| 支持快照 |支持链接克隆|
|-----|-----|-----|----|-----|
|虚拟机镜像 容器镜像 |raw |否|是|是|

