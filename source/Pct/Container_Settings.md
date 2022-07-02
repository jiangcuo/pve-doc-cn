# 11.4. 容器设置

## 11.4.1 通用设置

容器通用设置项如下：

- Node：容器所处的物理服务器

- CT ID：Proxmox VE用于标识容器的唯一序号。

- Hostname：容器的主机名。

- Resource Pool：逻辑上划分的一组容器和虚拟机。

- Password：容器的root口令。

- SSH Public Key：用于SSH连接登录root用户的公钥。

- Unprivileged container：该项目用于在容器创建阶段设置创建特权容器或非特权容器。

### 非特权容器

非特权容器采用了名为用户命名空间usernamespaces的内核新特性。容器内UID为0的root用户被影射至外部的一个非特权用户。也就是说，在非特权容器中常见的安全问题（容器逃逸，资源滥用等）最终只能影响到外部的一个随机的非特权用户，并最终归结为一个一般的内核安全缺陷，而非LXC容器安全性问题。LXC工作组认为非特权容器的设计是安全的。

注意： 如果容器使用 systemd 作为 init 系统，请注意，在容器内运行的 systemd 版本应等于或大于 220。


### 特权容器

容器中的安全性是通过使用强制访问控制（AppArmor）、seccomp 筛选器和 Linux 内核namespace来实现的。LXC团队认为特权容器技术是不安全的，并且不打算为新发现的容器逃逸漏洞申报CVE编号和发布快速修复补丁。。这就是为什么特权容器应仅在受信任的环境中使用的原因。

## 11.4.2 CPU

你可以通过cores参数项设置容器内可见的CPU数量。

该参数项基于Linux的cpuset cgroup（控制group）实现。

在pvestatd服务内有一个任务专门用于在CPU之间平衡容器工作负载。你可以用如下命令查看CPU分配情况：

```
pct cpusets
---------------------
102: 6 7
105: 2 3 4 5
108: 0 1
---------------------
```

容器能够直接调用主机内核，所以容器内的所有任务进程都由主机的CPU调度器直接管理。Proxmox VE默认使用Linux CFS（完全公平调度器），并提供以下参数项可以进一步控制CPU分配。

- cpulimit：	
  
  你可以设置该参数项进一步控制分配的CPU时间片。需要注意，该参数项类型为浮点数，因此你可以完美地实现这样的配置效果，即给容器分配2个CPU核心，同时限制容器总的CPU占用为0.5个CPU核心。具体如下：

    ```
    cores: 2
    cpulimit: 0.5
    ```

- cpuunits：	

  该参数项是传递给内核调度器的一个相对权重值。参数值越大，容器得到的CPU时间越多。
  
  具体得到的CPU时间片由当前容器权重占全部容器权重总和的比重决定。该参数默认值为1024，可以调大该参数以提高容器的优先权。

## 11.4.3 内存

容器内存由cgroup内存控制器管理。

- memory：容器的内存总占用量上限。对应于cgroup的memory.limit_in_bytes参数项。

- swap：	用于设置允许容器使用主机swap空间的大小。对应于cgroup的memory.memsw.limit_in_bytes参数项，cgroup的参数实际上是内存和交换分区容量之和（memory+swap）。

## 11.4.4 挂载点

容器的根挂载点通过rootfs属性配置。除此之外，你还可以再配置256个挂载点，分别对应于参数mp0到mp255。具体设置项目如下：

- rootfs:` [volume=]<volume> [,acl=<1|0>] [,mountoptions=<opt[;opt...]>] [,quota=<1|0>] [,replicate=<1|0>] [,ro=<1|0>] [,shared=<1|0>] [,size=<DiskSize>]`

  配置容器根文件系统存储卷。全部配置参数见后续内容。

- mp[n]:` [volume=]<volume> ,mp=<Path> [,acl=<1|0>] [,backup=<1|0>] [,mountoptions=<opt[;opt...]>] [,quota=<1|0>] [,replicate=<1|0>] [,ro=<1|0>] [,shared=<1|0>] [,size=<DiskSize>]`
  
  配置容器附加挂载点存储卷。使用STORAGE_ID:SIZE_IN_GiB语法分配新的存储卷。

  - acl=`<boolean>`
    
    启用/禁用acl。
  
  - backup=`<boolean>`
    
    用于配置在备份容器时是否将挂载点纳入备份范围。（仅限于附加挂载点）

  - `[,mountoptions=<opt[;opt...]>]`
    
    rootfs/mps挂载点的附加参数

  - mp=`<Path>`
    
    存储卷在容器内部的挂载点路径。

    - 注意: 出于安全性考虑，禁止含有文件链接。

  - quota=`<boolean>`
    
    在容器内启用用户空间配额（对基于zfs子卷的存储卷无效）。

  - replicate=`<boolean> `(default = 1)
  
    卷是否被可以被调度任务复制。

  - ro=`<boolean>`

    用于标识只读挂载点。

  - shared=`<boolean> `(default = 0)

    用于标识当前存储卷挂载点对所有节点可见。
    
    - 警告：设置该参数不等于自动共享挂载点，而仅仅表示当前挂载点被假定已经共享。

  - size=`<DiskSize>`
  
    存储卷容量（参数值只读）。

  - volume=`<volume>`

    存储卷命令，即挂载到容器的设备或文件系统路径。

目前主要有3类不同的挂载：基于存储服务的挂载，绑定挂载，设备挂载。

### 容器rootfs典型配置示例

```
rootfs: thin1:base-100-disk-1,size=8G
```

### 基于存储服务的挂载

基于存储服务的挂载由Proxmox VE的存储子系统管理，一共有3种不同方式：

- 硬盘镜像：也就是内建了ext4文件系统的硬盘镜像。

- ZFS存储卷：技术上类似于绑定挂载，但通过Proxmox VE存储子系统管理，并且支持容量扩充和快照功能。

- 目录：可以设置size=0禁止创建硬盘镜像，直接创建目录存储。

注意：可以STORAGE_ID:SIZE_IN_GB的形式在指定存储上创建指定大小的卷。例如，执行
  
```
pct set 100 –mp0 thin1:10,mp=/path/in/container
```
  
将在存储thin1上创建10GB大小的卷，并将卷ID替换为分配卷ID，同时在容器内的`=/path/in/container`创建挂载点。

### 绑定挂载

绑定挂载可以将Proxmox VE主机上的任意目录挂载到容器使用。可行的使用方法有：

- 在容器中访问主机目录

- 在容器中访问主机挂载的USB设备

- 在容器中访问主机挂载的NFS存储

绑定挂载并不由Proxmox VE存储子系统管理，因此你不能创建快照或在容器内启用配额管理。在非特权容器内，你可能会因为用户映射关系和不能配置ACL而遇到权限问题。

- 注意:
  
  vzdump将不会备份绑定挂载设备上的数据。

- 警告:
  
  出于安全性考虑，最好为绑定挂载创建专门的源目录路径，例如在/mnt/bindmounts下创建的目录。永远不要将/，/var或/etc等系统目录直接绑定挂载给容器使用，否则将可能带来极大的安全风险。

- 注意:
  
  绑定挂载的源路径必须没有任何链接文件。

例如，要将主机目录/mnt/bindmounts/shared挂载到ID为100的容器中的/shared下，可在配置文件/etc/pve/lxc/100.conf中增加一行配置信息p0:/mnt/bindmounts/shared, mp=/shared。或者运行命令pct set 100 -mp0 /mnt/bindmounts/shared,mp=/shared也可以达到同样效果。

### 设备挂载

设备挂载可以将Proxmox VE上的块存储设备直接挂载到容器中使用。和绑定挂载类似，设备挂载也不由Proxmox VE存储子系统管理，但用户仍然可以配置使用quota和acl等功能。

- 注意:

  设备挂载仅在非常特殊的场景下才值得使用，大部分情况下，基于存储服务的挂载能提供和设备挂载几乎一样的功能和性能，同时还提供更多的功能特性。

- 注意:

  vzdump将不会备份设备挂载上的数据。

## 11.4.5 网络

单个容器最多支持配置10个虚拟网卡设备，其名称分别为net0到net9，并支持以下配置参数项：

- net[n]: `name=<string> [,bridge=<bridge>] [,firewall=<1|0>] [,gw=<GatewayIPv4>] [,gw6=<GatewayIPv6>] [,hwaddr=<XX:XX:XX:XX:XX:XX>][,ip=<(IPv4/CIDR|dhcp|manual)>] [,ip6=<(IPv6/CIDR|auto|dhcp|manual)>] [,mtu=<integer>] [,rate=<mbps>] [,tag=<integer>] [,trunks=<vlanid;vlanid...]>] [,type=<veth>]`

  为容器配置虚拟网卡设备。

	- bridge=`<bridge>`
	  
    虚拟网卡设备连接的虚拟交换机。

	- firewall=`<boolean>`
	
    设置是否在虚拟网卡上启用防火墙策略。
	
  - gw=`<GatewayIPv4>`
	
    IPv4通信协议的默认网关。
	
  - gw6=`<GatewayIPv6>`
	
    IPv6通信协议的默认网关。
	
  - hwaddr=`<XX:XX:XX:XX:XX:XX>`
	
    虚拟网卡的MAC地址。
	
  - ip=`<(IPv4/CIDR|dhcp|manual)>`
	
    IPv4地址，以CIDR格式表示。	
	
  - ip6=`<(IPv6/CIDR|auto|dhcp|manual)>`
	
    IPv6地址，以CIDR格式表示。	
	
  - mtu=`<integer>` (64 -N)
	
    虚拟网卡的最大传输单元。（lxc.network.mtu）
	
  - name=`<string>`
  
    容器内可见的虚拟网卡名称。（lxc.network.name）

  - rate=`<mbps>`

    虚拟网卡的最大传输速度。
	
  - tag=`<integer> `(1 -4094)
	  
    虚拟网卡的VLAN标签。
	
  - trunks=`<vlanid[;vlanid...]>`
	
    虚拟网卡允许通过的VLAN号。
	
  - type=`<veth>`
	
    虚拟网卡类型。

## 11.4.6容器的自启动和自关闭

创建容器后，你也许会希望容器能够随主机自行启动。为此，你可以在Web界面的容器Options选项卡上选择Start at boot，或用如下命令设置：

```
pct set <ctid> -onboot 1
```

启动和关闭顺序


如果要精细调整容器的启动顺序，可以使用以下参数：

- Start/Shutdown order：
  
  用于设置启动优先级。例如，设为1表示你希望容器第1个被启动。（我们采用了和启动顺序相反的关闭顺序，所以Start order设置为1的容器将最后被关闭）

- Startup delay：

  用于设置当前容器启动和继续启动下一个容器之间的时间间隔。例如，设置为240表示你希望当前容器启动240秒后再继续启动下一个容器。

- Shutdown timeout：
  用于设置发出关闭命令后Proxmox VE等待容器执行关闭操作的时间，单位为秒。该参数默认值为60，也就是说Proxmox VE在发出关闭容器命令后，会等待60秒钟，如果容器不能在60秒内完成关机离线操作，Proxmox VE将通知用户容器关闭操作失败。

请注意，未设置Start/Shutdown order参数的容器将始终在设置了这些参数的容器之后启动。并且这些参数仅能影响同一Proxmox VE主机上的容器启动顺序，其作用范围局限在单一服务器内部，而不是整个集群。


