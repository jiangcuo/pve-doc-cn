# 7.9基于GlusterFS的后端存储

存储池类型：glusterfs

GlusterFS是一个可水平扩展的网络文件系统。GlusterFS具有模块化设计，兼容常见硬件等优点，是一种低成本的高可用企业级存储解决方案。GlusterFS能够支持扩容到数P字节容量，并可同时支持数千客户端连接。

注意：

在遭遇节点/brick故障时，GlusterFS会通过rsync重新同步数据，而大文件同步往往会需要很长时间，所以GlusterFS不适宜用于虚拟机镜像存储。在遭遇节点/brick故障时，GlusterFS会通过rsync重新同步数据，而大文件同步往往会需要很长时间，所以GlusterFS不适宜用于虚拟机镜像存储。


## 7.9.1 配置
GlusterFS后端存储支持全部的公共存储服务属性，以及如下的GlusterFS特有属性：

- server

GlusterFS存储服务器IP或DNS域名。

- server2
GlusterFS备用存储服务器IP或DNS域名。

- volume
GlusterFS卷名称。

- transport

GlusterFS网络传输协议：tcp，unix或rdma。


配置示例（`/etc/pve/storage.cfg`）

```
glusterfs: Gluster
        server 10.2.3.4
        server2 10.2.3.5
        volume glustervol
        content images,iso
```

## 7.9.2 文件命名规则

目录布局和文件命名规则与dir后端相同。

## 7.9.3 存储功能

glusterf提供文件级共享，无法在PVE上实现快照和链接克隆。但可利用qcow2文件格式的支持进行虚拟机快照和链接克隆。

|数据类型 |镜像格式 |支持共享| 支持快照 |支持链接克隆|
|-----|-----|-----|----|-----|
|虚拟机镜像  容器模板 iso镜像 虚拟机备份 片段 |raw qcow2 vmdk |是|qcow2|qcow2|

