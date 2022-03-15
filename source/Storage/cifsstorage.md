
# 7.7 基于 CIFS 的后端存储

存储池类型：cifs

基于 CIFS 的后端存储可用于扩展基于目录的存储，这样就无需再手工配置 CIFS 挂载。该类型存储可直接通过 Proxmox VE API 或 WebUI 添加。服务器心跳检测或共享输出选项等后端存储参数配置也将自动完成配置。

## 7.7.1 配置方法

CIFS 后端存储支持全部的公共存储服务属性，仅共享标识例外，而共享标识总是启用的。另外，CIFS 还提供以下特有属性:

- server
  
CIFS 存储服务器 IP 或 DNS 域名。必填项。

提示：为避免 DNS 域名查询带来的延时，直接配置 IP 地址较好─除非你的 DNS 服务器非常可靠，或者直接用/etc/hosts 文件进行域名解析

- share
  
所使用的 CIFS 共享服务（可执行 pvesm cifsscan 或在 WebUI 查看获取可用 cifs 服务）存储服务器 IP 。

- username

CIFS 存储的用户名。可选项，默认为““guest”。

- password
  
用户口令。可选项。用户口令文件仅有 root 可读（/etc/pve/priv/<STORAGE_ID>.cred）。

- domain

设置 CIFS 存储的用户域（workgroup）。可选项。

- subversion

SMB 协议版本号。可选项。默认为 3。因安全原因，已不再支持配置 SMB1。

- path

本地挂载点。可选项。默认为`/mnt/pve/<STORAGE_ID>/`。


配置示例（`/etc/pve/storage.cfg`）

```
cifs: backup
         path /mnt/pve/backup
         server 10.0.0.11
         share VMData
         content backup
         username anna
         smbversion 3
```

## 7.7.2 存储功能


CIFS 本身不支持快照功能，但可利用 qcow2 文件格式的支持实现虚拟机快照和链接克隆。


表 7.5 cifs 后端存储功能

|数据类型 |镜像格式 |支持共享| 支持快照 |支持链接克隆|
|-----|-----|-----|----|-----|
|虚拟机镜像 容器镜像 容器模板 iso镜像 虚拟机备份 snipptes|raw qcow2 vmdk subvol|是|qcow2|qcow2|


## 7.7.3 示例

可用如下命令列出 CIFS 共享：

 ```
 pvesm cifsscan <server> [--username <username>] [--password]
 ```

然后可用如下命令将 CIFS 存储添加到 Proxmox VE 集群：

```
pvesm add cifs <storagename> --server <server> --share <share>
[--username <username>] [--password]
```
