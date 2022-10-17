# 7.10 基于本地ZFS的后端存储

存储池类型：zfspool

该类型后端存储基于本地ZFS存储池（或ZFS存储池中的ZFS文件系统）建立。

## 7.10.1 配置方法

ZFS后端存储支持公共存储服务属性content、nodes、disable，以及如下的ZFS特有属性：

- pool

用于设置所使用的ZFS存储池/文件系统名称。所有的Proxmox VE存储卷都将在指定的存储池分配。

- blocksize

用于设置ZFS数据块大小。

- sparse

用于设置启用ZFS的薄存储模式。薄模式下，一个存储卷的大小等于其内部数据所占用的实际空间，而非分配给它的总空间。

配置示例（`/etc/pve/storage.cfg`）

```
zfspool: vmdata
       pool tank/vmdata
       content rootdir,images
       sparse
```

## 7.10.2文件命名规范

ZFS后端存储采用如下虚拟机镜像文件命名规范：

vm-<VMID>-<NAME> 	// 普通虚拟机镜像
base-<VMID>-<NAME> 	// 虚拟机模板（只读）
subvol-<VMID>-<NAME> 	// 容器镜像（使用ZFS文件系统存储容器）

- <VMID>

镜像文件所属的虚拟机ID.

- <NAME>

可以是任何不包含空白字符的字符串（ascii）。目录后端存储默认设置为disk-[N]，其中[N]是一个不重复的整数序号。

## 7.10.3存储功能

在快照功能和克隆功能方面，ZFS大概是最强大的后端存储方案。ZFS后端存储同时支持虚拟机镜像（raw格式）和容器镜像（subvol格式）的存储。ZFS的配置继承自上级存储池，所以你只需配置上级存储池使用默认属性值即可。


|数据类型 |镜像格式 |支持共享| 支持快照 |支持链接克隆|
|-----|-----|-----|----|-----|
|虚拟机镜像 容器镜像 |raw qcow2 vmdk subvol|是|qcow2|qcow2|

## 7.10.4示例

推荐创建另外的ZFS文件系统以存储虚拟机镜像：

``` 
zfs create tank/vmdata
```

如下命令在新建文件系统开启数据压缩功能：

 ```
zfs set compression=on tank/vmdata
```

如下命令用于列出可用的ZFS文件系统：

```
pvesm zfsscan
```
