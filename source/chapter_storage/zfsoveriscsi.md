# 7.18. 基于 ISCSI 后端的 ZFS

存储池类型：zfs

此后端通过ssh访问具有 ZFS 池作为存储和 iSCSI 目标实现的远程机器。它为每个来宾磁盘创建一个 ZVOL，并将其导出为 iSCSI LUN。Proxmox VE 将这个 LUN 用于来宾磁盘。

支持以下ISCSI目标提供者：

- LIO (Linux)
- LET (Linux)
- ISTGT (FreeBSD)
- Comstar (Solaris)

此插件需要支持 ZFS 的远程存储设备，您不能使用它在常规存储设备/SAN 上创建 ZFS 池

## 7.18.1. 配置

为了使用 ZFS over iSCSI 插件，您需要将远程机器（目标）配置为接受来自 Proxmox VE 节点的ssh连接。Proxmox VE 连接到目标以创建 ZVOL 并通过 iSCSI 导出它们。

身份验证通过存储在/etc/pve/priv/zfs/<target_ip>_id_rsa中的ssh密钥（无密码保护）.

以下步骤创建一个ssh-key并将其传递到IP为 192.0.2.1 的存储机器：

```
mkdir /etc/pve/priv/zfs 
ssh-keygen -f /etc/pve/priv/zfs/192.0.2.1_id_rsa 
ssh-copy-id -i /etc/pve/priv/zfs/192.0.2.1_id_rsa.pub root @192.0.2.1 
ssh -i /etc/pve/priv/zfs/192.0.2.1_id_rsa root@192.0.2.1
```

后端支持常见的存储属性content、nodes、 disable和以下 ZFS over ISCSI 特定属性：

- 资源池 

在ISCSI目标上的ZFS下的pool或pool下的文件系统，所有分配都在该池中完成。

- 门户

iSCSI 门户（带有可选端口的 IP 或 DNS 名称）。

- 目标

iSCSI目标

- iSCSI提供者

远程机器上使用的iSCSI提供程序

- 目标群组

使用comstar时的目标群组

- 主机群组

使用comstar时的主机群组

- 目标门户组

Linux LIO 目标的目标门户组

- 写缓存

在目标上禁用或者开启写缓存

- 块大小

设置ZFS块大小

- 精简配置

使用 ZFS 精简配置。实际大小不等于卷大小的卷。

## 配置示例 ( /etc/pve/storage.cfg )

```

zfs: lio
   blocksize 4k
   iscsiprovider LIO
   pool tank
   portal 192.0.2.111
   target iqn.2003-01.org.linux-iscsi.lio.x8664:sn.xxxxxxxxxxxx
   content images
   lio_tpg tpg1
   sparse 1

zfs: solaris
   blocksize 4k
   target iqn.2010-08.org.illumos:02:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx:tank1
   pool tank
   iscsiprovider comstar
   portal 192.0.2.112
   content images

zfs: freebsd
   blocksize 4k
   target iqn.2007-09.jp.ne.peach.istgt:tank1
   pool tank
   iscsiprovider istgt
   portal 192.0.2.113
   content images

zfs: iet
   blocksize 4k
   target iqn.2001-04.com.example:tank1
   pool tank
   iscsiprovider iet
   portal 192.0.2.114
   content images

   ```

## 7.18.2. 存储功能

ZFS over iSCSI 插件提供了一个可以创建快照的共享存储。您需要确保 ZFS 设备不会成为部署中的单点故障。

表 17. 后端iSCSI的存储功能

|数据类型 |镜像格式 |支持共享| 支持快照 |支持链接克隆|
|-----|-----|-----|----|-----|
|磁盘镜像 | raw |是|是|否|
