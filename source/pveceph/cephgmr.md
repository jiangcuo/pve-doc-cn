# 8.4. Ceph 管理器

Manager 守护程序与监视器一起运行。它提供了一个监控集群的接口。自Ceph luminous发布以来，至少需要一个ceph-mgr [ 15 ]守护进程。

## 创建Ceph Manager
可以安装多个 Manager，但在任何给定时间只有一个 Manager 处于活动状态。

`pveceph mgr create`

提示：建议将Ceph Manager部署在monitor节点上。并考虑安装多个Cepn Manager，以满足高可用要求。

## 8.6.2销毁Ceph Manager

要通过 GUI 删除 Ceph 管理器，首先在树视图中选择一个节点，然后转到Ceph → Monitor面板。选择 Manager 并单击 Destroy按钮。

要通过 CLI 删除 Ceph Monitor，首先连接到运行 Manager 的节点。然后执行以下命令：

`pveceph mgr destroy`

提示：Cepn集群可以在没有管理器的情况下运行，但它对于 Ceph 集群至关重要，因为它处理 PG 自动缩放、设备健康监控、遥测等重要功能。

