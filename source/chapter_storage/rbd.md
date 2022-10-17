# 7.15基于Ceph RADOS块设备的后端存储

存储池类型：rbd

Ceph是一种同时支持对象存储和文件存储的高性能分布式存储解决方案，其设计兼顾高性能、可靠性、可扩展性。RADOS块设备是一种功能强大的块级别存储设备，优势如下：

- 薄模式存储

- 存储卷容量可调
- 分布式存储及多副本存储（基于多个OSD的条带）

- 支持快照和链接式克隆

- 数据自修复

- 无单点故障

- 容量可扩展至数E字节。

- 支持内核空间和用户空间实现



注意:

小规模部署场景下，也可以直接在Proxmox VE服务器上运行Ceph存储服务。近些年服务器的CPU和内存配置足以支持同时运行存储服务和虚拟机应用。


	
## 7.15.1配置方法
rbd后端存储支持公共存储服务属性content、nodes、disable，以及如下的rbd特有属性：

- monhost
用于设置监控服务绑定的IP地址。

- pool
用于设置Ceph存储池名称。

- username
Ceph用户ID。

- krbd
设置强制通过内核模块krbd访问rbd存储服务。可选。

注意:

容器将自动通过krbd访问rbd，不受该参数设置影响。


配置外部Ceph集群示例（`/etc/pve/storage.cfg`）
```
rbd: ceph-external
    monhost 10.1.1.20 10.1.1.21 10.1.1.22
    pool ceph-external
    content images
    username admin
```
提示:
Ceph底层管理任务可以使用rbd命令完成。

## 7.15.2认证方式

如选择使用cephx认证方式，需要将密钥文件从外部Ceph集群复制到Proxmox VE服务器。首先运行如下命令创建目录`/etc/pve/priv/ceph`
```
mkdir /etc/pve/priv/ceph
```
然后复制密钥文件
```
scp <cephserver>:/etc/ceph/ceph.client.admin.keyring /etc/pve/priv/ceph/<STORAGE_ID>.keyring
```

密钥文件名称需要和<STORAGE_ID>一致。注意复制操作需要root权限才能完成。

如果Ceph就安装在PVE集群本地，可使用pveceph命令，或在GUI操作，将自动完成密钥文件复制过程。

## 7.15.3存储功能

rbd属于块存储解决方案，并支持快照和链接克隆。

表 14.后端 rbd 的存储功能

|数据类型 |镜像格式 |支持共享| 支持快照 |支持链接克隆|
|-----|-----|-----|----|-----|
|虚拟机镜像 容器镜像 |RAW |是|是|是|
