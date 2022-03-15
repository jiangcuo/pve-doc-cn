# 7.6. 基于 NFS 的后端存储

存储池类型：NFS

基于 NFS 的后端存储服务实际上建立在目录后端存储之上，其属性和目录后端存储非常相似。其中子目录布局和文件命名规范完全一致。NFS 后端存储的优势在于，你可以通过配置NFS 服务器参数，实现 NFS 存储服务自动挂载，而无需编辑修改/etc/fstab 文件。

NFS 存储服务能够自动检测 NFS 服务器的在线状态，并自动连接 NFS 服务器输出的共享存储服务。

## 7.6.1 配置方法

NFS 后端存储支持全部的公共存储服务属性，但 shared 标识例外，因为 NFS 后端存储的shared 属性值总是设置为启用状态。此外，NFS 后端存储还具有以下属性，以便于配置 NFS服务器：

- server
  
设置 NFS 服务器的 IP 地址或 DNS 域名。建议直接配置为 IP 地址，以避免 DNS 查询带来的额外延迟——除非你的 DNS 服务器非常强大，或者以本地/etc/hosts 文件方式解析 DNS 域名.

- export
  
设置 NFS 服务器输出的共享存储路径（可用 pvesm nfsscan 命令扫描查看）。

此外，你还可以通过如下属性设置 NFS 存储挂载点：

- path

NFS 后端存储在 Proxmox VE 服务器上的挂载点(默认为/mnt/pve/<STORAGE_ID>/ )。

- options

NFS 挂载选项（可查看 man nfs 获取更多信息）。


配置示例（/etc/pve/storage.cfg）

```
nfs: iso-templates
         path /mnt/pve/iso-templates
         server 10.0.0.10
         export /space/iso-templates
         options vers=3,soft
         content iso,vztmp
```
在 NFS 连接请求超时后，NFS 默认会持续尝试建立连接。这有可能导致 NFS 客户端一侧的意外死机。对于保存只读数据的 NFS 存储，可以考虑使用 soft 选项，以限制尝试连接次数为 3。


## 7.6.2 存储功能

NFS 本身不支持快照功能，但可利用 qcow2 文件格式的支持进行虚拟机快照和链接克隆。

表 7.4 NFS 后端存储功能

|数据类型 |镜像格式 |支持共享| 支持快照 |支持链接克隆|
|-----|-----|-----|----|-----|
|虚拟机镜像 容器镜像 容器模板 iso镜像 虚拟机备份 snipptes|raw qcow2 vmdk subvol|是|qcow2|qcow2|

## 7.6.3 示例

可用如下命令列出 NFS 共享路径：
```
pvesm nfsscan <server>
```
