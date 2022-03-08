
第七章  Proxmox VE 存储
===============================

Proxmox VE 提供了非常灵活的存储配置模型。 虚拟机镜像既可以保存在一个或者多个本地存储上，也可以保存在多种共享存储上，例如 NFS 或 iSCSI（NAS，SAN）。
没有任何限制。事实上，Debian Linux 支持的所有存储技术都可以拿过来用。

使用共享存储保存虚拟机镜像的最大好处就是可以在线迁移虚拟机，只要集群的所有节点都能直接访问虚拟机磁盘镜像，那么就无需关机随意迁移，而且迁移时无需复制虚拟机镜像数
据，这样也大大提高了迁移的速度。

Proxmox VE 的存储库（libpve-storage-perl 包）具有非常灵活的插件式设计，并对所有存储技术提供了统一接口。这使 Proxmox VE 能够轻松兼容未来出现的新存储技术。

.. toctree::
   :maxdepth: 2

   type.md
   storageconfig.md
   volume.md
   storagecmdline.md
   dirstorage.md
   nfsstorege.md
   