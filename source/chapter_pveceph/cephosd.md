# 8.5  Ceph OSD

Ceph 对象存储守护进程(Ceph Object Storage Daemons)通过网络为Ceph存储对象。建议每个物理磁盘使用一个OSD。

## 8.5.1 创建OSD

您可以通过 Proxmox VE Web 界面或通过 CLI 使用 pveceph创建 OSD 。例如：

`pveceph osd create /dev/sd[X]`

提示：建议至少为Ceph集群创建12个OSD，并平均分配到集群的各节点。在最小的3节点集群下，每个节点部署4个OSD。

如磁盘之前已经被格式化过（如ZFS/RAID/OSD），可用以下命令删除分区表、引导扇区和其他OSD遗留数据。

`ceph-volume lvm zap /dev/sd[X] --destroy`

警告：以上命令将删除磁盘上的所有数据。

**Ceph Bluestore**


从 Ceph Kraken 版本开始，引入了一种新的 Ceph OSD 存储类型，称为 Bluestore [ 16 ]。这是自 Ceph Luminous 以来创建 OSD 时的默认设置。

`pveceph osd create /dev/sd[X]`

**Block.db 和 block.wal**

如果要为OSD配置专门独立的DB/WAL设备，可以通过-db_dev和-wal_dev选项指定设备。如果不指定专门设备，WAL数据将保存在DB上。

`pveceph createosd /dev/sd[X] -db_dev /dev/sd[Y] -wal_dev /dev/sd[Z]`


你可以用-db_size和-wal_size参数直接设置相关设备大小。如果未明确设置，将依次尝试使用以下值：

- 使用ceph配置中的bluestore_block_{db,wal}_size

-...数据库，osd区块
-...数据库，global区块
-...文件，osd区块
-...文件，global区块

- OSD大小的10%(DB)/1%(WAL)

提示：DB保存了BlueStore的内部元数据。WAL是BlueStore的内部卷，用于保存预写日志。建议采用高性能SSD或NVRAM作为DB/WAL，以提高性能。



**Ceph Filestore**

在 Ceph Luminous 之前，Filestore 被用作 Ceph OSD 的默认存储类型。从 Ceph Nautilus 开始，Proxmox VE 不再支持使用 pveceph创建此类 OSD 。如果您仍想创建文件存储 OSD，请直接使用 ceph-volume。

`ceph-volume lvm create --filestore --data /dev/sd[X] --journal /dev/sd[Y]`


## 8.5.2. 销毁OSD

通过界面删除OSD，首先在树视图中选择一个Proxmox VE节点，然后转到Ceph→OSD面板。选择要销毁的OSD。接下来，单击Out按钮。一旦OSD状态从输入更改为输出，请点击停止按钮。状态从up更改为down后，立即从More(更多)下拉菜单中选择Destroy(销毁)。


通过CLI删除OSD，请运行以下命令。

```
ceph osd out <ID> 
systemctl stop ceph-osd@<ID>.service 
```