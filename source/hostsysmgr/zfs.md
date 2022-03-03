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
##  3.8.3. ZFS RAID 级别注意事项

在选择 ZFS 池的布局时，需要考虑几个因素。ZFS 池的基本构建块是虚拟设备或 vdev。池中的所有 vdev 均等使用，数据在它们之间条带化 （RAID0）。查看 zpool（8） 手册页，了解有关 vdevs 的更多详细信息。

### 性能
每个 vdev 类型具有不同的性能行为。最常见的两个参数是 IOPS（每秒输入/输出操作数）和写入或读取数据的带宽。

在写入数据时，RAID1有1块盘的速度，读取数据相当于2块盘的速度。

当有4个磁盘时。当将其设置为2个镜像vdevs（RAID10）时，池的IOPS 和带宽相当于两个单磁盘的写入。对于读取，相当于4个单磁盘读取。

任何冗余级别的 RAIDZ（如RAIDZ1，RAIDZ2...）在 IOPS 方面的类似于单个磁盘。带宽的大小取决于 RAIDZ vdev 的大小和冗余级别。

对于正在运行的 VM，在大多数情况下，IOPS 是更重要的指标。

### 大小、空间使用情况和冗余

虽然由镜像 vdev 组成的池将具有最佳性能表现，但可用空间将是总磁盘的 50%。每个镜像至少需要一个正常运行的磁盘，池才能保持正常运行。

N个磁盘的 RAIDZ 类型 vdev 的可用空间大致为 N-P，其中 P 是 RAIDZ 级别。RAIDZ 级别指示在不丢失数据的情况下，有多少个任意磁盘可以出现故障。例如3块硬盘的RAIDZ也就是RAIDZ-1，最多允许1块硬盘故障。可用容量为2块盘的容量。

使用任何RAIDZ级别的另一个重要因素是用于 VM 磁盘的 ZVOL 数据集的行为方式。对于每个数据块，池需要奇偶校验数据，该数据至少是池的 ashift 值定义的最小块的大小。如果ashift为12，则池的块大小为4k。ZVOL 的默认块大小为 8k。因此，在 RAIDZ2 中，写入的每个 8k 块都将导致写入两个额外的 4k 奇偶校验块，即 8k + 4k + 4k = 16k。这当然是一种简化的方法，实际情况会略有不同，元数据，压缩等在本例中未被考虑在内。

在检查 ZVOL 的以下属性时，可以观察到这种情况：
- volsize
- refreservation
- used 


```
zfs get volsize,refreservation,used <pool>/vm-<vmid>-disk-X
```
volsize 是呈现给 VM 的磁盘的大小，而 refreservation 保留显示池上的保留空间，其中包括奇偶校验数据所需的预期空间。如果池已精简置备，则重新预留将设置为 0。观察这种情况的另一种方法是比较 VM 中已用磁盘空间和 used 属性。请注意，如果有快照可能数据不准。

有几个选项可以减少奇偶校验的空间消耗：
- 增加volblocksize 
- 使用镜像而不是RAIDZ
- 使用ashit=9，这样blocksize=512b
  
volblocksize 属性只能在创建 ZVOL 时设置。可以在存储配置中更改。执行此操作时，需要相应地在虚拟机内部调整容量，并且根据用例，如果只是从 ZFS 层移动到来宾层，则会出现写入放大问题。

在创建池时使用 ashift=9 可能会导致性能下降，具体取决于下面的磁盘，并且以后无法更改。

镜像 vdev（RAID1、RAID10）有利于VM负载。除非您的环境具有特定需求和特征，必须使用镜像vdev，不然RAIDZ 的特性也是可以接受的。

## 3.8.4 系统引导程序
Proxmox VE 使用 proxmox-boot-tool 来管理引导加载程序配置。有关详细信息，请参阅有关 Proxmox VE 主机引导加载程序的章节。

## 3.8.5. ZFS 管理

本节为您提供了一些常见任务的使用示例。ZFS本身非常强大，并提供了许多选项。管理 ZFS 的主要命令是 zfs 和 zpool。这两个命令都带有出色的手册页，可以使用以下命令阅读：

```
man zpool
man zfs
```

## 3.8.6. 创建新的 zpool


**若要创建新池**，至少需要一个磁盘。ashift 应具有与底层磁盘相同的扇区大小（2 次方位）或更大。

```
 zpool create -f -o ashift=12 <pool> <device>
```
**要激活压缩**（请参阅 ZFS 中的压缩部分）：
```
 zfs set compression=lz4 <pool>
 ```

**使用 RAID-0 创建新池**
最少 1 个磁盘
```
 zpool create -f -o ashift=12 <pool> <device1> <device2>
 ```

**使用 RAID-1 创建新池**
最少 2 个磁盘
```
 zpool create -f -o ashift=12 <pool> mirror <device1> <device2>
 ```

**使用 RAID-10 创建新池**
最少 4 个磁盘
```
 zpool create -f -o ashift=12 <pool> mirror <device1> <device2> mirror <device3> <device4>
 ```

**使用 RAIDZ-1 创建新池**
最少 3 个磁盘
```
 zpool create -f -o ashift=12 <pool> raidz1 <device1> <device2> <device3>
 ```

**使用 RAIDZ-2 创建新池**
最少 4 个磁盘
```
zpool create -f -o ashift=12 <pool> raidz2 <device1> <device2> <device3> <device4>
```

**创建具有缓存的新池 （L2ARC）**
可以使用独立的硬盘分区（建议使用 SSD）作为缓存，以提高 ZFS 性能。

```
zpool create -f -o ashift=12 <pool> <device> cache <cache_device>
```

**使用日志创建新池 （ZIL）**
可以使用独立的硬盘分区（建议使用 SSD）作为缓存，以提高 ZFS 性能。

```
zpool create -f -o ashift=12 <pool> <device> log <log_device>
```

**为已有的存储池添加缓存和日志盘**
如果你要为一个未配置缓存和日志盘的 ZFS 存储池添加缓存和日志盘，首先需要使用 `parted`
或者 `gdisk`将 SSD 盘划分为两个分区

**注意** 需要使用 GPT 分区表。

日志盘的大小应约为物理内存大小的一半。SSD的其余部分可以用作缓存。
```
# zpool add -f <pool> log <device-part1> cache <device-part2>
```

**更改故障设备**

```
 zpool replace -f <pool> <old device> <new device>
 ```

**在使用 systemd-boot 时更换故障的系统磁盘**

根据Proxmox VE的安装方式，它要么使用proxmox-boot-tool [3]，要么使用普通的grub作为引导加载程序（参见主机引导加载程序）。您可以通过运行以下命令进行检查：
```
proxmox-boot-tool status
```
复制分区表、重新颁发 GUID 和替换 ZFS 分区的第一步是相同的。要使系统可从新磁盘引导，需要执行不同的步骤，具体取决于所使用的引导加载程序。
```
sgdisk <healthy bootable device> -R <new device>
sgdisk -G <new device>
zpool replace -f <pool> <old zfs partition> <new zfs partition>
```
注意	使用 zpool status -v 命令监视新磁盘的重新同步过程的进展程度。

**使用 proxmox-boot-tool**：
```
proxmox-boot-tool format <new disk's ESP>
proxmox-boot-tool init <new disk's ESP>
```
注意	ESP 代表 EFI 系统分区，它是从版本 5.4 开始由 Proxmox VE 安装程序设置的可启动磁盘上的分区 #2。有关详细信息，请参阅设置新分区以用作同步的 ESP。

**使用 grub**：
```
grub-install <new disk>
```

## 3.8.6.激活电子邮件通知

ZFS 有一个事件守护进程，专门监控 ZFS 内核模块产生的各类事件。当发生严重错误，例如
存储池错误时，该进程还可以发送邮件通知。

可 以 编 辑 配 置 文 件` /etc/zfs/zed.d/zed.rc `以 激 活 邮 件 通 知 功 能 。 
只 需 将 配 置 参 数
`ZED_EMAIL_ADDR` 前的注释符号去除即可，如下：

`ZED_EMAIL_ADDR="root" `

请注意，Proxmox VE 会将邮件发送给为 root 用户配置的电子邮件地址。


## 3.8.6 配置 ZFS 内存使用上限

默认情况下，ZFS会使用宿主机50%的内存做为ARC缓存。

为 ARC 分配足够的内存对于 IO 性能至关重要，因此请谨慎减少内存。根据一般情况，建议，1TB空间使用1G内存，同时预留2G基本内存。如果池有8TB空间，那应该给ARC分配8G+2G共10G的内存。

您可以通过直接写入zfs_arc_max模块参数来更改当前引导的 ARC 使用限制（重新启动会失效）：

```
 echo "$[10 * 1024*1024*1024]" >/sys/module/zfs/parameters/zfs_arc_max
```

要永久生效，请将以下行添加到 ```/etc/modprobe.d/zfs.conf```中。
如要限制为8G内存，则添加如下：
```
options zfs zfs_arc_max=8589934592
```
**注意**:如果所需的zfs_arc_max值小于或等于 zfs_arc_min（默认为系统内存的 1/32），则将忽略zfs_arc_max，除非您还将zfs_arc_min设置为最多 zfs_arc_max - 1。

如下，在256G内存的系统上，限制ARC为8GB，需要设置zfs_arc_min -1。只设置zfs_arc_max是不行的
```
echo "$[8 * 1024*1024*1024 - 1]" >/sys/module/zfs/parameters/zfs_arc_min
echo "$[8 * 1024*1024*1024]" >/sys/module/zfs/parameters/zfs_arc_max
```
如果根文件系统是 ZFS，则每次更改此值时都必须更新初始化接口：
``` update-initramfs -u```，同时重新启动才能激活这些更改。

## 3.8.7 ZFS 上的 SWAP

使用 zvol 创建 SWAP 分区可能会导致一些问题，例如系统卡死或者很高的 IO 负载。特别是
在向外部存储备份文件时会容易触发此类问题。

我们强烈建议为 ZFS 配置足够的物理内存，避免系统出现可用内存不足的情形。如果实在
想要创建一个 SWAP 分区，最好是直接在物理磁盘上创建。

可以在安装 Proxmox VE 时通过高级选项设置预留磁盘空间，以便创建 SWAP。此外，你可以调低“swappiness”参数值。通常，设置为 10 比较好。

`sysctl -w vm.swappiness=10`

如果需要将 swappiness 参数设置持久化，可以编辑文件`/etc/sysctl.conf`，插入下内容：

`vm.swappiness=10`


下表示 Linux 内核 swappiness 参数设置表
|值 |对应策略|
|---|------|
|vm.swappiness=0 |内核仅在内存耗尽时进行 swap|。
|vm.swappiness=1| 内核仅执行最低限度的 swap。|
|vm.swappiness=10| 当系统有足够多内存时，可考虑使用该值，以提高系统性能。|
|vm.swappiness=60 |默认设置值。|
|vm.swappiness=100 |内核将尽可能使用 swap|


## 3.8.8 加密 ZFS 数据集
ZFS on Linux 在 0.8.0 版之后引入了本地数据集加密功能。将 ZFS on Linux 升级后，就可以
对指定存储池启用加密功能：
```
zpool get feature@encryption tank
NAME PROPERTY VALUE SOURCE
tank feature@encryption disabled local

zpool set feature@encryption=enabled

zpool get feature@encryption tank
NAME PROPERTY VALUE SOURCE
tank feature@encryption enabled local
```
目前还不支持通过 Grub 从加密数据集启动系统，并且在启动过程中对自动解锁加密数据集的支持也很弱。不支持加密功能的旧版 ZFS 也不能解密相关数据。

建议在启动后手工解锁存储数据集，或使用 zfs load-key 命令将启动中解锁数据集所需 key

在对生产数据正式启用加密功能前，建议建立并测试备份程序有效性。注意，一旦 key 信息丢失，将永远不可再访问加密数据。

创建数据集`/zvols `时需要设置加密，并且默认情况下会继承到子数据集。例如，要创建加密的数据集 `tank/encrypted_data `并将其配置为 Proxmox VE 中的存储，请运行以下命令：

```
zfs create -o encryption=on -o keyformat=passphrase tank/encrypted_data
Enter passphrase:
Re-enter passphrase:
pvesm add zfspool encrypted_zfs -pool tank/encrypted_data
 ```

在此存储上创建的所有来宾卷/磁盘都将使用父数据集的共享密钥材料进行加密。

要实际使用存储，需要加载关联的密钥材料并装载数据集。这可以通过以下步骤一步完成：

``` 
zfs mount -l tank/encrypted_data
Enter passphrase for 'tank/encrypted_data':
```

还可以使用（随机）密钥文件，而不是通过设置密钥分配和密钥格式属性来提示输入密码，无论是在创建时还是在现有数据集上使用 zfs 更改键：
``` 
dd if=/dev/urandom of=/path/to/keyfile bs=32 count=1
zfs change-key -o keyformat=raw -o keylocation=file:///path/to/keyfile tank/encrypted_data
```

**警告**	使用密钥文件时，需要特别注意保护密钥文件，防止未经授权的访问或意外丢失。没有密钥文件，则无法访问纯文本数据！

在加密数据集下创建的来宾卷将相应地设置其 encryptionroot 属性。密钥材料只需在每个加密根加载一次，即可用于其下的所有加密数据集。

有关更多详细信息和高级用法，请参阅加 man zfs 手册的 Encryption 小节，包括 encryptionroot，encryption，
keylocation，keyformat 和 keystatus 属性，zfs load-key，zfs unload-key 和 zfs change-key


## 3.8.10. ZFS 中的压缩
在数据集上启用压缩后，ZFS 会尝试在写入所有新块之前对其进行压缩，并在读取时解压缩它们。现有数据将不会被追溯压缩。

您可以使用以下命令启用压缩：
```
 zfs set compression=<algorithm> <dataset>
```

我们建议使用 lz4 算法，因为它增加的 CPU 开销非常少。其他算法，如 lzjb 和 gzip-N，其中 N 是从 1（最快）到 9（最佳压缩比）的整数，也可用。根据算法和数据的可压缩性，启用压缩甚至可以提高 I/O 性能。

您可以随时禁用压缩：
```
zfs set compression=off <dataset>
```
同样，只有新块会受到此更改的影响。

## 3.8.11. ZFS 特殊设备

由于版本 0.8.0 ZFS 支持特殊设备。池中的特殊设备用于存储元数据、重复数据删除表和可选的小型文件块。

特殊设备可以提高由具有大量元数据更改的慢速旋转硬盘组成的池的速度。例如，涉及创建、更新或删除大量文件的工作负载将受益于特殊设备的存在。ZFS数据集还可以配置为在特殊设备上存储整个小文件，这可以进一步提高性能。特殊设备应使用快速SSD。

特殊设备的冗余应与池中的冗余相匹配，因为特殊设备是整个池的故障点。

**注意** 无法撤消将特殊设备添加到池中的过程！

**使用特殊设备和 RAID-1 创建池：**
```
zpool create -f -o ashift=12 <pool> mirror <device1> <device2> special mirror <device3> <device4>
```
**使用 RAID-1 将特殊设备添加到现有池中：**
```
zpool add <pool> special mirror <device1> <device2>
```
ZFS 数据集支持 special_small_blocks=<大小> 属性。size可以为0，这样可以禁止在特殊设备上存储小文件，或者设置512B到128K之间的2的幂值。设置后，将在特殊设备上分配小于该大小的新文件块。

**注意**，如果special_small_blocks的值大于或等于数据集的记录大小（默认为 128K），则所有数据都将写入特殊设备，因此请小心设置。

在池上设置 special_small_blocks， 所有的子数据集会继承此值。（例如，池中的所有容器都将选择加入小文件块）。

为整个池设置值：
``` 
zfs set special_small_blocks=4K <pool>
```
为单个数据集设置值：
```
zfs set special_small_blocks=4K <pool>/<filesystem>
```

禁止某个数据集存储小文件块：
``` 
zfs set special_small_blocks=0 <pool>/<filesystem>
```


## 3.8.12. ZFS 池功能

对 ZFS 中磁盘格式的更改仅在主要版本更改之间进行，并通过功能指定。所有特征以及一般机制都在 zpool-features（5）手册页中查询到。

由于启用新功能会使池无法由旧版本的 ZFS 导入，因此需要管理员通过在池上运行 zpool 升级来主动完成此操作（请参阅 zpool-upgrade（8） 手册页）。

除非您需要使用其中一项新功能，否则启用它们没有任何好处。

实际上，启用新功能有一些缺点：

- 如果 rpool 上激活了新功能，则仍然使用 grub 引导的 ZFS 根目录的系统将变得无法启动，因为 grub 中 ZFS 的实现不兼容。

- 使用较旧的内核引导时，系统将无法导入任何升级的池，该内核仍随旧的 ZFS 模块一起提供。

- 引导较旧的Proxmox VE ISO来修复非引导系统同样不起作用。
  
**注意**：如果您的系统仍然使用 grub 引导，请不要升级 rpool，因为这会使您的系统无法引导。这包括在 Proxmox VE 5.4 之前安装的系统，以及使用旧版 BIOS 引导的系统（请参阅如何确定引导加载程序）。

为 ZFS 池启用新功能：
```
zpool upgrade <pool>
```



