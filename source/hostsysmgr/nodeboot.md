# 3.12. 主机引导加载程序

Proxmox VE 目前使用两个引导加载程序之一，具体取决于安装程序中选择的磁盘设置。

对于随 ZFS 一起安装的 EFI 系统，将使用根文件系统 systemd-boot。所有其他部署都使用标准的 grub 引导加载程序（这通常也适用于安装在 Debian 之上的系统）

## 3.12.1. 安装程序使用的分区方案

Proxmox VE 安装程序在选择安装的所有磁盘上创建 3 个分区。

创建的分区包括：

- 一个 1 MB BIOS 启动分区（gdisk 类型 EF02）

- 一个 512 MB 的 EFI 系统分区（ESP，gdisk 类型 EF00）

- 第三个分区，跨越设置的 hdsize 参数或用于所选存储类型的剩余空间

使用 ZFS 作为根文件系统的系统使用存储在 512 MB EFI 系统分区上的内核和 initrd 映像进行引导。对于旧版 BIOS 系统，使用 grub，对于 EFI 系统，则使用系统启动。两者都已安装并配置为指向 ESP。

在 BIOS 模式 （--target i386-pc） 下，grub 被安装到使用 grub [5] 引导的所有系统上所有选定磁盘的 BIOS 引导分区上。

## 3.12.2. 使用 proxmox-boot-tool 同步 ESP 的内容
proxmox-boot-tool 是一个实用程序，用于保持 EFI 系统分区的内容正确配置和同步。它将某些内核版本复制到所有 ESP，并将相应的引导加载程序配置为从 vfat 格式的 ESP 引导。在 ZFS 作为根文件系统的上下文中，这意味着您可以使用根池上的所有可选功能，而不是在 grub 中的 ZFS 实现中也存在的子集，或者必须创建一个单独的小型引导池 [6]。

在具有冗余的设置中，安装程序使用 ESP 对所有磁盘进行分区。这可确保即使第一个引导设备出现故障或 BIOS 只能从特定磁盘引导，系统也能引导。

在正常操作期间，不会保持安装 ESP。这有助于防止在发生系统崩溃时文件系统损坏 vfat 格式的 ESP，并且无需在主引导设备出现故障时手动调整 /etc/fstab。

proxmox-boot-tool 处理以下任务：
- 格式化和设置新分区

- 将新的内核映像和初始化映像复制和配置到所有列出的 ESP

- 同步内核升级和其他维护任务的配置

- 管理已同步的内核版本列表

您可以通过运行以下命令来查看当前配置的 ESP 及其状态：
```
 proxmox-boot-tool status
```
### 设置新分区以用作同步的 ESP
要将分区格式化并初始化为同步的 ESP，例如，在替换 rpool 中出现故障的 vdev 之后，或者在转换早于同步机制的现有系统时，可以使用 `pve-kernel-helpers` 中的 `proxmox-boot-tool`。

format命令将格式化<分区>，请确保传入正确的设备/分区！

例如，要将空分区 /dev/sda2 格式化为 ESP，请运行以下命令：
```
proxmox-boot-tool format /dev/sda2
```

要设置位于 /dev/sda2 上的现有未挂载 ESP 以包含在 Proxmox VE 的内核更新同步机制中，请使用以下命令：

```
proxmox-boot-tool init /dev/sda2
```
之后，```/etc/kernel/proxmox-boot-uuids```应该包含一个新行，其中包含新添加分区的UUID。init 命令还将自动触发所有已配置的 ESP 的刷新。

### 更新所有 ESP 上的配置
要复制和配置所有可引导内核，并使 /etc/kernel/proxmox-boot-uuid 中列出的所有 ESP 保持同步，您只需运行：

```
proxmox-boot-tool refresh
```
（等效于在 root 上运行具有 ext4 或 xfs 的 update-grub 系统）。

如果您要对内核命令行进行更改，或者想要同步所有内核和初始化，这是必需的。

update-initramfs 和 apt（如有必要）都将自动触发刷新。

proxmox-boot-tool 考虑的内核版本

默认情况下配置以下内核版本：

- 当前运行的内核

- 软件包更新中新安装的版本

- 两个最新已安装的内核

- 倒数第二个内核系列的最新版本（例如 5.0、5.3），如果适用

- 任何手动选择的内核

### 手动保持内核可引导
如果您希望将某个内核和initrd映像添加到可引导内核列表中，请使用proxmox-boot-tool内核添加。

例如，运行以下命令，将 ABI 版本为 5.0.15-1-pve 的内核添加到内核列表中，以保持安装并同步到所有 ESP：

```
proxmox-boot-tool kernel add 5.0.15-1-pve
```

```proxmox-boot-tool ```内核列表将列出当前选择用于引导的所有内核版本：

```
proxmox-boot-tool 内核列表将列出当前选择用于引导的所有内核版本：
```

运行 proxmox-boot-tool kernel remove 以从手动选择的内核列表中删除内核，例如：

```
# proxmox-boot-tool kernel remove 5.0.15-1-pve
```

需要运行` proxmox-boot-tool reflash`，以便在手动添加或从上面删除内核后更新所有 EFI 系统分区 （ESP）。

## 3.12.3. 确定使用哪个引导加载程序

确定使用哪个引导加载程序的最简单，最可靠的方法是观察Proxmox VE节点的引导过程。

您将看到蓝色的 grub 盒或简单的白色 systemd-boot 上的黑色。

从正在运行的系统确定引导加载程序可能不是 100% 准确的。最安全的方法是运行以下命令：

```
 efibootmgr -v

```
如果它返回一条消息，指出 EFI 变量不受支持，则在 BIOS/旧模式中使用 grub。

如果输出包含类似于以下内容的行，则在 UEFI 模式下使用 grub。
```
Boot0005* proxmox       [...] File(\EFI\proxmox\grubx64.efi)
```

如果输出包含类似于以下内容的行，则使用 systemd-boot。

```
Boot0006* Linux Boot Manager    [...] File(\EFI\systemd\systemd-bootx64.efi)
```

通过运行：
```
 proxmox-boot-tool status
```
您可以了解是否配置了``proxmox-boot-tool``，这可以很好地指示系统的引导方式。

## 3.12.4. Grub

grub 多年来一直是引导 Linux 系统的事实标准，并且有多的文档记录 [7]。


### 配置

对 grub 配置的更改是通过 /etc/default/grub 中的默认文件 /etc/default/grub 或配置片段完成的。要在更改配置后重新生成配置文件，请运行
```
 update-grub
```
## 3.12.5. Systemd-boot

systemd-boot 是一个轻量级的 EFI 引导加载程序。它直接从安装它的 EFI 服务分区 （ESP） 读取内核和 initrd 映像。从 ESP 直接加载内核的主要优点是，它不需要重新实现用于访问存储的驱动程序。在 Proxmox VE 中，proxmox-boot-tool 用于使 ESP 上的配置保持同步。

## 配置
systemd-boot 是通过 EFI 系统分区 （ESP） 根目录中的文件加载程序/loader.conf 配置的。有关详细信息，请参阅 loader.conf（5） 手册页。

每个引导加载程序条目都放在目录加载程序/条目/中自己的文件中

一个示例 entry.conf 如下所示（/ 引用 ESP 的根）：
```
title    Proxmox
version  5.0.15-1-pve
options   root=ZFS=rpool/ROOT/pve-1 boot=zfs
linux    /EFI/proxmox/5.0.15-1-pve/vmlinuz-5.0.15-1-pve
initrd   /EFI/proxmox/5.0.15-1-pve/initrd.img-5.0.15-1-pve
```

## 3.12.6. 编辑内核命令行

您可以在以下位置修改内核命令行，具体取决于所使用的引导加载程序：

### GRUB
内核命令行需要放在变量`GRUB_CMDLINE_LINUX_DEFAULT`文件中 `/etc/default/grub `中。运行 `update-grub` 会将其内容附加到` /boot/grub/grub.cfg` 中的所有 linux 条目。

### Systemd-boot
内核命令行需要作为一行放在 `/etc/kernel/cmdline `中。要应用更改，请运行 `proxmox-boot-tool `刷新，这会将其设置为` loader/entries/proxmox-*.conf `中所有配置文件的选项行。





