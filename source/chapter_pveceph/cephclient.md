# 8.8 Ceph 客户端

完成上面的步骤后，接下来可以配置Proxmox VE使用pool存储虚拟机或容器镜像。通过GUI增加RBD存储即可（参见[7.15节](../Storage/rbd.md)”）

也可以将keyring复制到外部Ceph集群指定位置。如果Ceph就安装在Proxmox节点，该操作将自动完成。

- 注意
  - 文件名称需要采用<storage_id>+’.keyring的格式。其中<storage_id>配置文件/etc/pve/storage.cfg中rbd:后面的存储名称。下面例子中采用my-ceph-storage的名称。

```
mkdir /etc/pve/priv/ceph
cp /etc/ceph/ceph.client.admin.keyring /etc/pve/priv/ceph/my-ceph-storage.keyring
```

