
第八章  部署超融合Ceph集群
===============================

Proxmox VE 统一了您的计算和存储系统，也就是说，您可以将集群中的相同物理节点用于计算（处理虚拟机和容器）和复制存储。传统的计算和存储资源可以集成到单个超融合设备中。
独立的存储网络 (SAN) 和通过网络附加存储 (NAS) 的连接消失了。
通过集成开源软件定义存储平台 Ceph，Proxmox VE 能够直接在管理程序节点上运行和管理 Ceph 存储。

Ceph 是一个分布式对象存储和文件系统，旨在提供出色的性能、可靠性和可扩展性。


Proxmox VE 上 Ceph 的一些优点是：

- 可以通过CLI和GUI轻松安装管理
- 支持薄模式存储
- 支持快照
- 自动修复
- 容量最大可扩充至exabyte级别
- 支持多种性能和冗余级别的存储池
- 多副本，高容错
- 可在低成本硬件运行
- 无需硬件raid控制器
- 开源软件


对于中小型部署可以直接在Proxmox VE集群节点上安装用于RADOS块设备(RBD)的Ceph服务器（请参阅 (Ceph RADOS 块设备 (RBD))[https://pve.proxmox.com/pve-docs/pve-admin-guide.html#ceph_rados_block_devices]）。最近的硬件有很多 CPU 能力和 RAM，因此在同一个节点上运行存储服务和 VM 是可能的。

为了简化管理，我们提供了pveceph——一个用于在 Proxmox VE 节点上安装和管理Ceph服务的工具。


Ceph 由多个守护进程组成，用作 RBD 存储：

- Ceph 监视器 (ceph-mon)
- Ceph 管理器 (ceph-mgr)
- Ceph OSD（ceph-osd；对象存储守护进程）



.. toctree::
   :maxdepth: 2

   Precondition.md
   initceph.md
   cephmon.md
   cephmgr.md
   cephosd.md
   cephpools.md
   cephcrush.md