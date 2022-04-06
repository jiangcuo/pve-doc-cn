# 7.16基于Ceph 文件系统（CephFS）的后端存储

存储池类型：cephfs

CephFS是一种兼容POSIX标准的文件系统，后台使用Ceph集群保存数据。CephFS基于Ceph技术，兼具Ceph大部分特性，包括冗余性，横向扩展，自我修复和高可用性。

提示 :

Proxmox VE提供ceph安装功能，见4.2节，能够简便快捷地配置CephFS。当前主流硬件的CPU和内存资源已经足够强大，完全可以同时支持虚拟机和CephFS的运行。

如需使用CephFS存储插件，需要升级Ceph客户端。按3.1.4节内容增加Ceph软件源。然后运行apt update和apt dist-upgrade，即可升级到最新软件版本。

必须确认没有配置使用其他的Ceph软件源，否则安装将失败，节点上的软件包版本也将来自不同软件源，并导致未知后果。

## 7.16.1配置方法
CephFS后端存储支持公共存储服务属性nodes，disable，content，以及如下的cephfs特有属性：

- monhost

用于设置监视器进程地址列表。本参数为可选参数，仅在使用外部Ceph存储时需要配置。

- path

用于设置本地挂载点。本参数为可选参数。默认为/mnt/pve/<STORAGE_ID>/。

- username

用于设置Ceph用户ID。本参数为可选参数。仅在用外部Ceph存储时需要配置。默认为admin。

- subdir

用于设置待挂载的CephFS子目录。本参数为可选参数。默认为/。

- fuse

用于设置通过FUSE访问CephFS。未启用时默认通过内核客户端访问。本参数为可选参数。默认为0。

示例：外部Ceph集群配置样例（`/etc/pve/storage.cfg`）

```
cephfs: cephfs-external
	monhost 10.1.1.20 10.1.1.21 10.1.1.22
	path /mnt/pve/cephfs-external
	content backup
	username admin
```

提示:

如未关闭cephx，请务必记住配置客户端密钥。

## 7.16.2认证方式

默认使用cephx认证，如需使用该认证方式，需要把外部Ceph集群密钥复制到Proxmox VE主机。
创建目录/etc/pve/priv/ceph，命令如下：

```
mkdir /etc/pve/priv/ceph
```

然后复制密钥，命令如下：

```
scp cephfs.secret <proxmox>:/etc/pve/priv/ceph/<STORAGE_ID>.secrett
```

密钥名称必须与<STORAGE_ID>一致。密钥复制操作一般需要提供root权限才能完成。文件必须只包含密钥本身。这一点与rbd后端密钥不一致，rbd密钥还包含了[client.userid]小节。

密钥可以从外部ceph集群（使用ceph管理员用户）提取得到，命令如下。注意使用能够访问集群的真实客户端ID替换userid。关于ceph用户管理的进一步信息，可以查看Ceph文档。

```
ceph auth get-key client.userid > cephfs.secret
```

如果Ceph安装在Proxmox VE集群本地，也就是通过pveceph命令安装，以上步骤会在安装时自动完成。


## 7.16.3存储功能
cephfs属于兼容POSIX标准的文件系统，其底层采用Ceph集群存储。

	
|数据类型 |镜像格式 |支持共享| 支持快照 |支持链接克隆|
|-----|-----|-----|----|-----|
|容器模板 虚拟机备份 ISO 片段 | none |是|是[1]|否|

[1] 虽然不存在已知的错误，但快照还不能保证是稳定的，因为它们缺乏足够的测试。




