# 7.2 存储配置

Proxmox VE 所配置的存储配置信息全部保存在/etc/pve/storage.cfg 中。鉴于该文件在/etc/pve 目录下，该文件会自动分发到集群的所有节点，所以所有节点都使用同样的存储配置信息。

共享存储配置信息对于共享存储非常有意义，因为共享存储本身就需要被所有节点访问。但对于本地存储来说也是很有用的，特别是在所有节点都配置了同一类本地存储的时候，尽管每个节点的本地存储都是不同的物理设备，其保存的数据也完全不一样

## 7.2.1 存储池
每个存储池都有一个类型`<type>`，并唯一地被`<STORAGE_ID>`标识。 存储池的配置示例如下：

```
<type>: <STORAGE_ID>
<property> <value>
<property> <value>
...
```
其中，```<type>: <STORAGE_ID>```是存储池配的开始部分，其后是一组属性信息。大部分属性都需要配置参数值，但也有一部分使用默认值。使用默认值的情况下，可以省去`<value>`值。

以 Proxmox VE 安装后的默认存储配置文件为例，其中包含一个名为 `local `的本地存储池，其路径为本地文件系统`/var/lib/vz`，并默认处于启用状态。Proxmox VE 安装程序也会根据安装时设置的存储类型创建其他存储服务。

默认存储配置文件（/etc/pve/storage.cfg）

```
dir: local
          path /var/lib/vz
          content iso,vztmpl,backup
# default image store on LVM based installation
lvmthin: local-lvm
          thinpool data
          vgname pve
          content rootdir,images
# default image store on ZFS based installation
zfspool: local-zfs
          pool rpool/data
          sparse
          content images,rootdir
```

## 7.2.2 公共存储服务属性

在 Proxmox VE 中，有一些公共的存储服务属性，在不同类型的存储服务中有。

**nodes**

用于配置能够使用/访问当前存储服务的节点名列表。通过该属性可将存储服务配置为仅能由部分节点访问。

**content**
  
存储服务可用于保存多种不同类型的数据，例如虚拟磁盘镜像，光盘 ISO 镜像，容器模板或容器根文件系统。不是所有存储服务都可以存储所有类型的数据。可通过该属性设置存储服务所要保存的数据类型。可设置的属性值如下:

- `images` KVM-Qemu 虚拟机镜像
- `rootdir` 容器镜像数据
- `vztmpl` 容器模板
- `backup` 虚拟机备份文件
- `iso` ISO 镜像
- `snippets` Snippet 文件，例如客户机 hook 脚本

**shared**

用于标示存储服务是共享存储服务。

**disable**

设置该属性值可禁用该存储服务。

**maxfiles**

用于设置每个虚拟机备份文件最大数量。设为 0 表示不限制备份文件数量。

**format**

用于设置默认的虚拟机镜像格式（raw|qcow2|vmdk）。

**警告：**
建议不要在不同 Proxmox VE 集群之间共享同一存储服务。由于某些存储服务访问操作有排他性，需要通过锁机制来防止并发访问。一个集群内可以通过锁机制防止并发访问，但两个集群之间就没办法禁止并发访问了。

