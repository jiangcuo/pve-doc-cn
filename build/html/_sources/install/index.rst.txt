第二章 Proxmox VE安装
===============================
Proxmox VE基于Debian Linux操作系统，官方提供有ISO光盘镜像，其中包含了一个完整的Debian Linux操作系统（Proxmox VE 5.x使用的是”stretch”版本的Debian）和Proxmox VE的所有基本软件包。

使用安装向导可以帮助完成整个安装过程，包括本地磁盘分区，基本系统设置（例如，时区，语言，网络），软件包安装等。使用官方ISO可以在几分钟内完成安装，这也是首推使用官方ISO安装的原因。

当然，也可以先安装Debian操作系统，然后再安装Proxmox VE软件包。但这种安装方法需要对Proxmox VE有很深入的了解，仅推荐高级用户使用。

.. toctree::
   :maxdepth: 3


   requirt.rst
   installmedia.rst
   installpve.rst
   installpveondebian.rst

