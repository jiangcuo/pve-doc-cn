# 15.3管理任务
本节将简单介绍常见管理任务。首先是在资源上激活HA，也就是把资源添加到HA的资源配置中，可以通过WebGUI进行，也可以使用命令行工具完成该操作，如下：

```
ha-manager add vm:100
```

之后，HA组件将启动该资源并全力确保它连续运行。当然，你也可以配置该资源的“指定”工作状态，例如可以要求HA组件停止该资源的运行：

```
 ha-manager set vm:100 --state stopped
 ```
然后再启动运行

```
ha-manager set vm:100 --state started
```
你也可以使用常用的虚拟机和容器管理工具来改变资源运行状态，而常用工具会自动调用HA组件完成操作指令。因此

```
qm start 100
```
将资源状态设置为started。命令qm stop的原理类似，只是将资源状态设置为stopped。

- 注意
  
  HA组件以异步方式工作，并需要和集群其他成员进行通讯，因此从发出指令到观察到操作完成需要一些时间。

可以用如下命令查看HA的资源配置情况：

```
ha-manager config
vm:100
state stopped
```

可以用如下命令查看HA管理器和资源状态：

```
ha-manager status
quorum OK
master node1 (active, Wed Nov 23 11:07:23 2016)
lrm elsa (active, Wed Nov 23 11:07:19 2016)
service vm:100 (node1, started)
```

可以用如下命令将资源迁移到其他节点：
```
 ha-manager migrate vm:100 node2
```
上面的命令采用在线迁移方式，虚拟机在迁移过程中将保持运行。在线迁移需要通过网络将虚拟机内存数据传输到目标节点，因此在某些情况下关闭虚拟机然后在目标节点重新启动可能更快，具体可使用relocate命令进行：

```
ha-manager relocate vm:100 node2
```

最后，可用如下命令将资源从HA的资源配置中删除：

```
 ha-manager remove vm:100
```
- 注意
  
  该操作并不需要启停虚拟机。

所有的HA管理操作都可通过WebGUI进行，一般情况下无须使用命令行。