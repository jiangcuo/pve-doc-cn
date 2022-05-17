# 8.9. CephFS

Ceph也支持基于RADOS块设备的文件系统。元数据服务器（MDS）可以将RADOS块映射为文件和目录，并提供兼容POSIX标准的多副本文件系统。

用户可以很容易在Ceph上建立高可用的集群共享文件系统。元数据服务器可以确保文件平均分布在整个Ceph集群上，在高负载下也能有效避免单一节点过载，而这往往NFS等传统共享文件系统的一大痛点。

Proxmox VE支持创建超融合的CephFS，也支持挂载外部CephFS，并可用于保存备份，ISO文件，容器模板等。


## 8.9.1. 元数据服务器（MDS）

为了使用CephFS，至少需要配置一个元数据服务器。通过Proxmox VE的GUI界面，可以很容易创建元数据服务器，只需依次在打开Node→CephFS控制面板即可找到操作界面，也可以通过执行以下命令：

```
pveceph mds create
```

一个集群内也可以创建多个元数据服务器。但默认设置同一时间只能有一个元数据服务器处于活动状态。如果MDS，或者其所在节点失去响应（或者崩溃），某个standby的MDS将自动转为active。可以通过设置hotstandby参数加速主备切换，或者在对应MDS的ceph.conf文件中进行如下设置：

```
mds standby replay = true
```

启用该设置后，该备用MDS将持续轮训活动MDS的状态，相当于处于一种温备状态，能够在主MDS宕机后更快接管。当然，持续轮训会消耗一定资源，并对活动MDS的性能产生一定影响。


### 多主MDS

从Luminous（12.2.x）版本开始，可以有多个活动的元数据服务器同时运行，但这通常只在多个并发客户端的场景中有意义，MDS很少成为性能瓶颈。如果想使用该特性，情参考Ceph文档

## 创建CephFS

在Proxmox VE下，可以通过Web GUI、CLI、外部API接口等多种方式轻松创建CephFS。前置条件如下：

  创建CephFS的前置条件：

-  安装Ceph软件包
-  配置好Ceph监视器
-  配置好OSD
-  至少设置一个元数据服务器

完成以上操作后，就可以通过Web GUI的节点→CephFS面板或者命令行工具pveceph创建CephFS了。示例如下

```
pveceph fs create --pg_num 128 --add-storage
```


上面的命令将创建一个名为“cephfs”的CephFS存储池，数据存储名称为“cephfs_data”，配置128个pg，元数据存储名称为“cephfs_metadata”，配置32个数据集，也就是数据存储的四分之一。可查看[8.6 Ceph Pool](./cephpools.md)或Ceph文档以确定适当的存储集数量（pg_num）。此外，“--add-storage”参数将自动把创建成功的CephFS添加到Proxmox VE的存储配置文件中。


## 8.9.3. 删除CephFS

**警告**

- 删除操作后，CephFS上所有数据都将不可继续使用。且该操作无法撤销。

要完全且正确的删除CephFS，需要执行以下步骤：

- 断开所有非Proxmox VE客户端的连接，（如虚拟机中的Cephfs）
- 禁用所有相关的 CephFS Proxmox VE 存储条目（以防止它被自动挂载）。
- 从您要销毁的 CephFS 上的来宾（例如 ISO）中删除所有已使用的资源。
- 手动卸载所有集群节点上的 CephFS 存储
  - `umount /mnt/pve/<storage-name>`  storage-name是 Proxmox VE 中 CephFS 存储的名称。
- 现在确保没有元数据服务器 ( MDS ) 正在为该 CephFS 运行，方法是停止或销毁它们。这可以通过 Web 界面或命令行界面完成，对于后者，您将发出以下命令：
  - `pveceph stop --service mds.NAME` 然后 `pveceph mds destroy NAME` 请注意，当一个活动的MDS停止或删除时，备用服务器将自动提升为活动的，因此最好先停止所有备用服务器。
-  现在您可以使用以下命令销毁 CephFS
  - `pveceph fs destroy NAME --remove-storages --remove-pools` 这将彻底删除Cephfs池，并从Proxmox VE中删除存储

在这些步骤之后，应该完全删除 CephFS，如果您有其他 CephFS 实例，可以再次启动停止的元数据服务器以充当备用服务器。

