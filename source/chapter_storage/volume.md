# 7.3 存储卷

我们专门设计了一套存储空间命名规范。当你从存储池中分配了一块存储空间时，Proxmox VE 将返回一个存储卷标示符。存储卷标示符由多个部分组成，开头是存储服务标识`<STORAGE_ID>`，其后是冒号，最后是基于存储数据类型命名的卷名称。如下是一些合法卷标识符`<VOMUME_ID>`的示例：

```
local:230/example-image.raw
local:iso/debian-501-amd64-netinst.iso
local:vztmpl/debian-5.0-joomla_1.5.9-1_i386.tar.gz
iscsi-storage:0.0.2.scsi-14 f504e46494c4500494b5042546d2d646744372d31616d61
```
可用如下命令获`取<VOLUME_ID>`对应的文件系统路径：
```
pvesm path <VOLUME_ID>
```

## 7.3.1 存储卷从属关系
每个 image 类型的存储卷都有一个属主。每个iamge 类型的存储卷，都属于一个虚拟机或容器。例如存储卷 local:230/example-image.raw 由 230 号虚拟机拥有。

大部分后端存储都会把这种从属关系用于编码生成存储卷名称。当你删除虚拟机或容器时，Proxmox VE 会同时删除其拥有的全部存储卷。





