# 10.7虚拟机和磁盘镜像导入

其他虚拟机管理器导出的虚拟机一般由一个或多个磁盘镜像和一个虚拟机配置文件（描述内存，CPU数量）构成。

如果虚拟机由VMware或VirtualBox导出，磁盘镜像有可能是vmdk格式，如果从KVM管理器导出，可能是qcow2格式。最流行的虚拟机导出格式是OVF标准，但实际上由于OVF标准本身不完善，以及虚拟机管理器导出的众多非标准扩展信息，跨管理器使用OVF往往受很多限制。

除了格式不兼容之外，如果虚拟机管理器之间的虚拟硬件设备差别太大，也可能导致虚拟机镜像导入失败。特别是Windows虚拟机，对于硬件变化特别敏感。为解决这一问题，可以在导出Windows虚拟机之前安装MergeIDE.zip，并在导入后启动前将虚拟磁盘改为IDE类型。

最后还需要考虑半虚拟化驱动因素。半虚拟化驱动能够改善虚拟硬件性能，但往往针对特定虚拟机管理器。GNU/Linux和其他开源Unix类操作系统默认已经安装所有必要的半虚拟化驱动，可以在导入虚拟机后直接改用半虚拟化驱动。对于Windows虚拟机，还需要自行安装Windows版本的半虚拟化驱动软件。

GNU/Linux和其他开源Unix虚拟机通常可以直接导入。但由于以上提到的因素，不能保证所有Windows虚拟机均能够顺利导入成功。

## 10.7.1 Windows OVF导入步骤示例

Microsoft为Windows开发提供了[虚拟机下载服务](https://developer.microsoft.com/en-us/windows/downloads/virtual-machines/)。以下将利用这些镜像演示OVF导入功能。

下载虚拟机镜像压缩包

在选择同意用户协议后，选择基于VMware的Windows 10 Enterprise（Evaluation-Build），下载zip压缩包。

从zip压缩包提取磁盘镜像

使用unzip或其他工具解压缩zip压缩包，通过ssh/scp将ovf和vmdk文件复制到Proxmox VE服务器。

导入虚拟机

执行以下命令可以创建新虚拟机，虚拟机的CPU、内存和名称沿用OVF配置文件中的设置，磁盘镜像将导入local-lvm存储。网络配置可以手工完成。

```
qm importovf 999 WinDev1709Eval.ovf local-lvm
```

至此，虚拟机导入完成，可以启动使用。


## 10.7.2向虚拟机增加外部磁盘镜像

可以将磁盘镜像直接添加到虚拟机。磁盘镜像可以是外部虚拟机管理器导出的，也可以是你自己创建的。
首先使用vmdebootstrap工具创建Debian/Ubuntu磁盘镜像：

```
vmdebootstrap --verbose \
--size 10GiB --serial-console \
--grub --no-extlinux \
--package openssh-server \
--package avahi-daemon \
--package qemu-guest-agent \
--hostname vm600 --enable-dhcp \
--customize=./copy_pub_ssh.sh \
--sparse --image vm600.raw
```

然后创建一个新的虚拟机。
```
qm create 600 --net0 virtio,bridge=vmbr0 --name vm600 --serial0 socket \
--bootdisk scsi0 --scsihw virtio-scsi-pci --ostype l26
```
将磁盘镜像以unused0导入虚拟机，存储位置为`pvedir`：

```
qm importdisk 600 vm600.raw pvedir
```
最后将磁盘连接到虚拟机的SCSI控制器：

```
qm set 600 --scsi0 pvedir:600/vm-600-disk-1.raw
```

至此，虚拟机导入完成，可以启动使用。
