## 3.9. BTRFS

**注意**，BTRFS集成目前是Proxmox VE中的技术预览版。

BTRFS是一个由Linux内核支持的写入时复制的先进文件系统。通过数据和元数据的校验和实现快照功能，支持RAID和自我修复。

从 Proxmox VE 7.0 开始，引入BTRFS 作为根文件系统。可在安装的时候选择。

一般 BTRFS 优势
- 主系统设置与传统的基于 ext4 的设置几乎相同
- 快照
- 文件系统级别的数据压缩
- 写入时拷贝克隆
- RAID0、RAID1 和 RAID10
- 防止数据损坏
- 自我修复
- Linux 内核原生支持
- ...

**警告
RAID 5/6 是实验性的和危险的

## 3.9.1. 作为根文件系统安装
使用 Proxmox VE 安装程序进行安装时，可以为根文件系统选择 BTRFS。

您需要在安装时选择 RAID 类型：

- RAID0：也称为"条带化"。此类卷的容量是所有磁盘容量的总和。但是 RAID0 不会添加任何冗余，因此单个驱动器的故障会使卷无法使用。
- RAID1: 也称为"镜像"。数据以相同的方式写入所有磁盘。此模式至少需要 2 个相同大小的磁盘。生成的容量是单个磁盘的容量.
- RAID10: RAID0 和 RAID1 的组合。至少需要 4 个磁盘。

安装程序会自动对磁盘进行分区，并在 `/var/lib/pve/local-btrfs` 上创建一个附加子卷。为了将其与Proxmox VE工具一起使用，安装程序在`/etc/pve/storage`中创建以下配置条目.cfg：


```
dir: local
        path /var/lib/vz
        content iso,vztmpl,backup
        disable

btrfs: local-btrfs
        path /var/lib/pve/local-btrfs
        content iso,vztmpl,backup,images,rootdir
        
```
这将禁用默认的`local`存储，支持子卷上的 `local-btrfs `存储条目。

btrfs 命令用于配置和管理 btrfs 文件系统，安装后，以下命令列出了所有其他子卷：
```
btrfs subvolume list /
ID 256 gen 6 top level 5 path var/lib/pve/local-btrfs
```
## 3.9.2. BTRFS管理

本节为您提供了一些常见任务的使用示例。

创建 BTRFS 文件系统

要创建 BTRFS 文件系统，请使用 mkfs.btrfs。-d 和 -m 参数分别用于设置元数据和数据的配置文件。使用可选的 -L 参数，可以设置标签。

通常支持以下模式：单一，raid0，raid1，raid10。

在单个磁盘 `/dev/sdb` 上创建一个 BTRFS 文件系统，标签为 `My-Storage`：

```
 mkfs.btrfs -m single -d single -L My-Storage /dev/sdb
```
或者在两个分区 /dev/sdb1 和 /dev/sdc1 上创建 RAID1：

```
mkfs.btrfs -m raid1 -d raid1 -L My-Storage /dev/sdb1 /dev/sdc1
```

挂载 BTRFS 文件系统

分区之后，可以挂载新的文件系统，如下：
```
mkdir /my-storage
mount /dev/sdb /my-storage
```
BTRFS 也可以像任何其他挂载点一样添加到 ```/etc/fstab``` 中，自动将其挂载到引导时。建议避免使用块设备路径，但使用打印的 mkfs.btrfs 命令的 UUID 值，尤其是在 BTRFS 设置中有多个磁盘。

例如/etc/fstab：
```
# using the UUID from the mkfs.btrfs output is highly recommended
UUID=e2c0c3ff-2114-4f54-b767-3a203e49f6f3 /my-storage btrfs defaults 0 0
```

如果您找不到UUID，则可以使用blkid工具列出块设备的所有属性。

之后，您可以通过执行以下命令来触发第一次挂载：

```
mount /my-storage

```
下次重新启动后，系统将在启动时自动完成挂载操作。

将 BTRFS 文件系统添加到 Proxmox VE

您可以通过 Web 界面或使用 CLI 将现有的 BTRFS 文件系统添加到 Proxmox VE，例如：

```
pvesm add btrfs my-storage --path /my-storage

```

创建子卷
创建子卷会将其链接到 btrfs 文件系统中的路径，在该路径中，它将显示为常规目录。
```
btrfs subvolume create /some/path
```
之后/some/path将像常规目录一样工作。

删除子卷
与通过 rmdir 删除的目录相反，子卷不需要为空即可通过 btrfs 命令删除。

```
 btrfs subvolume delete /some/path
```

创建子卷的快照

BTRFS 实际上并不区分快照和普通子卷，因此拍摄快照也可以被视为创建子卷的任意副本。按照惯例，Proxmox VE 在创建来宾磁盘或子卷的快照时将使用只读标志，但此标志也可以在以后更改。

```
BTRFS 实际上并不区分快照和普通子卷，因此拍摄快照也可以被视为创建子卷的任意副本。按照惯例，Proxmox VE 在创建来宾磁盘或子卷的快照时将使用只读标志，但此标志也可以在以后更改。
```




