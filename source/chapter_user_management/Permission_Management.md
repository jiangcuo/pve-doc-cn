# 14.7 权限管理

用户进行任何操作前（例如查看、修改、删除虚拟机配置），都必须被赋予合适的权限。

Proxmox VE采用了基于角色和对象路径的权限管理系统。权限管理表中的一个条目记录了用户、组和令牌在访问某个对象或路径时所拥有的角色。也就是说，每条访问策略都可以用（路径，用户，角色）、（路径，组，角色）三元组来表示，其中角色包含了允许进行的操作，路径标明了操作的对象。

## 14.7.1. 角色

角色实际上是一个权限列表。Proxmox VE预定义了多个角色，能够满足大部分的管理需要。


- Administrator：拥有所有权限
- NoAccess：没有任何权限（用于禁止访问）
- PVEAdmin：有权进行大部分操作，但无权修改系统设置（Sys.PowerMgmt，Sys.Modify，Realm.Allocate）。
- PVEAuditor：只有只读权限。
- PVEDatastoreAdmin：创建和分配备份空间和模板。
- PVEDatastoreUser：分配备份空间，查看存储服务。
- PVEPoolAdmin: 分配资源池。
- PVESysAdmin: 分配用户访问权限，审计，访问系统控制台和系统日志。
- PVETemplateUser: 查看和克隆模板。
- PVEUserAdmin: 用户管理。
- PVEVMAdmin: 管理虚拟机。
- PVEVMUser: 查看，备份，配置CDROM，访问虚拟机控制台，虚拟机电源管理。

在WebGUI可以查看系统预定义的所有角色。

新增角色可以通过GUI或命令行进行。

![img](./gui-datacenter-role-add.png#pic_center)

使用GUI方式时，依次打开数据中心的权限→角色选项卡，然后点击创建按钮，之后可以设置角色名并在权限下拉框中选择所需权限。

使用命令行方式添加角色时，可以使用pveum命令行工具，如下：

```
pveum roleadd PVE_Power-only -privs "VM.PowerMgmt VM.Console"
pveum roleadd Sys_Power-only -privs "Sys.PowerMgmt Sys.Console"
```


## 14.7.2. 权限

权限是指进行某种操作的权力。为简化管理，一组权限可以被编组构成一个角色，角色可以用于制定权限管理表的条目。注意，权限不能被直接赋予用户和对象路径，而必须借助角色才可以。

目前有如下权限：


节点/系统相关的权限

- Permissions.Modify：修改访问权限
- Sys.PowerMgmt：管理节点电源（启动，停止，重启，关机）
- Sys.Console：访问节点控制台
- Sys.Syslog：查看syslog
- Sys.Audit：查看节点状态/配置
- Sys.Modify：创建/删除/修改节点网络配置参数
- Group.Allocate：创建/删除/修改组
- Pool.Allocate：创建/删除/修改资源池
- Pool.Audit: 查看资源池
- Realm.Allocate：创建/删除/修改认证域
- Realm.AllocateUser：将用户分配到认证域
- User.Modify：创建/删除/修改用户访问权限和详细信息

虚拟机相关的权限

- VM.Allocate：创建/删除虚拟机
- VM.Migrate：迁移虚拟机到其他节点
- VM.PowerMgmt：电源管理（启动，停止，重启，关机）
- VM.Console：访问虚拟机控制台
- VM.Monitor：访问虚拟机监视器（kvm）
- VM.Backup：备份/恢复虚拟机
- VM.Audit：查看虚拟机配置
- VM.Clone：克窿/复制虚拟机
- VM.Config.Disk：添加/修改/删除虚拟硬盘
- VM.Config.CDROM：弹出/更换CDROM
- VM.Config.CPU：修改CPU配置
- VM.Config.Memory：修改内存配置
- VM.Config.Network：添加/修改/删除虚拟网卡
- VM.Config.HWType：修改模拟硬件类型
- VM.Config.Options：修改虚拟机的其他配置
- VM.Snapshot：创建/删除虚拟机快照

存储相关的权限

- Datastore.Allocate：创建/删除/修改存储服务，删除存储卷
- Datastore.AllocateSpace：在存储服务上分配空间
- Datastore.AllocateTemplate：分配/上传模板和iso镜像
- Datastore.Audit：查看/浏览存储服务

## 14.7.3. 对象和路径

访问权限是针对对象而分配的，例如虚拟机，存储服务或资源池。我们采用了类似文件系统路径的方式来标识这些对象。所有的路径构成树状结构，用户可以选择将高层对象获得的权限（短路径）扩展到下层的对象
。
路径是可模板化的。当API调用申请访问一个模板化路径时，路径中可以包含API调用的参数。其中API参数需要用花括号括起来。某些参数会被隐式地从API调用的URI中获取。例如在调用/nodes/mynode/status时，路径/nodes/{node}实际上申请了/nodes/mynode的访问权限。而在对路径/access/acl的PUT请求中，{path}实际上引用了该方法的path参数。

一些示例如下：

- /nodes/{node}：访问Proxmox VE服务器
- /vms：所有的虚拟机
- /vms/{vmid}：访问指定虚拟机
- /storage/{storeid}：访问指定存储服务
- /pool/{poolname}：访问指定存储池中虚拟机
- /access/groups：组管理操作
- /access/realms/{realmid}：管理指定认证域

**权限继承**

如前所述，对象路径全体构成了类似文件系统的树状结构，而权限能够自上而下地继承下去（继承标识默认是启用的）。我们采用了以下的继承策略：

- 针对单一用户的权限将覆盖针对组的权限。
- 针对组赋权后，组内所有用户自动获得赋限。
- 明确的赋权会覆盖从高层继承来的赋权。

此外，当一个用户不拥有某个路径的权限时，其特权分离的令牌也不会拥有此路径的权限。

## 14.7.4. 资源池

资源池主要用来将虚拟机和存储服务组织起来，并形成一个组。当对资源池赋予访问权限后（/pool/{poolid}），其中所有成员都会继承该权限，从而大大简化访问控制配置工作。


## 14.7.5 我究竟需要哪些权限？
在http://pve.proxmox.com/pve-docs/api-viewer/记录了每一个方法所需的API调用权限。

所需的权限以列表形式表示，可以看作一个由访问权限检查函数构成的逻辑树。

**`["and", <subtests>...] and ["or", <subtests>...]`**

当前列表中的所有（and）或任意一个（or）权限需要被满足。

`["perm", <path>, [ <privileges>...], <options>...]`

该路径是一个模板参数（查看对象和路径一节）。访问目标路径时，列表中所有的（或任意一个，如果使用了any选项）权限需要被满足。如果指定了require-param选项，则需要满足指定的参数权限，除非API调用时标明该参数为可选的。

`["userid-group", [ <privileges>...], <options>...]`

调用方需要拥有/access/groups所列出的任意权限。此外，根据是否设置groups_param参数，还需要额外进行两个权限检查：

- 设置了groups_param：API调用使用了不可选的组参数，调用方必须对参数引用的所有组拥有该组所列出的任意权限。
- 未设置groups_param：通过userid参数传递的用户必须存在，并且是组的成员，而调用方拥有所列出的任意权限（通过`/access/groups/<group>`路径）。

`["userid-param", "self"]`

向API传递的userid参数值必须和申请进行操作的用户一致。（通常和or联合使用，以允许用户在没有权限的情况下在自身执行操作。）

`["userid-param", "Realm.AllocateUser"]`

用户需要对/access/realm/<realm>,拥有Realm.AllocateUser访问权。其中<realm>是用户通过userid参数传递的认证域。注意，用户不一定需要真的存在，因为用户ID是以<username>@<realm>形式传递的。
`
["perm-modify", <path>]`

其中path是一个模板化参数（参见对象和路径一节）。用户需要拥有Permissions.Modify权限，或根据以下不同路径拥有相应权限：

- /storage/...：需要额外拥有权限’Datastore.Allocate`
- /vms/...：需要额外拥有权限’VM.Allocate`
- /pool/...：需要额外拥有权限’Pool.Allocate`

如果路径为空，需要对/access拥有Permission.Modify权限。


