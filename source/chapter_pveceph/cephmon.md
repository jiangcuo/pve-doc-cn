# 8.3. Ceph 监视器

Ceph Monitor（MON）[ Ceph Monitor详见http://docs.ceph.com/docs/luminous/start/intro/]负责管理集群全局数据。如需要实现HA，则至少需要创建3个Monitor。

安装向导会自动创建一个monitor。对中小规模集群而言，最多3个monitor就够了，只有大型集群才需要更多的monitor。

## 8.3.1 创建监视器

可以在你想要部署monitor的节点上（建议创建3个monitor），可以在GUI界面依次选择Ceph→Monitor选项完成monitor创建，也可以运行如下命令。

`pveceph mon create`

## 销毁监视器

要通过 GUI 删除 Ceph 监视器，首先在树视图中选择一个节点，然后转到Ceph → 监视器面板。选择 MON 并单击Destroy 按钮。

要通过 CLI 删除 Ceph Monitor，首先连接到运行 MON 的节点。然后执行以下命令：

`pveceph mon destroy`

提示: quroum至少需要3个监视器

