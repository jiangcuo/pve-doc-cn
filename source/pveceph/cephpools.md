# 8.6 Ceph Pool

存储池pool是一组存储对象的逻辑集合。具体是由一组Placement Groups（PG，pg_num）的对象集合组成。

## 8.6.1 创建Ceph Pool

https://10.13.14.4:8006/pve-docs/images/screenshot/gui-ceph-pools.png

可以在GUI主机管理界面选择Ceph→Pools或直接用命令行创建pool。当不使用任何选项时，默认将创建128个PG，并使用3副本模式，降级模式最低使用2副本模式。

** 注意 **
 - 不要将 min_size 设置为 1。min_size 为 1 的复制池允许在对象只有 1 个副本时进行 I/O，这可能导致数据丢失、不完整的 PG 或未找到的对象。


建议根据你的具体配置计算确定PG数量。互联网上可以找到PG数量计算公式或PG数量计算器[ PG计算机详见http://ceph.com/pgcalc/]。不过从 Ceph Nautilus 开始，允许在部署之后更改 PG 的数量。

PG-Autoscaler可以在后台自动缩放池的PG数量，设置 Target Size或Target Ratio高级参数有助于PG-Autoscaler自动设置最优值。

### 通过命令行创建Pool示例

```
pveceph pool create <name> --add_storages
```

如果想自动将ceph pool添加到Proxmox VE存储，请保持`--add_storages`参数。或者在GUI上勾选`添加存储`。

### Pool 选项
 
下面选项在创建Pool时可用，有些也可以在编辑池时可用。

- 名称
  
   池的名称，这是唯一的，且之后无法更改

- 大小

   每个对象的副本数，Ceph根据这个值调整副本的数量。默认值为3

- PG Autoscale Mode

  PG自动缩放模式。如果设置为warn，它会在池具有非最佳 PG 计数时产生警告消息。默认值：警告。

- 添加存储

  自动将Ceph Pool添加为Proxmox VE存储


### 高级选项

- 最小尺寸

  每个对象的最小副本数。如果PG的副本数少于此数量，Ceph 将拒绝池上的 I/O请求。默认为2

- Crush Rules
  
  

of PGs

Target Ratio

Target Size

Min. # of PGs

