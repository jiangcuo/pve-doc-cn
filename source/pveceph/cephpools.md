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
  
  用于在集群中映射对象放置的规则。这些规则定义了数据在集群中的放置方式。有关基于设备的规则的信息，请参阅 Ceph CRUSH 和设备类。
  

- of PGs
  
  池在创建时的pg数量

- Target Ratio

  池中预期的数据比率。PG 自动缩放器使用相对于其他比率集的比率。如果两者都设置 ，它优先于`Target Size`

- Target Size

  池中预期的估计数据量。PG 自动缩放器使用此大小来估计最佳 PG 计数。

- Min. # of PGs

  PG的最小数量，此设置用于微调该池的 PG 计数的下限。 PG Autoscale不会合并低于此阈值的 PG。


## 8.6.2. 销毁池

要通过 GUI 销毁池，请在树视图中选择一个节点，然后转到 Ceph → Pools面板。选择要销毁的池，然后单击Destroy 按钮。要确认池的销毁，您需要输入池名称。

运行以下命令以销毁池。指定-remove_storages以同时删除关联的存储。

```
pveceph pool destroy <name>
```

- 注意
   
   - 删除pool的数据是一项后台任务，可能需要一些时间。您将注意到集群中的数据使用率正在减少。

## 8.6.3. PG Autoscale

PG Autoscale 允许集群预估存储在每个池中的数据量，并自动选择适当的 pg_num 值。它从 Ceph Nautilus 开始可用。

需要激活 PG Autoscale Mode才能使调整生效。

```
ceph mgr module enable pg_autoscaler
```

自动缩放模式基于每个池进行配置，并具有以下选项

- warn 
  - 如果建议的pg_num值与当前值相差太大， 则会发出健康警告

- on
  - pg_num会自动调整，无需干预

- off
  - 不会自动调整pg_num， 即使当前的pg_num值不是最优值，也不会发出警告。

可以使用`target_size`、`target_size_ratio`和`pg_num_min`选项调整缩放因子以优化未来的数据存储。

- 注意
  -  默认情况下，如果池的 PG 数量偏离 3 倍，自动所放弃会考虑调整它。这将导致数据放置发生相当大的变化，并可能在集群上引入高负载。


您可以在Ceph-blog [New in Nautilus: PG merging and autotuning](https://ceph.io/rados/new-in-nautilus-pg-merging-and-autotuning/)中找到对 PG 自动缩放器的更深入介绍 。
