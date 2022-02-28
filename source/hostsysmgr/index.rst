第三章 系统管理
===============================
Proxmox VE基于著名的Debian Linux发行版。也就是说，你可以充分利用Debian操作系统的所有软件包资源，以及Debian完善的技术文档。可以在线阅读Debian Administrator’s Handbook，深入了解Debian操作系统的有关内容（见[Hertzorg13]）。

Proxmox VE安装后默认配置使用Debian的默认软件源，所以你可以通过该软件源直接获取补丁修复和安全升级。
此外，我们还提供了Proxmox VE自己的软件源，以便升级Proxmox VE相关的软件包。这其中还包括了部分必要的Debian软件包升级补丁。
我们还为Proxmox VE提供了一个专门优化过的Linux内核，其中开启了所有必需的虚拟化和容器功能。该内核还提供了ZFS相关驱动程序，以及多个硬件驱动程序。
例如我们在内核中包含了Intel网卡驱动以支持最新的Intel硬件设备。

后续章节将集中讨论虚拟化相关内容。有些内容是关于Debian和Proxmox VE的不同之处，有些是关于Proxmox VE的日常管理任务。更多内容请参考Debian相关文档。

.. toctree::
   :maxdepth: 2


   aptsource.md
   syssoftupdate.md
   netconfig.md

