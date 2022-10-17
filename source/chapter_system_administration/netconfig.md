# 3.3. 网络配置
网络配置可以通过GUI完成，也可以通过手动编辑包含整个网络配置的文件`/etc/network/interfaces`来完成。interfaces(5)手册页包含完整的格式说明。所有Proxmox VE工具都努力保持直接的用户修改，但使用GUI仍然是可取的，因为它可以保护您免受错误的影响。

一旦配置了网络，您可以使用 Debian 传统工具 ifup 和 ifdown 命令来启动和关闭接口。

## 3.3.1. 应用网络更改

Proxmox VE 不会将更改直接写入 `/etc/network/interfaces·。相反，我们写入一个名为`/etc/network/interfaces.new`的临时文件，这样你就可以一次做许多相关的更改。这还允许在应用之前确保您的更改是正确的，因为错误的网络配置可能会导致节点无法访问。

### 重启生效
使用默认安装的 ifupdown 网络管理包，您需要重新启动才能提交任何挂起的网络更改。大多数时候，基本的Proxmox VE网络设置是稳定的，不会经常更改，因此不需要经常重新启动。

### 使用 ifupdown2 重新加载网络

使用可选的 ifupdown2 网络管理软件包，您还可以实时重新加载网络配置，而无需重新启动。

从Proxmox VE 6.1开始，您可以使用节点的`"网络"`面板中的`"应用配置"`按钮，通过Web界面应用挂起的网络更改。

要安装 `ifupdown2` 确保您安装了最新的 Proxmox VE 更新，然后

**安装 ifupdown2 将删除 ifupdown，但由于版本 0.8.35+pve1 之前的 ifupdown 的删除脚本存在一个问题，即网络在删除时完全停止 [1] 您必须确保您拥有最新的 ifupdown 软件包版本。**

对于安装本身，您可以简单地执行以下操作：

`apt install ifupdown2`
有了它，一切就绪。如果遇到问题，您也可以随时切换回 ifupdown 变体。

## 3.3.2 网卡命名规范
目前我们采用的网络设备命名规范如下：
- 网卡：en*，即systemd类的网络接口命名。新安装的Proxmox VE 5.0将采用该命名规范。
- 网卡：eth[N]，其中0 ≤ N（eth0，eth1， …)。Proxmox VE 5.0之前的版本采用该命名规范。从旧版Proxmox VE升级至5.0以上版本时，网卡命名将保持不变，继续沿用该规范。
- 网桥：vmbr[N]，其中0 ≤ N ≤ 4094（vmbr0 - vmbr4094）
- 网口组合：bond[N]，其中0 ≤ N（bond0，bond1， …)
- VLANs：只需要将VLAN编号附加到网络设备名称后面，并用“.”分隔（eht0.50，bond1.30）

采用命名规范将网络设备名称和网络设备类型关联起来，能够大大降低网络故障排查难度。

### Systemd网卡命名规范

Systemd采用en作为网卡设备名称前缀。名称后续字符由网卡驱动和命名规范匹配先后顺序决定。
- o<index>[n<phys_port_name>|d<dev_port>]—板载设备命名
- s<slot>[f<function>][n<phys_port_name>|d<dev_port>]—按设备热插拔ID命名
- [P<domain>]p<bus>s<slot>[f<function>][n<phys_port_name>|d<dev_port>]—按设备总线ID命名
- x<MAC>—按设备MAC地址命名
最常见的命名模式如下
- eno1—第一个板载NIC网卡
- enp3s0f1—位于3号PCI总线，0号插槽，NIC功能号为1的NIC网卡。

更多信息参见[Predictable Network Interface Names](https://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/)。


## 3.3.3 网络配置规划
你需要根据当前的网络规划以及可用资源，决定具体采用的网络配置模式。可选模式包括网桥、路由以及地址转换三种类型。

**Proxmox VE服务器位于内部局域网，通过外部网关与互联网连接**

这种情况下最适宜采用网桥模式。这也是新安装Proxmox VE服务器默认采用的模式。该模式下，所有虚拟机通过虚拟网卡与Proxmox VE虚拟网桥连接。其效果类似于虚拟机网卡直接连接在局域网交换机上，而Proxmox VE服务器就扮演了这个交换机的角色。

**Proxmox VE托管于主机供应商，并分配有一段互联网公共IP地址**

这种情况下，可根据主机供应商分配的资源和权限，选择网桥模式或路由模式。

**Proxmox VE托管于主机供应商，但只有一个互联网公共IP地址**

这种情况下，虚拟机访问外部互联网的唯一办法就是通过地址转换。如果外部网络需要访问虚拟机，还需要配置端口转发。
为日后维护使用方便，可以配置VLANs（IEEE 802.1q）和网卡绑定，也就是“链路聚合”。这样就可以灵活地建立复杂虚拟机网络结构。

## 3.3.4 基于网桥的默认配置

网桥相当于一个软件实现的物理交换机。所有虚拟机共享一个网桥，在多个域的网络环境中，也可以创建多个网桥以分别对应不同网络域。理论上，每个Proxmox VE最多可以支持4094个网桥。
Proxmox VE安装程序会创建一个名为`vmbr0`的网桥，并和检测到的服务器第一块网卡桥接。配置文件`/etc/network/interfaces`中的对应配置信息如下：
```
auto lo
iface lo inet loopback

iface eno1 inet manual

auto vmbr0
iface vmbr0 inet static
address 192.168.10.2
netmask 255.255.255.0
gateway 192.168.10.1
bridge_ports eno1
bridge_stp off
bridge_fd 0
```
在基于网桥的默认配置下，虚拟机看起来就和直接接入物理网络一样。尽管所有虚拟机共享一根网线接入网络，但每台虚拟机都使用自己独立的MAC地址访问网络。


## 3.3.5 路由配置

但大部分IPC服务器供应商并不支持基于网桥的默认配置方式，出于网络安全的考虑，一旦发现网络接口上有多个MAC地址出现，他们会立刻禁用相关网络端口。

**提示**

也有一些IPC服务器供应商允许你注册多个MAC地址。这就可以避免上面提到的问题，但这样你就需要注册每一个虚拟机MAC地址，实际操作会非常麻烦。

你可以用配置“路由”的方式让多个虚拟机共享一个网络端口，这样就可以避免上面提到的问题。这种方式可以确保所有的对外网络通信都使用同一个MAC地址。

常见的应用场景是，你有一个可以和外部网络通信的IP地址（假定为192.51.100.5），还有一个供虚拟机使用的IP地址段（203.0.113.16/29）。针对该场景，我们推荐使用如下配置：
```
auto lo
iface lo inet loopback

auto eno1
iface eno1 inet static
address 192.51.100.5
netmask 255.255.255.0
gateway 192.51.100.1
post-up echo 1 > /proc/sys/net/ipv4/ip_forward 
post-up echo 1 > /proc/sys/net/ipv4/conf/eno1/proxy_arp

auto vmbr0
iface vmbr0 inet static
address 203.0.113.17
netmask 255.255.255.248
bridge_ports none
bridge_stp off
bridge_fd 0
```
## 3.3.6 基于iptables的网络地址转换配置（NAT）

利用地址转换技术，所有虚拟机可以使用内部私有IP地址，并通过Proxmox VE服务器的IP来访问外部网络。Iptables将改写虚拟机和外部网络通信数据包，对于虚拟机向外部网络发出的数据包，将源IP地址替换成服务器IP地址，对于外部网络返回数据包，将目的地址替换为对应虚拟机IP地址。
```
auto lo
iface lo inet loopback

auto eno1
#real IP address
iface eno1 inet static
address 192.51.100.5
netmask 255.255.255.0
gateway 192.51.100.1

auto vmbr0
#private sub network
iface vmbr0 inet static
address 10.10.10.1
netmask 255.255.255.0
bridge_ports none
bridge_stp off
bridge_fd 0
post-up echo 1 > /proc/sys/net/ipv4/ip_forward
post-up iptables -t nat -A POSTROUTING -s ’10.10.10.0/24’ -o eno1
-j MASQUERADE
post-down iptables -t nat -D POSTROUTING -s ’10.10.10.0/24’ -o eno1
-j MASQUERADE
```

## 3.3.7 Linux多网口绑定
多网口绑定（也称为网卡组或链路聚合）是一种将多个网卡绑定成单个网络设备的技术。利用该技术可以实现某个或多个目标，例如提高网络链路容错能力，增加网络通信性能等。

类似光纤通道和光纤交换机这样的高速网络硬件的价格一般都非常昂贵。利用链路聚合技术，将两个物理网卡组成一个逻辑网卡，能够将网络传输速度加倍。大部分交换机设备都已经支持Linux内核的这个特性。如果你的服务器有多个以太网口，你可以将这些网口连接到不同的交换机，以便将故障点分散到不同的网络设备，一旦有物理线路故障或网络设备故障发生，多网卡绑定会自动将通信流量从故障线路切换到正常线路。

链路聚合技术可以有效减少虚拟机在线迁移的时延，并提高Proxmox VE集群服务器节点之间的数据复制速度。

目前一共有7种网口绑定模式：
- 轮询模式（blance-rr）：网络数据包将按顺序从绑定的第一个网卡到最后一个网卡轮流发送。这种模式可以同时实现负载均衡和链路容错效果。
- 主备模式（active-backup）：该模式下网卡组中只有一个网卡活动。只有当活动的网卡故障时，其他网卡才会启动并接替该网卡的工作。整个网卡组使用其中一块网卡的MAC地址作为对外通信的MAC地址，以避免网络交换机产生混乱。这种模式仅能实现链路容错效果。
- 异或模式（balance-xor）：网络数据包按照异或策略在网卡组中选择一个网卡发送（[源MAC地址 XOR 目标MAC地址] MOD 网卡组中网卡数量）。对于同一个目标MAC地址，该模式每次都选择使用相同网卡通信。该模式能同时实现负载均衡和链路容错效果。
- 广播模式（broadcast）：网络数据包会同时通过网卡组中所有网卡发送。该模式能实现链路容错效果。
- IEEE 802.3ad动态链路聚合模式（802.3ad）（LACP）：该模式会创建多个速度和双工配置一致的聚合组。并根据802.3ad标准在活动聚合组中使用所有网卡进行通信。
- 自适应传输负载均衡模式（balance-tlb）：该Linux网卡绑定模式无须交换机支持即可配置使用。根据当前每块网卡的负载情况（根据链路速度计算的相对值），流出的网络数据包流量会自动进行均衡。流入的网络流量将由当前指定的一块网卡接收。如果接收流入流量的网卡故障，会自动重新指定一块网卡接收网络数据包，但该网卡仍沿用之前故障网卡的MAC地址。
- 自适应负载均衡模式（均衡的IEEE 802.3ad动态链路聚合模式（802.3ad）（LACP）:-alb）：该模式是在blance-tlb模式的基础上结合了IPV4网络流量接收负载均衡（rlb）特性，并且无须网络交换机的专门支持即可配置使用。网络流量接收负载均衡基于ARP协商实现。网卡组驱动将自动截获本机的ARP应答报文，并使用网卡组中其中一块网卡的MAC地址覆盖ARP报文中应答的源MAC地址，从而达到不同的网络通信对端和本机不同MAC地址通信的效果。

在网络交换机支持LACP（IEEE 802.3ad）协议的情况下，推荐使用LACP绑定模式（802.3ad），其他情况建议使用active-backup模式。

对于Proxmox集群网络的网卡绑定，目前仅支持active-backup模式，其他模式均不支持。

下面所列的网卡绑定配置示例可用于分布式/共享存储网络配置。其主要优势是能达到更高的传输速度，同时实现网络链路容错的效果。

示例：基于固定IP地址的多网卡绑定
```
auto lo
iface lo inet loopback

iface eno1 inet manual

iface eno2 inet manual

auto bond0
iface bond0 inet static
slaves eno1 eno2
address 192.168.1.2
netmask 255.255.255.0
bond_miimon 100
bond_mode 802.3ad
bond_xmit_hash_policy layer2+3

auto vmbr0
iface vmbr0 inet static
address 10.10.10.2
netmask 255.255.255.0
gateway 10.10.10.1
bridge_ports eno1
bridge_stp off
bridge_fd 0
```
另一种配置方法是直接使用网卡组作为虚拟交换机桥接端口，从而实现虚拟机网络的容错效果。

示例：利用多网卡绑定配置网桥端口
```
auto lo
iface lo inet loopback

iface eno1 inet manual

iface eno2 inet manual

auto bond0
iface bond0 inet maunal
slaves eno1 eno2
bond_miimon 100
bond_mode 802.3ad
bond_xmit_hash_policy layer2+3

auto vmbr0
iface vmbr0 inet static
address 10.10.10.2
netmask 255.255.255.0
gateway 10.10.10.1
bridge_ports bond0
bridge_stp off
bridge_fd 0
```
## 3.3.8 VLAN 802.1Q
虚网（VLAN）是基于2层网络的广播域划分和隔离技术。利用VLAN，可以在一个物理网络中创建多个（最多4096）相互隔离的子网。
每个VLAN都有一个独立的，称为tag的编号。相应的，每个网络数据包都被标上tag以标明其所属的VLAN。

### 基于VLAN的虚拟机网络
Proxmox VE直接支持VLAN模式。创建虚拟机时，可以指定tag，使该虚拟机接入对应VLAN。VLAN tag是虚拟机网络配置的一部分。根据虚拟网桥配置的不同，网络层支持多种不同的VLAN实现模式：
- Linux网桥感知VLAN配置模式：这种方式下，每个虚拟机的虚拟网卡都分配了一个VLAN tag，Linux网桥将自动支持这些虚拟网卡的VLAN tag。也可以将虚拟网卡配置为trunk模式，但VLAN tag的配置就需要在虚拟机内部另行配置完成。
- Linux网桥传统VLAN配置模式：不同于VLAN感知模式，传统模式下的Linux网桥不能直接支持配有VLAN tag的虚拟网卡，而需要为每个VLAN另行创建一个虚拟网桥，以便连接该属于VLAN的虚拟网卡设备。例如要在默认网桥上配置一个VLAN 5供虚拟机使用，就需要创建一个虚拟网卡eno1.5和虚拟网桥vmbr0v5，然后重启服务器以使其生效。
- Open vSwitch VLAN配置模式：基于OVS VLAN特性实现。
- 虚拟机配置VLAN模式：这种配置模式下，VLAN是在虚拟机内部配置实现的。这时，有关配置完全在虚拟机内部实现，不受外部配置干扰。这种配置模式最大好处是可以在一个虚拟网卡上同时运行多个VLAN。

### Proxmox VE主机上的VLAN
Proxmox VE主机上配置VLAN，可以将主机网络通信与其他网络的逻辑隔离。实际上，你可以在任意网络设备上配置使用VLAN tag（如网卡、多网卡绑定，网桥）。一般情况下，你应该在与物理网卡最近，中间虚拟设备数最少的接口设备上配置VLAN tag。

思考一下，在默认网络配置下，你会在的哪个设备上配置Proxmxo VE的管理地址VLAN？

示例：在传统Linux Bridge上利用VLAN 5配置Proxmox VE管理IP
```
auto lo
iface lo inet loopback

iface eno1 inet manual

iface eno1.5 inet manual

auto vmbr0v5
iface vmbr0v5 inet static
address 10.10.10.2
netmask 255.255.255.0
gateway 10.10.10.1
bridge_ports eno1.5
bridge_stp off
bridge_fd 0

auto vmbr0
iface vmbr0 inet manual
bridge_ports eno1
bridge_stp off
bridge_fd 0
```

示例：在启用VLAN感知的Linux Bridge上利用VLAN 5配置Proxmox VE管理IP
```
auto lo
iface lo inet loopback

iface eno1 inet manual

auto vmbr0.5
iface vmbr0.5 inet static
address 10.10.10.2
netmask 255.255.255.0
gateway 10.10.10.1

auto vmbr0
iface vmbr0 inet manual
bridge_ports eno1
bridge_stp off
bridge_fd 0
bridge_vlan_aware yes
```
下一个示例配置实现的功能完全一样，但是增加了多网卡绑定，以避免单链路故障。

示例：在传统Linux Bridge上利用bond0和VLAN 5配置Proxmox VE管理IP
```
auto lo
iface lo inet loopback

iface eno1 inet manual

iface eno2 inet manual

auto bond0
iface bond0 inet manual
slaves eno1 eno2
bond_miimon 100
bond_mode 802.3ad
bond_xmit_hash_policy layer2+3

iface bond0.5 inet manual

auto vmbr0v5
iface vmbr0v5 inet static
address 10.10.10.2
netmask 255.255.255.0
gateway 10.10.10.1
bridge_ports bond0.5
bridge_stp off
bridge_fd 0

auto vmbr0
iface vmbr0 inet manual
bridge_ports bond0
bridge_stp off
bridge_fd 0
```
## 3.3.9. 禁用IPV6
Proxmox VE在所有环境中都能正常工作，无论是否部署了IPv6。我们建议将所有设置保留为提供的默认值。

如果仍需要在节点上禁用对 IPv6 的支持，请通过创建适当的 sysctl.conf （5） 代码段文件并设置正确的 sysctl 来执行此操作，例如添加 /etc/sysctl.d/disable-ipv6.conf 和内容：
```
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
```
此方法比在[内核命令行](https://www.kernel.org/doc/Documentation/networking/ipv6.rst)上禁用 IPv6 模块的加载更可取。
