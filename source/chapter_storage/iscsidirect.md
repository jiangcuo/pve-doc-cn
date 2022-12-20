# 7.14基于用户空间iSCSI的后端存储

存储池类型：iscsidirect

用户空间iSCSI和Open-iSCSI后端存储功能相近，其主要区别在于使用用户空间库（libiscsi2）实现。

需要强调的是，iscsidirect未使用内核组件。由于省去了内核空间切换，所以其性能更加优秀，但代价是不能其创建的iSCSI LUN上配置使用LVM，你只能在存储服务器端完成iSCSI LUN的划分和管理。

## 7.14.1配置方法

用户空间iSCSI后端存储的属性和Open-iSCSI后端存储完全一致。

```
iscsidirect: faststore
portal 10.10.10.1
target iqn.2006-01.openfiler.com:tsn.dcb5aaaddd
```

## 7.14.2存储功能

提示:

用户空间iSCSI后端存储仅能用于KVM虚拟机镜像存储，不能存储容器镜像。

表 13.后端 iscsidirect 的存储功能

|数据类型 |镜像格式 |支持共享| 支持快照 |支持链接克隆|
|-----|-----|-----|----|-----|
|虚拟机镜像 容器镜像 |RAW |是|否|否|

