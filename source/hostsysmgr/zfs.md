# 3.8 Linux上的ZFS

ZFS 是由 Sun Microsystems 设计的文件系统和逻辑卷管理器的组合。从 Proxmox VE 3.4 开始，ZFS 文件系统的本机 Linux 内核端口作为可选文件系统引入，也作为根文件系统的附加选择引入。无需手动编译 ZFS 模块 ——已包含所有包。

使用ZFS，可以降低硬件预算硬件，同时实现企业功能，也可以通过利用SSD缓存甚至全闪存来实现高性能系统。ZFS对CPU和内存消耗小可以替代硬件阵列卡，同时易于管理。

**使用ZFS 优势**

- 可使用Proxmox VE GUI和CLI轻松配置和管理。

- 高可靠性

- 防止数据损坏

- 文件系统级别的数据压缩

- 快照

- 写入时拷贝克隆

- 支持各种阵列级别：RAID0、RAID1、RAID10、RAIDZ-1、RAIDZ-2 和 RAIDZ-3

- 可以使用 SSD 进行缓存

- 自我修复

- 持续的完整性检查

- 专为高存储容量而设计

- 通过网络异步复制

- 开源



## 3.8.1. 硬件

ZFS在很大程度上依赖于内存，因此至少需要8GB才能启动。在实践中，尽可能多地使用您的硬件/预算。为了防止数据损坏，我们建议使用安全性高的 ECC RAM。

如果您使用专用缓存和/或日志磁盘，则应使用企业级固态盘（例如英特尔固态盘 DC S3700 系列）。这可以显著提高整体安全和性能。

**注意**

不要在具有自己的缓存管理的硬件 RAID 控制器之上使用 ZFS。ZFS 需要直接与磁盘通信。使用HBA卡或者将硬盘设置成IT模式会更好。

如果您正在在 VM（嵌套虚拟化）中安装 Proxmox VE，请不要对该 VM 的磁盘使用 virtio，因为 ZFS 不支持这些磁盘。请改用 IDE 或 SCSI（也适用于 virtio SCSI 控制器类型）。

## 3.8.2. 以根文件系统形式安装

使用 Proxmox VE 安装程序进行安装时，可以为根文件系统选择 ZFS。您需要在安装时选择 RAID 类型：

- RAID0：
也叫作条带，此类卷的容量是所有磁盘容量的总和。但是RAID0没有冗余，单块盘故障会导致整个卷无法使用。但性能是最好的。

- RAID1：
通常被称作镜像。数据以相同的方式写入所有磁盘。此模式至少需要 2 个相同大小的磁盘。生成的容量是单个磁盘的容量。

- RAID10：
RAID0 和 RAID1 的组合。至少需要 4 个磁盘

- RAIDZ-1：
RAID-5 的变体，单奇偶校验。至少需要 3 个磁盘。

- RAIDZ-2：
RAID-5 的变体，双奇偶校验。至少需要 4 个磁盘。

- RAIDZ-3：
RAID-5 的变体，三重奇偶校验。至少需要5个磁盘。

安装程序会自动对磁盘进行分区，创建一个名为 rpool 的 ZFS 池，并将根文件系统安装在 ZFS 子卷 rpool/ROOT/pve-1 上。

将创建另一个名为 rpool/data 的子卷来存储 VM 映像。为了将其与Proxmox VE工具一起使用，安装程序在/etc/pve/storage中创建以下配置条目.cfg：

```
zfspool: local-zfs
        pool rpool/data
        sparse
        content images,rootdir
```
安装后，您可以使用 zpool 命令查看 ZFS 池状态：

```
# zpool status
  pool: rpool
 state: ONLINE
  scan: none requested
config:

        NAME        STATE     READ WRITE CKSUM
        rpool       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sda2    ONLINE       0     0     0
            sdb2    ONLINE       0     0     0
          mirror-1  ONLINE       0     0     0
            sdc     ONLINE       0     0     0
            sdd     ONLINE       0     0     0

errors: No known data errors
```

zfs 命令用于配置和管理 ZFS 文件系统。以下命令列出了安装后的所有文件系统：

```
# zfs list
NAME               USED  AVAIL  REFER  MOUNTPOINT
rpool             4.94G  7.68T    96K  /rpool
rpool/ROOT         702M  7.68T    96K  /rpool/ROOT
rpool/ROOT/pve-1   702M  7.68T   702M  /
rpool/data          96K  7.68T    96K  /rpool/data
rpool/swap        4.25G  7.69T    64K  -

```