# 12.8 示例


## 12.8.1. VLAN设置示例

> 虽然我们在这里显示了普通的配置内容，但几乎所有内容都应该只使用Web界面进行配置。

Node1: /etc/network/interfaces

```
auto vmbr0 
iface vmbr0 inet manual 
        bridge-ports eno1 
        bridge-stp off 
        bridge-fd 0 
        bridge-vlan-aware yes 
        bridge-vids 2-4094 

#management ip on vlan100 
auto vmbr0.100 
        iface vmbr0.100 inet static 
        address 192.168.0.1/24 

source /etc/network/interfaces.d/* 
```



Node2: /etc/network/interfaces 
```

auto vmbr0 
iface vmbr0 inet manual 
        bridge-ports eno1 
        bridge-stp off 
        bridge-fd 0 
        bridge-vlan-aware yes 
        bridge-vids 2-4094 

#management ip on vlan100 
auto vmbr0.100 
iface vmbr0.100 inet static 
        address 192.168.0.2/24 

source /etc/network/interfaces.d/*
```

创建名为‘myvlanzone’的VLAN zone：

```
id: myvlanzone 
bridge: vmbr0 
```

使用‘vlan-id’‘10’创建名为‘myvnet1’的VNet，并将之前创建的‘myvlanzone’作为其zone。

```
id: myvnet1 
zone: myvlanzone 
tag: 10 
```

通过主SDN面板应用配置，以便在每个节点上本地创建VNET。在node1上创建基于Debian的虚拟机(VM1)，并在“myvnet1”上创建vNIC。

为此VM使用以下网络配置：

```
auto eth0 
iface eth0 inet static 
        address 10.0.3.100/24
```

在node2上创建第二个虚拟机(Vm2)，并在与vm1相同的vNet‘myvnet1’上使用vNIC。

对此VM使用以下网络配置：


```
auto eth0 
iface eth0 inet static 
        address 10.0.3.101/24 
```

然后，您应该能够通过该网络在两个VM之间执行ping操作。

## 12.8.2 QinQ配置示例

> 虽然我们在这里显示了普通的配置内容，但几乎所有内容都应该只使用Web界面进行配置。

Node1: /etc/network/interfaces 

```
auto vmbr0 
iface vmbr0 inet manual 
        bridge-ports eno1 
        bridge-stp off 
        bridge-fd 0 
        bridge-vlan-aware yes 
        bridge-vids 2-4094 

#management ip on vlan100 
auto vmbr0.100 
iface vmbr0.100 inet static 
        address 192.168.0.1/24 

source /etc/network/interfaces.d/*
```


Node2: /etc/network/interfaces 

```
auto vmbr0 
iface vmbr0 inet manual 
        bridge-ports eno1 
        bridge-stp off 
        bridge-fd 0 
        bridge-vlan-aware yes 
        bridge-vids 2-4094 

#management ip on vlan100 
auto vmbr0.100 
iface vmbr0.100 inet static 
        address 192.168.0.2/24 

source /etc/network/interfaces.d/*
```

使用服务VLAN 20创建名为‘qinqzone1’的QinQ zone

```
id: qinqzone1 
bridge: vmbr0 
service vlan: 20 
```

使用服务VLAN 30创建另一个名为‘qinqzone2’的QinQ区域

```
id: qinqzone2 
bridge: vmbr0 
service vlan: 30 
```

在之前创建的‘qinqzone1’分区上创建名为‘myvnet1’、客户VLAN-id为100的vNet。

```
id: myvnet1 
zone: qinqzone1 
tag: 100 
```


在之前创建的‘qinqzone2’分区上创建一个客户VLAN-id为100的‘myvnet2’。

```
id: myvnet2 
zone: qinqzone2 
tag: 100
```

应用主SDN Web界面面板上的配置，在每个节点上本地创建VNET。

在node1上创建基于Debian的虚拟机(VM1)，并在‘myvnet1’上创建vNIC。

为此VM使用以下网络配置：

```
auto eth0 
iface eth0 inet static 
address 10.0.3.100/24
```

在node2上创建第二个虚拟机(Vm2)，并在与vm1相同的VNet‘myvnet1’上安装vNIC。
为此VM使用以下网络配置：


```
auto eth0 
iface eth0 inet static 
address 10.0.3.101/24
```

在节点1上创建第三个虚拟机(Vm3)，并在另一个VNet‘myvnet2’上创建一个vNIC。

为此VM使用以下网络配置：

```
auto eth0 
iface eth0 inet static 
address 10.0.3.102/24 
```

在节点2上创建另一个虚拟机(Vm4)，使vNIC位于与vm3相同的vNet‘myvnet2’上。

为此VM使用以下网络配置：

```
auto eth0 
iface eth0 inet static 
address 10.0.3.103/24 
```

然后，您应该能够在虚拟机vm1和vm2之间执行ping操作，也可以在vm3和vm4之间执行ping操作。但是，VM vm1或vm2都不能ping通VM vm3或vm4，因为它们位于具有不同服务VLAN的不同区域。

## 12.8.3. VXLAN 配置示例

> 虽然我们在这里显示了普通的配置内容，但几乎所有内容都应该只使用Web界面进行配置。

node1: /etc/network/interfaces 

```
auto vmbr0 
iface vmbr0 inet static 
        address 192.168.0.1/24 
        gateway 192.168.0.254 
        bridge-ports eno1 
        bridge-stp off
        bridge-fd 0 
        mtu 1500 

source /etc/network/interfaces.d/* 
```

node2: /etc/network/interfaces 

```
auto vmbr0 
iface vmbr0 inet static 
        address 192.168.0.2/24 
        gateway 192.168.0.254 
        bridge-ports eno1 
        bridge-stp off 
        bridge-fd 0 
        mtu 1500 

source /etc/network/interfaces.d/* 
```

node3: /etc/network/interfaces 

```
auto vmbr0 
iface vmbr0 inet static 
        address 192.168.0.3/24 
        gateway 192.168.0.254 
        bridge-ports eno1 
        bridge-stp off 
        bridge-fd 0 
        mtu 1500 

source /etc/network/interfaces.d/*
```


创建一个名为‘myvxlanzone’的VXLAN区域，使用较低的MTU确保可以容纳额外的50个字节的VXLAN报头。将节点之前配置的所有IP添加为对等地址列表。

```
id: myvxlanzone 
peers address list: 192.168.0.1,192.168.0.2,192.168.0.3 
mtu: 1450

```


使用之前创建的VXLAN区域‘myvxlanzone’创建名为‘myvnet1’的vNet。

```
id: myvnet1 
zone: myvxlanzone 
tag: 100000 
```

应用主SDN Web界面面板上的配置，在每个节点上本地创建VNET。

在node1上创建基于Debian的虚拟机(VM1)，并在‘myvnet1’上创建vNIC。

对此虚拟机使用以下网络配置，请注意此处较低的MTU。

```
auto eth0 
iface eth0 inet static 
address 10.0.3.100/24 
mtu 1450
```

在node3上创建第二个虚拟机(Vm2)，并在与vm1相同的vNet‘myvnet1’上安装vNIC。
为此VM使用以下网络配置：

```
auto eth0 
iface eth0 inet static 
address 10.0.3.101/24 
mtu 1450 
```

然后，您应该能够在vm1和vm2之间执行ping操作。


## 12.8.4 EVPN设置示例


node1: /etc/network/interfaces 

```
auto vmbr0 
iface vmbr0 inet static 
        address 192.168.0.1/24 
        gateway 192.168.0.254 
        bridge-ports eno1 
        bridge-stp off 
        bridge-fd 0 
        mtu 1500 

source /etc/network/interfaces.d/* 

```

node2: /etc/network/interfaces 

```
auto vmbr0 
iface vmbr0 inet static 
        address 192.168.0.2/24 
        gateway 192.168.0.254 
        bridge-ports eno1 
        bridge-stp off 
        bridge-fd 0 
        mtu 1500 

source /etc/network/interfaces.d/* 
```


node3: /etc/network/interfaces

```
auto vmbr0 
iface vmbr0 inet static 
        address 192.168.0.3/24 
        gateway 192.168.0.254 
        bridge-ports eno1 
        bridge-stp off 
        bridge-fd 0 
        mtu 1500 

source /etc/network/interfaces.d/* 
```

创建一个EVPN控制器，使用私有ASN号和以上节点地址作为对等设备。将上面的节点地址加入池。

```
id: myevpnctl 
asn: 65000 
peers: 192.168.0.1,192.168.0.2,192.168.0.3 

```

使用之前创建的EVPN-Controller创建名为‘myevpnzone’的EVPN区域。使用node1和node2作为退出节点

```
id: myevpnzone
vrf vxlan tag: 10000
controller: myevpnctl
mtu: 1450
vnet mac address: 32:F4:05:FE:6C:0A
exitnodes: node1,node2
```

创建一个名为'myvnet1'的VNET，使用EVPN区域'myevpnzone'

```
id: myvnet1
zone: myevpnzone
tag: 11000
```

创建一个子网10.0.1.0/24，并将10.0.1.1作为vnet1上的网关

```
subnet: 10.0.1.0/24
gateway: 10.0.1.1
```

创建第二个名为'mynet2'的子网，同样使用EVPN区域'myevpnzone'，只是ipv4网络不一样。

```
id: myvnet2
zone: myevpnzone
tag: 12000
```

创建一个不同的子网10.0.2.0/24，并将10.0.2.1作为vnet1上的网关

```
subnet: 10.0.2.0/24
gateway: 10.0.2.1
```


应用主SDN Web界面面板上的配置，在每个节点上本地创建VNET并生成FRR配置。


在node1上创建基于Debian的虚拟机(VM1)，并在‘myvnet1’上创建vNIC。
为此VM使用以下网络配置：

```
auto eth0 
iface eth0 inet static 
        address 10.0.1.100/24 
        gateway 10.0.1.1 #this is the ip of the vnet1 
        mtu 1450 
```

在node2上创建第二个虚拟机(Vm2)，在另一个vNet‘myvnet2’上创建一个vNIC。

为此VM使用以下网络配置：

```
auto eth0 
iface eth0 inet static 
        address 10.0.2.100/24 
        gateway 10.0.2.1 #this is the ip of the vnet2 
        mtu 1450 
```

然后，您应该能够从VM1 ping通vm2，并从vm2 ping通VM1。

如果您从非网关节点3上的vm2 ping外部IP，则数据包将到达配置的myvnet2网关，然后被路由到网关节点(节点1或节点2)，并从那里通过节点1或节点2上配置的默认网关离开这些节点。


- 注意

  当然，您需要将10.0.1.0/24和10.0.2.0/24网络的反向路由添加到您的外部网关上的node1、node2，这样公网才能回复。

如果您配置了外部BGP路由器，BGP-EVPN路由(本例中为10.0.1.0/24和10.0.2.0/24)将被动态通告。