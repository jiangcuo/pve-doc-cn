# 3.7. 逻辑卷管理（LVM）

大多数人直接在本地磁盘上安装Proxmox VE。Proxmox VE 安装 CD 提供了多个本地磁盘管理选项，并且默认使用 LVM。安装程序允许您为此类设置选择单个磁盘，并将该磁盘用作 Volume Group （VG） pve 的物理卷。以下输出来自使用 8GB 小磁盘的测试安装。
```
# pvs
  PV         VG   Fmt  Attr PSize PFree
  /dev/sda3  pve  lvm2 a--  7.87g 876.00m

# vgs
  VG   #PV #LV #SN Attr   VSize VFree
  pve    1   3   0 wz--n- 7.87g 876.00m
```

安装程序在此 VG 中分配三个LV。

```
# lvs
  LV   VG   Attr       LSize   Pool Origin Data%  Meta%
  data pve  twi-a-tz--   4.38g             0.00   0.63
  root pve  -wi-ao----   1.75g
  swap pve  -wi-ao---- 896.00m
```

- root 格式化为 ext4，并包含Proxmox VE的系统
- swap 交换分区
- data 格式化为lvm精简卷（lvm-thin），，用于存储 VM 映像。因它为快照和克隆提供了有效的支持，所以LVM-thin 更适合此场景。

对于 Proxmox VE 版本（最高 4.1），安装程序会创建一个名为`data`的标准逻辑卷，该逻辑卷安装在 `/var/lib/vz`。

从版本 4.2 开始，逻辑卷`data`是一个 LVM 精简池，用于存储基于块的客户机映像，而 `/var/lib/vz` 只是根文件系统上的一个目录。

## 3.7.1. 硬件

我们强烈建议使用硬件 RAID 控制器（带电池）进行此类设置。这样不仅可以提高性能，而且还可以提供冗余，并且磁盘可热插拔更换。

LVM本身不需要任何特殊的硬件，内存要求非常低


## 3.7.2. 创建卷组

假设我们有一个空磁盘 /dev/sdb，我们要在它上面创建一个名为"vmdata"的卷组。

**注意**：请注意，以下命令将清空 /dev/sdb 上的所有现有数据。

首先创建一个分区。

```
# sgdisk -N 1 /dev/sdb
```

创建一个未确认的 Physical Volume （PV） 和 250K 元数据大小。

```
# pvcreate --metadatasize 250k -y -ff /dev/sdb1
```

在 /dev/sdb1 上创建名为"vmdata"的卷组

```
# vgcreate vmdata /dev/sdb1
```

## 3.7.4. 为 /var/lib/vz 创建一个额外的 LV

下面命令可以轻松创建一个LV。

```
# lvcreate -n <Name> -V <Size[M,G,T]> <VG>/<LVThin_pool>
```

如在pve卷组下创建一个名为vz的10g lv

```
# lvcreate -n vz -L 10G vmdata
```

接着在做个。

```
# mkfs.ext4 /dev/vmdata/vz
```

最后，必须安装它。

**注意**确保 /var/lib/vz 为空。如果是默认安装，那么不为空。


为了使其始终可访问，请在 /etc/fstab 中添加以下行。

```
echo '/dev/pve/vz /var/lib/vz ext4 defaults 0 2' >> /etc/fstab
```

## 3.7.6. 创建 LVM 精简池

在vmdata卷组上，创建一个名为data，大小为10G的精简池。

```
lvcreate -L 10G -T -n data vmdata
```

## 3.7.5. 调整精简池的大小

可以使用以下命令调整 LV 和元数据池的大小。

**注意**：扩展数据池时，还必须扩展元数据池。


```
# lvresize --size +<size[\M,G,T]> --poolmetadatasize +<size[\M,G]> <VG>/<LVThin_pool>
```
将data精简池增加10G，同时将元数据池增加1G

```
# lvresize --size +10G --poolmetadatasize +1G vmdata/data
```

