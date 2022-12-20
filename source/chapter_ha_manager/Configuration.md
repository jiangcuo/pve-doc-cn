# 15.6. 配置

HA组件被紧密集成到了Proxmox VE API中。因此，你既能够通过ha-manager命令行配置HA，也可以通过WebGUI配置HA，两种方式都很简便，更进一步，还可以用自动化工具直接调用API配置HA。

HA配置文件全部保存在`/etc/pve/ha/`目录中，因此可以被自动复制到集群所有节点，所有节点都共享使用相同的HA配置。

## 15.6.1. 资源

资源配置文件/etc/pve/ha/resources.cfg保存了ha-manager管理的所有资源列表。资源列表中的资源配置格式如下：
```
<type>: <name>
<property> <value>
...
```
每条资源配置信息都以冒号分隔的资源类型和资源名称开始，这也是ha-manager命令用于标识HA资源的ID（例如vm:100或ct:101），而后续配置行包含了附加属性：

- `comment: <string>`
  
  描述信息。
- `group: <string>`
  
  HA组标识符。

- `max_relocate: <integer> (0 -N) (default = 1)`
  
  资源启动失败后尝试重新部署最大次数。
- `max_restart: <integer> (0 -N) (default = 1)`
  
  资源启动失败后尝试重新启动最大次数。
- `state: <disabled | enabled | ignored | started | stopped> (default =started)`

  资源的指定状态。CRM将根据该状态值管理相关资源。请注意enabled是started的别名。
  
  - started

    CRM将尝试启动资源，并在成功启动后将状态设置为started。如果遭遇节点故障或启动失败，CRM将尝试恢复资源。如果所有尝试均告失败，状态将被设为error。
  
  - stopped
    
    CRM将努力确保资源处于停止状态。但在遭遇节点时，CRM还是会尝试将资源重新部署到其他节点。

  - disabled

    CRM将努力确保资源处于停止状态。但在遭遇节点时，CRM不会将资源重新部署到其他节点。设置该状态的主要目的是将资源从error状态恢复出来，因为这是error状态的资源唯一可以被设置的状态。
  - ignored
    
    该状态表示资源不再接受HA管理，CRM和LRM也不再管理相关资源。所有Proxmox将努VE API将绕过HA组件，直接对相关资源进行操作。对该资源执行的CRM命令将直接返回，而不做任何操作。同时，在节点发生故障时，资源也不会被自动故障转移。

以下是一个实际生产中的例子，其中包含了一个虚拟机和一个容器。可以看到，配置文件的语法其实非常简单，所以你可以用文本编辑器直接读取或修改这些配置文件：

**配置示例（/etc/pve/ha/resources.cfg）**

```
vm: 501
    state started
    max_relocate 2

ct: 102
    # Note: use default settings for everything
```

以上配置示例是由命令行工具ha-manager生成的：

```
ha-manager add vm:501 --state started --max_relocate 2
ha-manager add ct:102
```

## 15.6.2. 组

HA的组配置文件/etc/pve/ha/groups.cfg用于定义集群节点服务器组。一个资源可以被指定只能在一个组内的节点上运行。组配置示例如下：
```
group: <group>
	nodes <node_list>
	<property> <value>
	...
```
- `comment: <string>`
  
  描述信息。

- `nodes: <node>[:<pri>]{,<node>[:<pri>]}*`

  节点组成员列表，其中每个节点都可以被赋予一个优先级。绑定在一个组上的资源会优先选择在最高优先级的节点上运行。如果有多个节点都被赋予最高优先级，资源将会被平均分配到这些节点上运行。优先级的值只有相对大小意义。

- `nofailback: <boolean> (default = 0)`
  
  CRM会尝试在最高优先级的节点运行资源。当有更高优先级的节点上线后，CRM将把资源迁移到更高优先级节点。设置nofailback后，CRM将继续保持资源在原节点运行。

- `restricted: <boolean> (default = 0)`
  
  绑定到restricted组的资源将只能够在该组的节点运行。如果该组的节点全部关机，则相关资源将停止运行。而对于非restricted组而言，如果该组的节点全部关机，相关资源可以转移到集群内的任何节点运行，一旦该组节点重新上线，相关资源会立刻迁移回到该组节点上运行。可以通过设置只有一个成员的非restricted组实现更好表现。


指定资源在固定节点运行是很常见的做法，但通常也会允许资源在其他节点运行。为此，你可以设置一个只有一个节点的非restricted组：

```
ha-manager groupadd prefer_node1 --nodes node1
```

对于节点较多的集群而言，可以考虑制定更加详尽的故障转移策略。例如，你可以指定一组资源固定在node1节点运行。一旦node1节点不可用，你可以将相关资源平均分配到node2和node3节点运行。如果node2和node3也遭遇故障，则可以进一步转移到node4运行。为达到该效果，你可以设置节点列表如下：

```
ha-manager groupadd mygroup1 -nodes "node1:2,node2:1,node3:1,node4"
```

另一个例子是，如果某个资源需要用到只有特定节点，比如node1和node2，才具有的硬件或其他资源。我们就需要确保HA管理器不在其他节点运行该资源。为此，我们需要创建一个由指定节点构成的restricted组：
```
ha-manager groupadd mygroup2 -nodes "node1,node2" -restricted
```

以上命令创建的配置文件如下：

**配置文件示例（/etc/pve/ha/groups.cfg）**

```
group: prefer_node1
	nodes node1
group: mygroup1
	nodes node2:1,node4,node1:2,node3:1
group: mygroup2
	nodes node2,node1
	restricted 1
```

选项nofailback主要用于在管理操作中避免意外的资源迁移。例如，如果你需要将一个资源迁移到一个优先级较低的节点运行，就需要设置nofailback选项来告诉HA管理器不要立刻把资源迁移回原来的高优先级节点。

另一种可能场景是，在节点因故障被隔离后，相关资源会自动迁移到其他节点运行，而管理员在把故障节点重新恢复加入集群后，可能会希望先查明故障原因并检测该节点是否能稳定运行。这时可以设置nofailback选项组织HA管理器立刻把相关资源迁移故障节点运行。


