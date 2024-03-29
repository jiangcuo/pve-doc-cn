
第十章 Qemu/KVM虚拟机
===============================

Qemu（Qemu模拟器的简称）是一个开源的虚拟机管理软件，主要功能是模拟物理计算机。
在运行Qemu的主机看来，Qemu就是一个普通的用户进程，将主机拥有的硬盘分区、文件、网卡等本地资源虚拟成物理硬件设备并映射给模拟计算机使用。

模拟计算机的操作系统访问这些虚拟硬件时，就好像在访问真正的物理硬件设备一样。例如，当你设置Qemu参数向模拟计算机映射一个ISO镜像时，模拟计算机的操作系统就会看到一个插在CD驱动器里的CDROM光盘。

Qemu能够模拟包括从ARM到sparc在内的一大批硬件设备，但Proxmox VE仅仅使用了其中的32位和64位PC平台模拟硬件，而这也是当前绝大部分服务器所使用的硬件环境。
此外，借助CPU的虚拟化扩展功能，Qemu模拟相同架构硬件环境的速度可以被大大提高，虚拟PC硬件也是当前Qemu支持的运行速度最快的虚拟硬件环境。

注意：
后续章节你可能会看到KVM（Kernel-based Virtual Machine）一词。这是指Qemu借助Linux的kvm内核模块在CPU虚拟化扩展的支持下运行。在Proxmox VE里，Qemu和KVM这两个词完全可以互换使用，因为Qemu总是尝试使用kvm模块。

为方便访问块存储设备和PCI硬件，在Proxmox VE里Qemu进程总是以root权限运行。


.. toctree::
   :maxdepth: 2

   edandpd.md
   vmsetting.md
   migrate.md
   copyclone.md
   template.md
   vmgenid.md
   importdisk.md
   cloudinit.md
   pcipassthrough.md
   hookscript.md
   Hibernation.md
   qm.md
   vmconf.md
   qmlock.md