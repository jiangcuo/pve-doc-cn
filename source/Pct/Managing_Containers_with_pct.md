# 11.9 使用pct管理容器

Proxmox VE使用pct命令管理容器。你可以用pct命令创建或销毁容器，也可以控制容器的运行（启动，关闭，迁移等）。你还可以用pct命令设置相关配置文件中的参数，例如网络配置或内存上限。

## 11.9.1命令行示例

使用Debian模板创建一个容器（假定你已经通过Web界面下载了模板）

```
pct create 100 /var/lib/vz/template/cache/debian-8.0-standard_8.0-1_amd64.tar.gz
```

启动100号容器

```
pct start 100
```

通过getty启动登录控制台

```
pct console 100
```

进入LXC命名空间并使用root用户启动一个shell

```
pct enter 100
```

显示容器配置

```
pct config 100
```

在容器运行的状态下增加名为eth0的虚拟网卡，同时设置桥接虚拟交换机vmbr0，IP地址和网关。

```
pct set 100 -net0 name=eth0,bridge=vmbr0,ip=192.168.15.147/24,gw=192.168.15.1
```

调整容器内存减少到512MB

```
pct set 100 -memory 512
```

删除容器总是会将其从访问控制列表和防火墙配置中移除，如果你想将容器从备份任务、复制或者HA资源中移除，你还需要添加选项--purge

```
 pct destroy 100 --purge
```

移动挂载点到其他的存储

```
pct move-volume 100 mp0 other-storage
```

重新分配磁盘到另外的容器。这把源容器的mp0重新配置到目标CT的mp0。在移动过程中，会将磁盘重新按照目标容器的磁盘格式命令。

```
pct move-volume 100 mp0 --target-vmid 200 --target-volume mp1
```

## 11.9.2 获取调试日志

如果`pct start`无法启动特定容器，通过添加--debug标志（将CTID替换为容器的CTID）来收集调试输出，可能会有所帮助：

```
pct start CTID --debug
```

或者，您可以使用下面`lxc-start`命苦，该命令将调试日志保存到-o输出选项指定的文件中：

```
lxc-start -n CTID -F -l DEBUG -o /tmp/lxc-CTID.log
```

该命令将尝试用前台模式启动容器，可以在另外一个控制台运行pct shutdown ID或pct stop ID停止容器。

收集到的日志信息保存在/tmp/lxc-ID.log中。

- 注意
  
  如果你在最近一次运行pct start命令尝试启动容器后修改了容器配置，在执行lxc-start命令前，你应该至少再运行一次pct start命令，以更新容器lxc-start命令可用的配置。

## 11.10 迁移

在集群环境中，你可以用如下命令迁移容器

```
pct migrate <vmid> <target>
```

该命令只对关机离线的容器有效。如果容器使用了本地存储和挂载点，而迁移目标服务器配置了同名的存储服务和资源，迁移命令将自动通过网络把相关数据复制到目标服务器。

由于技术限制，运行的容器无法实时迁移。您可以进行重启迁移，该迁移会先将容器关闭再迁移，最后在目标节点上再次启动容器。由于容器非常轻巧，这通常只会产生数百毫秒的停机时间。

重启迁移可以通过Web界面或使用带有pct迁移命令的--restart标志来完成。

重启迁移将关闭容器或者在超时后（默认为180秒）强制关闭。然后，它将像离线迁移一样迁移容器，完成后，它会在目标节点上启动。

## 11.11 容器配置文件

容器配置信息全部保存在`/etc/pve/lxc/<CTID>.conf`文件中，其中`<CTID>`是容器的数字ID。和/etc/pve目录下的所有文件一样，容器配置文件也会被自动复制到集群的所有其他节点。

- 注意
  
  小于100的CTID都被Proxmox VE内部保留使用。同一集群内不能有重复的CTID。

容器配置文件示例

```
ostype: debian
arch: amd64
hostname: www
memory: 512
swap: 512
net0: bridge=vmbr0,hwaddr=66:64:66:64:64:36,ip=dhcp,name=eth0,type=veth
rootfs: local:107/vm-107-disk-1.raw,size=7G
```

容器配置文件采用了简单的文本格式，可以用常见的编辑器（vi，nano等）编辑修改。这也是日常进行少量配置调整的常用方法，但务必注意必须重启容器才能让新的配置生效。

因此，更好的方法是使用pct命令修改配置，或通过WebGUI进行。Proxmox VE能让大部分配置变更对运行中的容器即时生效。该功能称为“热插拔”，并且无须重启容器。

如果更改无法热插拔，它将标记为待处理的更改（在GUI中以红色显示）。它们只有在重新启动容器后才会应用。

## 11.11.1 配置文件格式

容器配置文件采用了简单的冒号分隔的键/值格式。每一行的格式如下：

```
# this is a comment
OPTION: value
```

空行将被自动忽略，以#字符开头的行将被当作注释处理，也会被自动忽略。

可以在配置文件中直接添加底层LXC风格的配置，例如：

```
lxc.init_cmd: /sbin/my_own_init
```

或

```
lxc.init_cmd = /sbin/my_own_init
```

这些配置将被直接传递给底层LXC管理工具。

## 11.11.2 快照

当你创建一个快照后，pct将在原配置文件中创建一个独立小节保存快照创建时的配置。例如，创建名为“testsnapshot”的快照后，你的配置文件会类似于下面的例子：
创建快照后的配置文件示例

```
memory: 512
swap: 512
parent: testsnaphot
...
[testsnaphot]
memory: 512
swap: 512
snaptime: 1457170803
...
````
其中parent和snaptime是和快照相关的配置属性。属性parent用于保存快照之间的父/子关系。属性snaptime用于标识快照创建时间（Unix epoch）。


## 11.11.3 参数项

arch: `<amd64 | arm64 | armhf | i386>`    (default = amd64)
  
  操作系统架构类型。

cmode:` <console | shell | tty>` (default = tty)

  控制台模式。默认情况下，控制台命令尝试打开到tty设备的连接。设置cmode为console后，将尝试连接到/dev/console设备。设置cmode为shell后，将直接调用容器内的shell（no login）。

console:` <boolean>` (default = 1)
  
  挂接到容器的控制台设备（/dev/console）。

cores: `<integer> `(1 -128)
  
  分配给容器的CPU核心数量。默认容器可以使用全部的核心。

cpulimit: `<number> `(0 -128) (default = 0)

  CPU分配限额。

  - 注意
    
    如计算机有2个CPU，一共可分配的CPU时间为2。设置为0表示无限制。

cpuunits: `<integer> `(0 -500000) (default = 1024)

  分配给容器的CPU权重。该参数用于内核的公平调度器。参数值越大，容器能获得的CPU时间片越多。获得的CPU时间片具体由当前容器权重和所有其他容器权重总和的比值决定。

  - 注意
    
    可将该参数设为0以禁用公平调度器。

description:` <string>`

  容器描述信息。仅供Web界面显示使用。

features: `[fuse=<1|0>] [,keyctl=<1|0>] [,mount=<fstype;fstype;...>] [,nesting=<1|0>]`
  
  设置容器可以使用的高级特性

fuse=`<boolean>` (default = 0)
  
  在容器中启用fuse文件系统。注意，同时使用fuse和freezer cgroup可能导致I/O死锁。

   keyctl=`<boolean>` (default = 0)
   
     仅适用于非特权容器：允许调用keyctl()系统调用。主要用于在容器内运行docker。默认情况下，容器无法看到该系统调用，从而避免systemd-networkd因权限不足调用keyctl()失败而导致的致命错误。因此，是否启用该参数主要取决于你在容器内运行systemd-networkd还是docker。
   
   mount=`<fstype;fstype;...>`
    
     用于设置允许容器挂载指定文件系统。该参数指定了允许mount命令挂载的文件系统类型列表。需要注意的是，在容器内挂载其他文件系统会对危害安全性。例如，通过访问loop设备，可以在挂载文件系统时绕过设备cgroup组的mknod权限，挂载NFS文件系统有可能完全阻塞主机I/O，并导致无法重启等等。
   
   nesting=`<boolean> `(default = 0)

    设置允许容器嵌套。最好在启用ID映射的非特权容器内使用。注意，该特性会将主机的procfs和sysfs暴露给容器。

hookscript:` <string>`
  
  设置回调脚本。

hostname: `<string>`
  容器的主机名。

lock: `<backup | create | disk | fstrim | migrate | mounted | rollback | snapshot | snapshot-delete>`
  
  设置锁定/解锁容器。

memory: `<integer>` (16 -N) (default = 512)
  
  分配给容器的内存容量。

mp[n]: `[volume=]<volume> ,mp=<Path> [,acl=<1|0>] [,backup=<1|0>][,mountoptions=<opt[;opt...]>][,quota=<1|0>] [,replicate=<1|0>] [,ro=<1|0>] [,shared=<1|0>][,size=<DiskSize>]`

给容器设置附加挂载点。
  acl=`<boolean>`

	设置启用或禁用ACL。
  
  backup=`<boolean>`

	设置在备份容器时是否将挂载点纳入备份范围（仅对卷挂载点有效）。

 ` [,mountoptions=<opt[;opt...]>]`

    rootfs/mps挂载点的附加参数
  
  mp=`<Path>`
	容器内的挂载点路径。
  
    - 注意

      出于安全性考虑，禁止包含任何文件链接。

  quota=`<boolean>`
     
    启用容器内的用户配额功能（对基于ZFS子卷的挂载点无效）。
	
  replicate=`<boolean>` (default = 1)
     
    设置卷是否可以被调度任务复制。

  ro=`<boolean>`

	设置挂载点为只读。
  
  shared=`<boolean> `(default = 0)

	设置非卷挂载点为所有节点可共享。

    - 警告
    
      设置该参数不等于自动共享挂载点，而仅仅表示当前挂载点被假定已经共享。

  size=`<DiskSize>`
    
    挂载点存储卷容量（参数值只读）。
	
  volume=`<volume>`
    
    挂载到容器的卷、设备或目录。

nameserver:` <string>`
  
  设置容器所使用的DNS服务器IP地址。如未指定nameserver和searchdomain，将在创建容器时直接使用主机的相关配置。

net[n]: `name=<string> [,bridge=<bridge>] [,firewall=<1|0>] [,gw=<GatewayIPv4>] [,gw6=<GatewayIPv6>] [,hwaddr=<XX:XX:XX:XX:XX:XX>][,ip=<(IPv4/CIDR|dhcp|manual)>] [,ip6=<(IPv6/CIDR|auto|dhcp|manual)>] [,mtu=<integer>] [,rate=<mbps>] [,tag=<integer>] [,trunks=<vlanid;vlanid...]>] [,type=<veth>]`
  
  为容器配置虚拟网卡设备。
  
  bridge=`<bridge>`

	虚拟网卡设备连接的虚拟交换机。

  firewall=`<boolean>`
	
    设置是否在虚拟网卡上启用防火墙策略。
  
  gw=`<GatewayIPv4>`

	IPv4通信协议的默认网关。

  gw6=`<GatewayIPv6>`

	IPv6通信协议的默认网关。
  
  hwaddr=`<XX:XX:XX:XX:XX:XX>`

	虚拟网卡的MAC地址。

  ip=`<(IPv4/CIDR|dhcp|manual)>`

	IPv4地址，以CIDR格式表示。	
  
  ip6=`<(IPv6/CIDR|auto|dhcp|manual)>`

	IPv6地址，以CIDR格式表示。	

  mtu=`<integer> `(64 -N)

	虚拟网卡的最大传输单元。（lxc.network.mtu）

  name=`<string>`

	容器内可见的虚拟网卡名称。（lxc.network.name）

  rate=`<mbps>`

	虚拟网卡的最大传输速度。

  tag=`<integer>` (1 -4094)

	虚拟网卡的VLAN标签。
  
  trunks=`<vlanid[;vlanid...]>`
    
    虚拟网卡允许通过的VLAN号。
  
  type=`<veth>`

	虚拟网卡类型。

onboot: `<boolean>` (default = 0)
  
  设置容器是否随主机自动启动。

ostype:` <alpine | archlinux | centos | debian | fedora | gentoo | opensuse | ubuntu | unmanaged>`
  
  设置操作系统类型。供容器内部配置使用，并和/usr/share/lxc/config/<ostype>.common.conf中的lxc启动脚本对应。设置为unmanaged表示跳过操作系统相关配置。

protection:` <boolean>` (default = 0)
  
  设置容器的保护标志。设置后将禁止删除/变更容器及容器硬盘配置。

rootfs: `[volume=]<volume> [,acl=<1|0>][,mountoptions=<opt[;opt...]>] [,quota=<1|0>] [,replicate=<1|0>] [,ro=<1|0>] [,shared=<1|0>] [,size=<DiskSize>]`
  
  为容器配置根文件系统卷。
  
  acl=`<boolean>`

	设置启用或禁用ACL。

  `[,mountoptions=<opt[;opt...]>]`
    
    rootfs/mps挂载点的附加参数

  quota=`<boolean>`

	在容器内启用用户空间配额（对基于zfs子卷的存储卷无效）。

  replicate=`<boolean>` (default = 1)

    设置卷是否可以被调度任务复制。
  ro=`<boolean>`

    用于标识只读挂载点。
  
  shared=`<boolean>` (default = 0)

	设置非卷挂载点为所有节点可共享。

    - 警告 
      
      设置该参数不等于自动共享挂载点，而仅仅表示当前挂载点被假定已经共享。

  size=`<DiskSize>`
    
    挂载点存储卷容量（参数值只读）。
	
  volume=`<volume>`

	挂载到容器的卷、设备或目录。

searchdomain: `<string>`

  设置容器的DNS搜索域。如未指定nameserver和searchdomain，将在创建容器时直接使用主机的相关配置。

startup: `[[order=]\d+] [,up=\d+] [,down=\d+] `
  
  启动和关闭行为设置。参数order为非负整数，用于定义启动顺序。关闭顺序和启动顺序相反。此外还可以设置启动延时秒数，以指定下一个虚拟机启动或关闭之前的时间间隔。

swap: `<integer> `(0 -N) (default = 512)
  
  分配给容器的SWAP容量，单位为MB。

template: `<boolean>` (default = 0)
 
  启用/禁用模板

tty: `<integer> `(0 -6) (default = 2)
  
  指定容器可用的tty数量。

unprivileged:` <boolean> `(default = 0)
  
  设置容器以非特权用户权限运行。（不要手工修改该配置）

unused[n]:` <string>`
  
  标识未使用的存储卷。仅供Proxmox VE内部使用，不要手工修改该配置。

## 11.12 锁

容器迁移、快照创建和备份（vzdump）操作会设置容器锁，以避免不恰当的并发操作。某些情况下，你需要手工移除容器锁（例如，意外断电）。

```
pct unlock <CTID>
```

- 警告

  执行该操作前，务必确保设置锁的操作已经停止运行。
