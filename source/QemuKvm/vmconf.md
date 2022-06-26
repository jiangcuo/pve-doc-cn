# 10.13虚拟机配置文件

虚拟机配置文件保存在Proxmox集群文件系统中，并可以通过路径`/etc/pve/qemu-server/<VMID>.conf`访问。和`/etc/pve`下的其他文件一样，虚拟机配置文件会自动同步复制到集群的其他节点。

### 注意

小于100的VMID被Proxmox VE保留内部使用，并且在集群内的VMID不能重复。

## 虚拟机配置文件示例

```
boot: order=virtio0;net0
cores: 1
sockets: 1
memory: 512
name: webmail
ostype: l26
net0: e1000=EE:D2:28:5F:B6:3E,bridge=vmbr0
virtio0: local:vm-100-disk-1,size=32G
```

虚拟机配置文件就是普通文本文件，可以直接使用常见文本编辑器（vi，nano等）编辑。这也是日常对虚拟机配置文件进行细微调整的一般做法。但是务必注意，必须彻底关闭虚拟机，然后再启动虚拟机，修改后的配置才能生效。

因此，更好的做法是使用qm命令或WebGUI来创建或修改虚拟机配置文件。Proxmox VE能够直接将大部分变更直接应用到运行中的虚拟机，并即时生效。该特性称为“热插拔“，并无需重启虚拟机。

## 10.13.1配置文件格式
虚拟机配置文件使用英文冒号字符“:“为分隔符的键/值格式。格式如下：

```
# this is a comment
OPTION: value
```

空行会被自动忽略，以字符`#`开头的行按注释处理，也会被自动忽略。

## 10.13.2 虚拟机快照

创建虚拟机快照后，qm会在配置文件中创建一个小节，专门保存创建虚拟机快照时的虚拟机配置。例如，创建名为“testsnapshot“的虚拟机快照后，虚拟机配置文件内容可能会像下面这样：


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
```

其中parent和snaptime是和虚拟机快照相关的配置属性。属性parent用于保存快照之间的父/子关系，属性snaptime是创建快照的时间戳（Unix epoch）。

可以选择使用`vmstate`选项保存虚拟机的内存状态。关于如何选择虚拟机内存状态的保存目录，请参阅10.11休眠章节.

## 10.13.3 虚拟机配置项目

- acpi : `<boolean> `(default = 1 )
  
  启用/禁用 ACPI。

- agent:` [enabled=]<1|0> [,fstrim_cloned_disks=<1|0>]`

  启用/禁用Qemu GuestAgent及其属性。

- enabled=`<boolean>` (default = 0)

  启用/禁用Qemu GuestAgent。

- fstrim_cloned_disks=`<boolean>` (default = 0)

  在克隆/迁移虚拟磁盘后运行fstrim。

- arch: `<aarch64 | x86_64>`

  虚拟CPU架构。默认为host。

- args :` <string>`

  传递给kvm的任意参数，例如：
  
  ```
  args: -no-reboot -no-hpet
  ```

  注意:args仅供专家使用。

- audio0: device=`<ich9-intel-hda|intel-hda|AC97>` [,driver=<spice|none>]
 
  配置虚拟声卡，与Spice/QXL配合很有用。

  device=`<ich9-intel-hda|intel-hda|AC97>` 选择声卡的类型

  driver=`<none | spice> `(default = spice) 选择声卡的后端驱动，默认为spice


- autostart : `<boolean>` (default = 0 )

  虚拟机崩溃后自动启动（目前该属性会被自动忽略）

- balloon : `<integer>` (0 -N)

  为虚拟机配置的目标内存容量，单位为MB。设为0表示禁用ballon驱动程序。
  
- bios : `<ovmf | seabios>` (default = seabios )

  设置BIOS类型。

- boot: `[[legacy=]<[acdn]{1,4}>] [,order=<device[;device...]>]`

  legacy=`<[acdn]{1，4}>` （default = cdn)，虚拟机启动顺序，软驱（a），硬盘（c），光驱（d），或网络（n）。现已弃用，请改用`order`

  order=`<device[;d evice...]>`,虚拟机将按照此规则进行启动。磁盘、光驱和直通存储USB设备将直接从中启动，NIC将加载PXE，PCIe设备如果是磁盘（Nvme）就会启动或加载OPTION ROM（例如RAID控制器、硬件NIC）。

  注意，只有在这里被标记成可启动设备，才能由虚拟机的（BIOS/UEFI）加载。如果您需要多个磁盘进行引导（例如software-raid），则需要在此处指定所有磁盘。
  
  使用order将会忽略legacy的值

- bootdisk: `(ide|sata|scsi|virtio)\d+`
 
  指定启动磁盘，已经弃用，请使用 `boot: order=xx`

- cdrom:`<volume>`

  光驱，相当于-ide2的别名。

- cicustom: `[meta=<volume>] [,network=<volume>] [,user=<volume>] [,vendor=<volume>]
`
  - 使用指定文件代替自动生成文件。

  - meta=`<volume>`，将包含所有元数据的指定文件通过cloud-init传递给虚拟机。该文件提供指定configdrive2和nocluod信息。

  - network=`<volume>`，将包含所有网络配置数据的指定文件通过cloud-init传递给虚拟机。

  - user=`<volume>` ，将包含所有用户配置数据的指定文件通过cloud-init传递给虚拟机。

- cipassword: `<string>`

  Cloud-Init：用户口令。通常推荐使用SSH密钥认证，不要使用口令方式认证。请注意，旧版Cloud-Init不支持口令hash加密。

- citype: `<configdrive2 | nocloud | opennebula>`

  Cloud-Init：指定Cloud-Init配置数据格式。默认依赖于操作系统类型（ostype）。Linux可设置为nocloud，Windows可设置为configdrive2。

- ciuser: `<string>`
  
  Cloud-Init：指定用户名，同时不再使用镜像配置的默认用户。

- cores : <integer> (1 -N) (default = 1 )

  每个插槽的CPU核心数量

- cpu:` [[cputype=]<string>] [,flags=<+FLAG[;-FLAG...]>] [,hidden=<1|0>] [,hv-vendor-id=<vendor-id>] [,phys-bits=<8-64|host>] [,reported-model=<enum>]`

  - 模拟CPU类型。

  - cputype=`<string>` (default = kvm64)

    模拟的CPU类型。可以使用默认类型，也可以自定义类型。自定义类型将以`custom-`开头。

  - flags=`<+FLAG[;-FLAG...]>`

    CPU标识列表，分隔符为分号“;”，启用标识使用+FLAG，禁用标识使用-FLAG。目前支持的标识有：pcid, spec-ctrl, ibpb, ssbd, virt-ssbd, amd-ssbd, amd-no-ssb, pdpe1gb,md-clear。

  - hidden = `<boolean>` (default = 0 )
  
    设为1表示不标识为KVM虚拟机。

  - hv-vendor-id=`<vendor-id>`
  
    Hyper-V厂商ID。Windows客户机的部分驱动或程序可能需要指定ID

  - phys-bits=`<8-64|host>`
 
    报告给客户机操作系统的物理内存地址位。应小于或等于主机的物理内存地址位。设置为 host 以使用主机 CPU 中的值
 
  - reported-model=`<enum>`
   
    486 | Broadwell | Broadwell-IBRS | Broadwell-noTSX | Broadwell-noTSX-IBRS | Cascadelake-Server | Cascadelake-Server-noTSX | Conroe | EPYC | EPYC-IBPB | EPYC-Rome | Haswell | Haswell-IBRS | Haswell-noTSX | Haswell-noTSX-IBRS | Icelake-Client | Icelake-Client-noTSX | Icelake-Server | Icelake-Server-noTSX | IvyBridge | IvyBridge-IBRS | KnightsMill | Nehalem | Nehalem-IBRS | Opteron_G1 | Opteron_G2 | Opteron_G3 | Opteron_G4 | Opteron_G5 | Penryn | SandyBridge | SandyBridge-IBRS | Skylake-Client | Skylake-Client-IBRS | Skylake-Client-noTSX-IBRS | Skylake-Server | Skylake-Server-IBRS | Skylake-Server-noTSX-IBRS | Westmere | Westmere-IBRS | athlon | core2duo | coreduo | host | kvm32 | kvm64 | max | pentium | pentium2 | pentium3 | phenom | qemu32 | qemu64  (default = kvm64)
    
    所选择的型号及厂商，将会传递给虚拟机，但必须选择QEMU支持的CPU模型。只有自定义CPU模型才能将自定义厂商ID传递给虚拟机，默认的CPU模型会始终传递自身的默认属性。

- cpulimit :` <number>` (0 -128) (default = 0 )
    
  CPU配额上限值。

  注意：如果一台计算机有2个CPU，那么该计算机一共有2份额的CPU时间片可以分配。设为0表示不限制CPU配额。
    
- cpuunits : `<integer> `(2 -262144) (default = cgroup v1: 1024, cgroup v2: 100 )

  虚拟机的CPU时间片分配权重值。该参数供内核的公平调度器使用。设定的权重值越大，虚拟机得到的CPU时间片越多。最终分配得到的时间片由该虚拟机权重和所有其他虚拟机权重总和之比决定。

- description : `<string>`

  虚拟机描述信息。仅供WebGUI使用。在虚拟机配置文件中以注释形式保存。

- efidisk0 :` [file=]<volume> [,efitype=<2m|4m>] [,format=<enum>] [,pre-enrolled-keys=<1|0>] [,size=<DiskSize>]`

  配置用于存储 EFI 变量的磁盘。使用特殊语法 STORAGE_ID:SIZE_IN_GiB 分配新卷。请注意，此处忽略 SIZE_IN_GiB，而是将默认 EFI 变量复制到卷中。

  - efitype=`<2m | 4m>` (default = 2m)

    EFI变量的大小，4m最新且推荐使用，用于安全启动。为了向后兼容性，如果没有制定，则使用2m。

  - file=`<volume>`

    EFI虚拟硬盘所基于的存储服务卷名称。

  - format = `<cloop | cow | qcow | qcow2 | qed | raw | vmdk>`
    
    EFI虚拟硬盘所采用的存储格式。

  - pre-enrolled-keys=`<boolean>` (default = 0)
  
    预注册密钥。如果与efitype=4m 一起使用，则使用EFI模板并注册特定于分发的密钥和 Microsoft 标准密钥。请注意，这将默认启用安全启动，但仍可以从VM中BIOS将其关闭。

  - size = `<DiskSize>`
    
    EFI虚拟硬盘容量。仅供显示使用，并不能影响实际容量大小。
  
- freeze : `<boolean>`

  虚拟机启动时自动冻结CPU（使用监视器命令c可继续启动过程）。

- hookscript: `<string>`

  回调脚本，将在虚拟机生命周期的各个步骤中执行的脚本。如启动阶段，关闭阶段。

- hostpci[n]: [host=]<HOSTPCIID[;HOSTPCIID2...]> [,mdev=<string>][,pcie=<1|0>] [,rombar=<1|0>] [,romfile=<string>] [,x-vga=<1|0>]

  将物理主机PCI设备映射给虚拟机。

    注意：该属性允许虚拟机直接访问物理主机硬件。启用后将不能再进行虚拟机迁移操作，因此使用时务必小心

    警告：该特性仍处于试验阶段，有用户报告该属性会导致故障和问题。

  - host =` <HOSTPCIID[;HOSTPCIID2...]>`
  
    将PCI设备直通虚拟机使用。可指定一个或一组设备的PCI ID。HOSTPCIID格式为“总线号:设备号.功能号“（16进制数字表示），具体可使用lspci命令查看。

  - mdev=`<string>`
    
    表示中介设备类型。虚拟机启动时会自动创建设备，停止时自动删除清理。

  - pcie = `<boolean> `(default = 0 )
    
    标明是否是PCI-express类型总线（用于q35类型计算机）。

  - rombar = `<boolean> `(default = 1 )
  
    标明是否将设备ROM映射至虚拟机内存空间。

  - romfile=`<string>`
  
    pci设备的rom文件名（文件需要保存在/usr/share/kvm/下）。

  - x-vga = `<boolean> `(default = 0 )
    
    标明是否启用vfio-vga设备支持。

- hotplug : `<string> `(default = network,disk,usb )

  设置启用的热插拔设备类型。启用热插拔的设备类型之间用英文逗号字符分隔，
  可选参数值包括network，disk，cpu，memory和usb。设为0表示禁用热插拔，
  设为1表示启用默认值network,disk,usb.

- hugepages : `<1024 | 2 | any>`

  启用/禁用巨型页。

- ide[n]: [file=]`<volume>` [,aio=<native|threads|io_uring>] [,backup=<1|0>] [,bps=<bps>] [,bps_max_length=<seconds>] [,bps_rd=<bps>] [,bps_rd_max_length=<seconds>] [,bps_wr=<bps>] [,bps_wr_max_length=<seconds>] [,cache=<enum>] [,cyls=<integer>] [,detect_zeroes=<1|0>] [,discard=<ignore|on>] [,format=<enum>] [,heads=<integer>] [,iops=<iops>] [,iops_max=<iops>] [,iops_max_length=<seconds>] [,iops_rd=<iops>] [,iops_rd_max=<iops>] [,iops_rd_max_length=<seconds>] [,iops_wr=<iops>] [,iops_wr_max=<iops>] [,iops_wr_max_length=<seconds>] [,mbps=<mbps>] [,mbps_max=<mbps>] [,mbps_rd=<mbps>] [,mbps_rd_max=<mbps>] [,mbps_wr=<mbps>] [,mbps_wr_max=<mbps>] [,media=<cdrom|disk>] [,model=<model>] [,replicate=<1|0>] [,rerror=<ignore|report|stop>] [,secs=<integer>] [,serial=<serial>] [,shared=<1|0>] [,size=<DiskSize>] [,snapshot=<1|0>] [,ssd=<1|0>] [,trans=<none|lba|auto>] [,werror=<enum>] [,wwn=<wwn>]

  配置IDE类型虚拟硬盘或光驱（n的值为0-3）。使用STORAGE_ID:SIZE_IN_GiB语法去分配虚拟硬盘
 
  - aio=`<io_uring | native | threads>`

    指定异步io模型。默认为io_uring

  - backup=`<boolean>`

    设置虚拟硬盘在进行虚拟机备份时是否被纳入备份范围。

  - bps=`<bps>`

    最大读写操作速度，单位为字节/秒。

  - bps_max_length=`<seconds>`

    突发读写操作最大时间长度，单位为秒。

  - bps_rd=`<bps>`

    最大读操作速度，单位为字节/秒。

  - bps_rd_max_length=`<seconds>`

    突发读操作最大时间长度，单位为秒。

  - bps_wr=`<bps>`
 
    最大写操作速度，单位为字节/秒

  - bps_wr_max_length=`<seconds>`

    突发写操作最大时间长度，单位为秒。

  - cache=`<directsync | none | unsafe | writeback | writethrough>`

    虚拟硬盘缓存工作模式

  - cyls=`<integer>`

    强制指定虚拟硬盘物理几何参数中的cylinder值

  - detect_zeroes=`<boolean>`

    设置是否检测并优化零写入操作。

  - discard=`<ignore | on>`

    设置是否向下层存储服务传递discard/trim操作请求。

  - file=`<volume>`

    IDE虚拟硬盘所基于的存储服务卷名称。

  - format=`<cloop | cow | qcow | qcow2 | qed | raw | vmdk>`

    IDE虚拟硬盘所采用的存储格式。

  - heads=`<integer>`

    强制指定虚拟硬盘物理几何参数中的head值。

  - iops=`<iops>`

    最大读写I/O速度，单位为个/秒。

  - iops_max=`<iops>`

    最大无限制读写I/O速度，单位为个/秒。

  - iops_max_length=`<seconds>`

    突发读写操作最大时间长度，单位为秒。

  - iops_rd=`<iops>`

    最大读I/O速度，单位为个/秒。

  - iops_rd_max=`<iops>`

    最大无限制读I/O速度，单位为个/秒。

  - iops_rd_max_length=`<seconds>`

    突发读操作最大时间长度，单位为秒。

  - iops_wr=`<iops>`
     
    最大写I/O速度，单位为个/秒。

  - iops_wr_max=`<iops>`

    最大无限制写I/O速度，单位为个/秒。

  - iops_wr_max_length=`<seconds>`

    突发读操作最大时间长度，单位为秒。

  - mbps=`<mbps>`

    最大读写操作速度，单位为MB/秒。

  - mbps_max=`<mbps>`

    最大无限制读写操作速度，单位为MB/秒。

  - mbps_rd=`<mbps>`

    最大读操作速度，单位为MB/秒。

  - mbps_rd_max=`<mbps>`

    最大无限制读操作速度，单位为MB/秒。

  - mbps_wr=`<mbps>`

    最大写操作速度，单位为MB/秒。

  - mbps_wr_max=`<mbps>`
    
    最大无限制写操作速度，单位为MB/秒。

  - media=`<cdrom | disk> `(default = disk)

    虚拟硬盘驱动器介质类型。

  - model=`<model>`

    虚拟硬盘的模型名，基于url编码格式，最大40字节。

  - replicate=`<boolean> `(default = 1)

    磁盘是否被调度复制。

  - rerror=`<ignore | report | stop>`

    读错误处理方式。

  - secs=`<integer>`

    强制指定虚拟硬盘物理几何参数中的sector值。

  - serial=`<serial>`
 
    虚拟硬盘的序列号，基于url编码格式，最大20字节。

  - shared=`<boolean> `(default = 0)

    将本地管理卷标记为所有节点均可用。
    
    注意：该选项并不自动共享卷，只是假定该卷已经被共享。

  - size=`<DiskSize>`

    虚拟硬盘容量。仅供显示使用，并不能影响实际容量大小。

  - snapshot=`<boolean>`

    Qemu快照功能控制选项。设置后，对磁盘的改写会被当成临时的，并在虚拟机重启后全部丢弃。
  
  - ssd=`<boolean>`

    设置虚拟磁盘连接到虚拟机的方式，SSD或硬盘。

  - trans=`<auto | lba | none>`

    设置虚拟硬盘几何参数地址bios解释模式。

  - werror=`<enospc | ignore | report | stop>`

    写错误处理方式。

  - wwn=`<wwn>`

    驱动器的唯一名称，使用16字节hex字符串表示，前缀为0x。

- ipconfig[n]: `[gw=<GatewayIPv4>] [,gw6=<GatewayIPv6>] [,ip=<IPv4Format/CIDR>] [,ip6=<IPv6Format/CIDR>]`

  loud-Init：为对应端口设置IP地址和网关。
  IP地址采用CIDR格式，网关为可选项，也采用CIDR格式IP形式设置。
  在DHCP环境中可将IP地址设置为字符串dhcp，此时应将网关留空。在IPv6网络中，如需启用无状态自动配置，将IP设置为字符串auto即可。
  如未设置IPv4或IPv6地址，Cloud-Init默认将使用IPv4的dhcp。

  - gw=`<GatewayIPv4>`
    
    IPv4的默认网关

    注意：需要和ip配合使用

  - gw6=`<GatewayIPv6>`
  
    IPv6的默认网关

    注意：需要和ip6配合使用

  - ip=`<IPv4Format/CIDR>` (default = dhcp) 

    IPv4地址，采用CIDR格式。
 
  - ip=`<IPv6Format/CIDR> `(default = dhcp) 

    IPv6地址，采用CIDR格式。

- ivshmem: size=`<integer>` [,name=<string>]

  内部虚拟机共享内存。可实现虚拟机之间、主机虚拟机之间的直接通信。

  - name=`<string>`

    设备文件名称。会自动添加前缀pve-shm-。默认为虚拟机VMID，并将在虚拟机停止后自动删除。
  
  - size=`<integer>` (1 - N)

    文件大小，单位MB。

- keephugepages:` <boolean>` (default = 0)

  与huepages一起使用。如果启用，则在 VM 关闭后不会删除大页，可用于后续启动。

- keyboard: `<da | de | de-ch | en-gb | en-us | es | fi | fr | fr-be | fr-ca | fr-ch | hu | is | it | ja | lt | mk | nl | no | pl | pt | pt-br | sl | sv | tr>`

  键盘布局设置，用于vnc服务器。默认采用/etc/pve/datacenter.conf中的设置值。 

- kvm: `<boolean>` (default = 1)

  启用/禁用KVM硬件虚拟化。

- localtime: `<boolean>`

  设置虚拟机时间是否采用服务器本地时间。如虚拟机操作系统类型为Microsoft OS，则默认启用该项。

- lock: `<backup | clone | create | migrate | rollback | snapshot | snapshot-delete | suspended | suspending>`

  锁定/解锁虚拟机。

- machine: (pc|pc(-i440fx)?-\d+(\.\d+)+(\+pve\d+)?(\.pxe)?|q35|pc-q35-\d+(\.\d+)+(\+pve\d+)?(\.pxe)?|virt(?:-\d+(\.\d+)+)?(\+pve\d+)?)

  设置Qemu虚拟机类型。

- memory: `<integer> `(16 - N) (default = 512)

  设置虚拟机内存容量，单位为MB。启用balloon驱动时，该值为最大可用内存值。

- migrate_downtime: `<number> `(0 - N) (default = 0.1)

  设置虚拟机在线迁移时最大停机时间（单位为秒）。
  
- migrate_speed: `<integer> `(0 - N) (default = 0)

  设置虚拟机迁移时最大数据传输速度（单位为MB/s）。设为0表示不限速。

- name: `<string>`

  设置虚拟机名称。仅用于WebGUI界面。

- nameserver: `<string>`

  Cloud-Init：为容器设置DNS服务器IP地址。如未设置searchdomian及nameserver，将自动采用服务器主机设置创建有关配置。

- net[n]: [model=]`<enum> `[,bridge=<bridge>] [,firewall=<1|0>] [,link_down=<1|0>] [,macaddr=<XX:XX:XX:XX:XX:XX>] [,mtu=<integer>] [,queues=<integer>] [,rate=<number>] [,tag=<integer>] [,trunks=<vlanid[;vlanid...]>] [,<model>=<macaddr>]

  设置虚拟网络设备
  
  - bridge=`<bridge>`

    虚拟网络设备桥接的虚拟交换机。Proxmox VE默认创建虚拟交换机名为vmbr0。
    如未指定虚拟交换机，Proxmox VE将创建KVM网络设备（NAT），并提供DHCP和DNS服务。具体地址如下：
    
    - 10.0.2.2 Gateway
    
    - 10.0.2.3 DNS Server
    
    - 10.0.2.4 SMB Server
    
    其中DHCP服务器将从10.0.2.15开始分配IP地址

  - firewall=`<boolean>`
     
    是否在此虚拟机网卡上启用防火墙功能。 
  
  - link_down=`<boolean>`

    将此虚拟网卡设为断开状态。

  - macaddr=`<XX:XX:XX:XX:XX:XX>`
    
    MAC地址。

  - model=`<e1000 | e1000-82540em | e1000-82544gc | e1000-82545em | e1000e | i82551 | i82557b | i82559er | ne2k_isa | ne2k_pci | pcnet | rtl8139 | virtio | vmxnet3>`

    虚拟网卡类型。其中virtio性能最好。若虚拟机不支持virtio，最好使用e1000。

  - mtu=`<integer> `(1 - 65520)

    只针对于virtio类型虚拟机网卡，强制设置mtu。设为1则继承网桥的mtu。

  - queues=`<integer>` (0 - 16)

    设置虚拟网卡的包队列数量。

  - rate=`<number> `(0 - N)

    虚拟网卡最大传输速度，单位为Mb/s。

  - tag=`<integer> `(1 - 4094)

    在此虚拟网卡的数据包上自动标记的vlan标签。

  - trunks=`<vlanid[;vlanid...]>`

    虚拟网卡上允许通过的vlan标签

- numa: `<boolean> `(default = 0)

  启用/禁用NUMA。

- numa[n]: cpus=`<id[-id];...> [,hostnodes=<id[-id];...>] [,memory=<number>] [,policy=<preferred|bind|interleave>]`
  
  设置NUMA拓扑

  - cpus=`<id[-id];...>`
 
    当前NUMA节点上的CPU列表。

  - hostnodes=`<id[-id];...>`

    所采用的主机NUMA节点。

  - memory=`<number>`

    NUMA节点所提供的内存容量。

  - policy=`<bind | interleave | preferred>`
 
    NUMA分配策略

- onboot: `<boolean> `(default = 0)

  设置虚拟机是否在物理服务器启动时自动启动。

- ostype:` <l24 | l26 | other | solaris | w2k | w2k3 | w2k8 | win10 | win11 | win7 | win8 | wvista | wxp>`

  虚拟机操作系统类型。用于启用针对操作系统的优化和功能特性。可选值如下：

  - other
    
    unspecified OS

  - wxp
  
    Microsoft Windows XP

  - w2k
    
    Microsoft Windows 2000

  - w2k3
    
    Microsoft Windows 2003

  - w2k8
    
    Microsoft Windows 2008

  - wvista
  
    Microsoft Windows Vista

  - win7
  
    Microsoft Windows 7

  - win8
  
    Microsoft Windows 8/2012/2012r2

  - win10
 
    Microsoft Windows 10/2016/2019

  - win11
  
    Microsoft Windows 11/2022

  - l24
  
    Linux 2.4 Kernel

  - l26
   
    Linux 2.6 - 5.X Kernel

  - solaris

     Solaris/OpenSolaris/OpenIndiania kernel

- parallel[n]: /dev/parport\d+|/dev/usb/lp\d+

  将物理主机并口设备映射给虚拟机(n的值为0-2)。
  
  注意：该属性允许虚拟机直接访问物理主机硬件。启用后将不能再进行虚拟机迁移操作，因此使用时务必小心。

  警告：该特性仍处于试验阶段，有用户报告该属性会导致故障和问题。

- protection: `<boolean>` (default = 0)

  设置虚拟机保护标识。启用后将禁止删除虚拟机或虚拟机硬盘。

- reboot: `<boolean>` (default = 1)

  允许虚拟机重启。设为0后，虚拟机重启时将自动关闭。

- rng0: `[source=]</dev/urandom|/dev/random|/dev/hwrng> [,max_bytes=<integer>] [,period=<integer>]`

  配置基于 VirtIO 的随机数生成器。
  
  - max_bytes=`<integer>` (default = 1024)

    每毫秒内允许向虚拟机内注入的最大熵字节数，使用/dev/random作为源时，首选较低的值。使用0禁用限制（可能很危险！）。

  - period=`<integer>` (default = 1000)
   
    每隔几毫秒，熵注入配额就会重置，允许来宾检索另一个max_bytes熵。

  - source=`</dev/hwrng | /dev/random | /dev/urandom>`

    主机上要从中收集熵的文件。在大多数情况下， /dev/urandom应该优先于/dev/random以避免主机上的熵饥饿问题。使用 urandom 不会以任何有意义的方式降低安全性，因为它仍然是从真实熵中播种的，并且提供的字节很可能也会与来宾上的真实熵混合。/dev/hwrng可用于从主机传递硬件 RNG。
  
- sata[n]: `[file=]<volume> [,aio=<native|threads|io_uring>] [,backup=<1|0>] [,bps=<bps>] [,bps_max_length=<seconds>] [,bps_rd=<bps>] [,bps_rd_max_length=<seconds>] [,bps_wr=<bps>] [,bps_wr_max_length=<seconds>] [,cache=<enum>] [,cyls=<integer>] [,detect_zeroes=<1|0>] [,discard=<ignore|on>] [,format=<enum>] [,heads=<integer>] [,iops=<iops>] [,iops_max=<iops>] [,iops_max_length=<seconds>] [,iops_rd=<iops>] [,iops_rd_max=<iops>] [,iops_rd_max_length=<seconds>] [,iops_wr=<iops>] [,iops_wr_max=<iops>] [,iops_wr_max_length=<seconds>] [,mbps=<mbps>] [,mbps_max=<mbps>] [,mbps_rd=<mbps>] [,mbps_rd_max=<mbps>] [,mbps_wr=<mbps>] [,mbps_wr_max=<mbps>] [,media=<cdrom|disk>] [,replicate=<1|0>] [,rerror=<ignore|report|stop>] [,secs=<integer>] [,serial=<serial>] [,shared=<1|0>] [,size=<DiskSize>] [,snapshot=<1|0>] [,ssd=<1|0>] [,trans=<none|lba|auto>] [,werror=<enum>] [,wwn=<wwn>]`

  配置SATA类型虚拟硬盘或光驱（n的值为0-5）。使用STORAGE_ID:SIZE_IN_GiB语法去分配虚拟硬盘

  - aio=`<io_uring | native | threads>`

    指定异步io模型。默认为io_uring

  - backup=`<boolean>`

    设置虚拟硬盘在进行虚拟机备份时是否被纳入备份范围。

  - bps=`<bps>`

    最大读写操作速度，单位为字节/秒。

  - bps_max_length=`<seconds>`

    突发读写操作最大时间长度，单位为秒。

  - bps_rd=`<bps>`

    最大读操作速度，单位为字节/秒。

  - bps_rd_max_length=`<seconds>`

    突发读操作最大时间长度，单位为秒。

  - bps_wr=`<bps>`
 
    最大写操作速度，单位为字节/秒

  - bps_wr_max_length=`<seconds>`

    突发写操作最大时间长度，单位为秒。

  - cache=`<directsync | none | unsafe | writeback | writethrough>`

    虚拟硬盘缓存工作模式

  - cyls=`<integer>`

    强制指定虚拟硬盘物理几何参数中的cylinder值

  - detect_zeroes=`<boolean>`

    设置是否检测并优化零写入操作。

  - discard=`<ignore | on>`

    设置是否向下层存储服务传递discard/trim操作请求。

  - file=`<volume>`

    IDE虚拟硬盘所基于的存储服务卷名称。

  - format=`<cloop | cow | qcow | qcow2 | qed | raw | vmdk>`

    IDE虚拟硬盘所采用的存储格式。

  - heads=`<integer>`

    强制指定虚拟硬盘物理几何参数中的head值。

  - iops=`<iops>`

    最大读写I/O速度，单位为个/秒。

  - iops_max=`<iops>`

    最大无限制读写I/O速度，单位为个/秒。

  - iops_max_length=`<seconds>`

    突发读写操作最大时间长度，单位为秒。

  - iops_rd=`<iops>`

    最大读I/O速度，单位为个/秒。

  - iops_rd_max=`<iops>`

    最大无限制读I/O速度，单位为个/秒。

  - iops_rd_max_length=`<seconds>`

    突发读操作最大时间长度，单位为秒。

  - iops_wr=`<iops>`
     
    最大写I/O速度，单位为个/秒。

  - iops_wr_max=`<iops>`

    最大无限制写I/O速度，单位为个/秒。

  - iops_wr_max_length=`<seconds>`

    突发读操作最大时间长度，单位为秒。

  - mbps=`<mbps>`

    最大读写操作速度，单位为MB/秒。

  - mbps_max=`<mbps>`

    最大无限制读写操作速度，单位为MB/秒。

  - mbps_rd=`<mbps>`

    最大读操作速度，单位为MB/秒。

  - mbps_rd_max=`<mbps>`

    最大无限制读操作速度，单位为MB/秒。

  - mbps_wr=`<mbps>`

    最大写操作速度，单位为MB/秒。

  - mbps_wr_max=`<mbps>`
    
    最大无限制写操作速度，单位为MB/秒。

  - media=`<cdrom | disk> `(default = disk)

    虚拟硬盘驱动器介质类型。

  - model=`<model>`

    虚拟硬盘的模型名，基于url编码格式，最大40字节。

  - replicate=`<boolean> `(default = 1)

    磁盘是否被调度复制。

  - rerror=`<ignore | report | stop>`

    读错误处理方式。

  - secs=`<integer>`

    强制指定虚拟硬盘物理几何参数中的sector值。

  - serial=`<serial>`
 
    虚拟硬盘的序列号，基于url编码格式，最大20字节。

  - shared=`<boolean> `(default = 0)

    将本地管理卷标记为所有节点均可用。
    
    注意：该选项并不自动共享卷，只是假定该卷已经被共享。

  - size=`<DiskSize>`

    虚拟硬盘容量。仅供显示使用，并不能影响实际容量大小。

  - snapshot=`<boolean>`

    Qemu快照功能控制选项。设置后，对磁盘的改写会被当成临时的，并在虚拟机重启后全部丢弃。
  
  - ssd=`<boolean>`

    设置虚拟磁盘连接到虚拟机的方式，SSD或硬盘。

  - trans=`<auto | lba | none>`

    设置虚拟硬盘几何参数地址bios解释模式。

  - werror=`<enospc | ignore | report | stop>`

    写错误处理方式。

  - wwn=`<wwn>`

    驱动器的唯一名称，使用16字节hex字符串表示，前缀为0x。

- scsi[n]: `[file=]<volume> [,aio=<native|threads|io_uring>] [,backup=<1|0>] [,bps=<bps>] [,bps_max_length=<seconds>] [,bps_rd=<bps>] [,bps_rd_max_length=<seconds>] [,bps_wr=<bps>] [,bps_wr_max_length=<seconds>] [,cache=<enum>] [,cyls=<integer>] [,detect_zeroes=<1|0>] [,discard=<ignore|on>] [,format=<enum>] [,heads=<integer>] [,iops=<iops>] [,iops_max=<iops>] [,iops_max_length=<seconds>] [,iops_rd=<iops>] [,iops_rd_max=<iops>] [,iops_rd_max_length=<seconds>] [,iops_wr=<iops>] [,iops_wr_max=<iops>] [,iops_wr_max_length=<seconds>] [,iothread=<1|0>] [,mbps=<mbps>] [,mbps_max=<mbps>] [,mbps_rd=<mbps>] [,mbps_rd_max=<mbps>] [,mbps_wr=<mbps>] [,mbps_wr_max=<mbps>] [,media=<cdrom|disk>] [,queues=<integer>] [,replicate=<1|0>] [,rerror=<ignore|report|stop>] [,ro=<1|0>] [,scsiblock=<1|0>] [,secs=<integer>] [,serial=<serial>] [,shared=<1|0>] [,size=<DiskSize>] [,snapshot=<1|0>] [,ssd=<1|0>] [,trans=<none|lba|auto>] [,werror=<enum>] [,wwn=<wwn>]`

配置SCSI类型虚拟硬盘或光驱（n的值为0-30）。使用STORAGE_ID:SIZE_IN_GiB语法去分配虚拟硬盘

  - aio=`<io_uring | native | threads>`

    指定异步io模型。默认为io_uring

  - backup=`<boolean>`

    设置虚拟硬盘在进行虚拟机备份时是否被纳入备份范围。

  - bps=`<bps>`

    最大读写操作速度，单位为字节/秒。

  - bps_max_length=`<seconds>`

    突发读写操作最大时间长度，单位为秒。

  - bps_rd=`<bps>`

    最大读操作速度，单位为字节/秒。

  - bps_rd_max_length=`<seconds>`

    突发读操作最大时间长度，单位为秒。

  - bps_wr=`<bps>`
 
    最大写操作速度，单位为字节/秒

  - bps_wr_max_length=`<seconds>`

    突发写操作最大时间长度，单位为秒。

  - cache=`<directsync | none | unsafe | writeback | writethrough>`

    虚拟硬盘缓存工作模式

  - cyls=`<integer>`

    强制指定虚拟硬盘物理几何参数中的cylinder值

  - detect_zeroes=`<boolean>`

    设置是否检测并优化零写入操作。

  - discard=`<ignore | on>`

    设置是否向下层存储服务传递discard/trim操作请求。

  - file=`<volume>`

    SCSI虚拟硬盘所基于的存储服务卷名称。

  - format=`<cloop | cow | qcow | qcow2 | qed | raw | vmdk>`

    SCSI虚拟硬盘所采用的存储格式。

  - heads=`<integer>`

    强制指定虚拟硬盘物理几何参数中的head值。

  - iops=`<iops>`

    最大读写I/O速度，单位为个/秒。

  - iops_max=`<iops>`

    最大无限制读写I/O速度，单位为个/秒。

  - iops_max_length=`<seconds>`

    突发读写操作最大时间长度，单位为秒。

  - iops_rd=`<iops>`

    最大读I/O速度，单位为个/秒。

  - iops_rd_max=`<iops>`

    最大无限制读I/O速度，单位为个/秒。

  - iops_rd_max_length=`<seconds>`

    突发读操作最大时间长度，单位为秒。

  - iops_wr=`<iops>`
     
    最大写I/O速度，单位为个/秒。

  - iops_wr_max=`<iops>`

    最大无限制写I/O速度，单位为个/秒。

  - iops_wr_max_length=`<seconds>`

    突发读操作最大时间长度，单位为秒。

  - mbps=`<mbps>`

    最大读写操作速度，单位为MB/秒。

  - mbps_max=`<mbps>`

    最大无限制读写操作速度，单位为MB/秒。

  - mbps_rd=`<mbps>`

    最大读操作速度，单位为MB/秒。

  - mbps_rd_max=`<mbps>`

    最大无限制读操作速度，单位为MB/秒。

  - mbps_wr=`<mbps>`

    最大写操作速度，单位为MB/秒。

  - mbps_wr_max=`<mbps>`
    
    最大无限制写操作速度，单位为MB/秒。

  - media=`<cdrom | disk> `(default = disk)

    虚拟硬盘驱动器介质类型。

  - model=`<model>`

    虚拟硬盘的模型名，基于url编码格式，最大40字节。

  - replicate=`<boolean> `(default = 1)

    磁盘是否被调度复制。

  - rerror=`<ignore | report | stop>`

    读错误处理方式。

  - ro=`<boolean>`

    设置磁盘只读

  - scsiblock=<boolean> (default = 0)

    是否将scsi-block用于主机块设备直通
    
    警告：在主机内存较低且内存碎片化严重时可能导致I/O错误。

  - secs=`<integer>`

    强制指定虚拟硬盘物理几何参数中的sector值。

  - serial=`<serial>`
 
    虚拟硬盘的序列号，基于url编码格式，最大20字节。

  - shared=`<boolean> `(default = 0)

    将本地管理卷标记为所有节点均可用。
    
    注意：该选项并不自动共享卷，只是假定该卷已经被共享。

  - size=`<DiskSize>`

    虚拟硬盘容量。仅供显示使用，并不能影响实际容量大小。

  - snapshot=`<boolean>`

    Qemu快照功能控制选项。设置后，对磁盘的改写会被当成临时的，并在虚拟机重启后全部丢弃。
  
  - ssd=`<boolean>`

    设置虚拟磁盘连接到虚拟机的方式，SSD或硬盘。

  - trans=`<auto | lba | none>`

    设置虚拟硬盘几何参数地址bios解释模式。

  - werror=`<enospc | ignore | report | stop>`

    写错误处理方式。

  - wwn=`<wwn>`

    驱动器的唯一名称，使用16字节hex字符串表示，前缀为0x。

- scsihw : <lsi | lsi53c810 | megasas | pvscsi | virtio-scsi-pci | virtio-scsi-single> (default = lsi )

  设置SCSI控制器类型。

- searchdomain: <string>

  Cloud-Init：为容器设置DNS搜索域。如未设置searchdomian及nameserver，将自动采用服务器主机设置创建有关配置。

- serial[n] : (/dev/.+|socket)

  在虚拟机内创建串口设备（n的值为0-3），并直通到物理服务器的串口设备（如
  /dev/ttyS0）或主机上创建的unix socket（可使用qm terminal打开终端连接）。

  注意：该属性允许虚拟机直接访问物理主机硬件。启用后将不能再进行虚拟机迁移操作，因此使用时务必小心。
  
  警告：该特性仍处于试验阶段，有用户报告该属性会导致故障和问题。

- shares : <integer> (0 -50000) (default = 1000 )

  用于auto-ballooning的共享内存容量。设置的值越大，虚拟机得到的内存越多。具体分配到的内存由当前虚拟机的权重和所有其他虚拟机权重之和的比例决定。设置为0表示禁用auto-ballooning。Pvestatd会自动执行auto-ballooning。

- smbios1 :  [base64=<1|0>] [,family=<Base64 encoded string>][，manufacturer=<Base64 encoded string>] [,product=<Base64 encoded string>] [,serial=<Base64 encoded string>] [,sku=<Base64 encoded string>] [,uuid=<UUID>] [,version=<Base64 encoded string>]

  设置SMBIOS的类型1字段。

  - base64=<boolean>

    用于设置SMBIOS是否采用base64编码的参数值。
  
  - family = <Base64 encoded string>

    设置SMBIOS1家族名称。
  
  - manufacturer = <Base64 encoded string>

    设置SMBIOS1厂商名。

  - product = <Base64 encoded string>
   
    设置SMBIOS1产品ID。

  - serial = <Base64 encoded string>

    设置SMBIOS1序列号。

  - sku = <Base64 encoded string>

    设置SMBIOS1的SKU字符串。

  - uuid = <UUID>

    设置SMBIOS1的UUID。

  - version = <Base64 encoded string>

    设置SMBIOS1版本。

- smp : <integer> (1 -N) (default = 1 )

  设置CPU数量。请使用选项-sockets代替。

- sockets : <integer> (1 -N) (default = 1 )

  设置CPU的sockets数量。

- sshkeys: <string>

  Cloud-Init：设置SSH公钥（每行设置一个key，OpenSSH格式）。

- startdate : (now | YYYY-MM-DD | YYYY-MM-DDTHH:MM:SS) (default = now )

  设置系统时钟的初始时间。日期格式示例为：now或2006-06-17T16:01:21或2006-06-17。

- startup : `[[order=]\d+] [,up=\d+] [,down=\d+] `

  开机或关机操作。参数order是一个非负整数值，用于指定虚拟机开机启动顺序。
  关机顺序和开机顺序相反。此外还可以设置开机或关机的延迟时间，也就是当前虚拟机启动或关机后下一个虚拟机开机或关机的等待时间。

- tablet : <boolean> (default = 1 )

  启用/禁用USB指针设备。该设备一般用来允许在VNC中使用鼠标的绝对坐标。
  否则鼠标将和VNC终端内的位置不同步。如果你在一台主机上运行了很多通过
  VNC终端访问的虚拟机，可以考虑禁用该参数以节省不必要的上下文切换。该项在spice终端下默认是禁用的（-vga=gxl）。

- tdf : <boolean> (default = 0 )
  
  启用/禁用时间漂移修正。

- template : <boolean> (default = 0 )

  启用/禁用模板。   

- tpmstate0： [file=]<volume> [，size=<DiskSize>] [，version=<v1.2|v2.0>]

  配置用于存储 TPM 状态的磁盘。使用特殊语法 STORAGE_ID：SIZE_IN_GiB 分配新卷。请注意，此处忽略SIZE_IN_GiB，将始终使用默认大小 4 MiB。格式也固定为原始格式。

  - file=<volume>

    TMP虚拟硬盘所基于的存储服务卷名称

  - size=<DiskSize>

    TPM虚拟硬盘容量。仅供显示使用，并不能影响实际容量大小。

  - version=<v1.2 | v2.0> (default = v2.0)

    TPM版本。v2.0是最新的，因此是首选版本。注意，设置之后无法修改。

- unused[n]: [file=]<volume>

  用于标识未使用的存储卷。该参数仅供内部使用，不要手工编辑该参数。

  - file=<volume>
   
    虚拟硬盘所基于的存储服务卷名称。

- usb[n] : [host=]<HOSTUSBDEVICE|spice> [,usb3=<1|0>]

  设置USB设备（n的值为0到4）。

  - host = <HOSTUSBDEVICE|spice>

    主机USB设备或端口或值spice。HOSTUSBDEVICE的配置语法为：’bus-port(.port) * ’ （十进制数）’vendor_id:product_id’（十六进制数）或’spice’

    可使用命令lsusb –t列出当前的usb设备。

  注意：该属性允许虚拟机直接访问物理主机硬件。启用后将不能再进行虚拟机迁移操作，因此使用时务必小心。
  
  值spice用于设置usb设备到spice的重定向。

  - usb3 = <boolean> (default = 0 )
    
    标识是否为USB3设备或端口。


- vcpus : <integer> (1 -N) (default = 0 )

  可热插拔的虚拟cpu数量。

- vga: [[type=]<enum>] [,memory=<integer>]

  设置VGA硬件。如果使用高分辨率显示器（>=1280x1024x16），应该设置更高显存。
  QEMU2.9之后，除部分Windows操作系统（XP及更旧版本）使用cirrus以外，其他操作系统默认VGA显示器类型为std。设置为qxl将启用SPICE显示服务器。对于Win系列操作系统，可以设置多个独立显示器，对于Linux系统可以自行添加显示器。也可以设置不使用图形显示卡，而使用串口设备作为终端。

  - memory=<integer> (4 - 512)
   
    设置VGA显存大小。对串口终端无效。
  
  - type=<cirrus | none | qxl | qxl2 | qxl3 | qxl4 | serial0 | serial1 | serial2 | serial3 | std | virtio| vmware> (default = std)
    
    设置VGA类型。

- virtio[n]: [file=]<volume> [,aio=<native|threads|io_uring>] [,backup=<1|0>] [,bps=<bps>] [,bps_max_length=<seconds>] [,bps_rd=<bps>] [,bps_rd_max_length=<seconds>] [,bps_wr=<bps>] [,bps_wr_max_length=<seconds>] [,cache=<enum>] [,cyls=<integer>] [,detect_zeroes=<1|0>] [,discard=<ignore|on>] [,format=<enum>] [,heads=<integer>] [,iops=<iops>] [,iops_max=<iops>] [,iops_max_length=<seconds>] [,iops_rd=<iops>] [,iops_rd_max=<iops>] [,iops_rd_max_length=<seconds>] [,iops_wr=<iops>] [,iops_wr_max=<iops>] [,iops_wr_max_length=<seconds>] [,iothread=<1|0>] [,mbps=<mbps>] [,mbps_max=<mbps>] [,mbps_rd=<mbps>] [,mbps_rd_max=<mbps>] [,mbps_wr=<mbps>] [,mbps_wr_max=<mbps>] [,media=<cdrom|disk>] [,replicate=<1|0>] [,rerror=<ignore|report|stop>] [,ro=<1|0>] [,secs=<integer>] [,serial=<serial>] [,shared=<1|0>] [,size=<DiskSize>] [,snapshot=<1|0>] [,trans=<none|lba|auto>] [,werror=<enum>]

  配置virtio类型虚拟硬盘或光驱（n的值为0-30）。使用STORAGE_ID:SIZE_IN_GiB语法去分配虚拟硬盘

  - aio=`<io_uring | native | threads>`

    指定异步io模型。默认为io_uring

  - backup=`<boolean>`

    设置虚拟硬盘在进行虚拟机备份时是否被纳入备份范围。

  - bps=`<bps>`

    最大读写操作速度，单位为字节/秒。

  - bps_max_length=`<seconds>`

    突发读写操作最大时间长度，单位为秒。

  - bps_rd=`<bps>`

    最大读操作速度，单位为字节/秒。

  - bps_rd_max_length=`<seconds>`

    突发读操作最大时间长度，单位为秒。

  - bps_wr=`<bps>`
 
    最大写操作速度，单位为字节/秒

  - bps_wr_max_length=`<seconds>`

    突发写操作最大时间长度，单位为秒。

  - cache=`<directsync | none | unsafe | writeback | writethrough>`

    虚拟硬盘缓存工作模式

  - cyls=`<integer>`

    强制指定虚拟硬盘物理几何参数中的cylinder值

  - detect_zeroes=`<boolean>`

    设置是否检测并优化零写入操作。

  - discard=`<ignore | on>`

    设置是否向下层存储服务传递discard/trim操作请求。

  - file=`<volume>`

    SCSI虚拟硬盘所基于的存储服务卷名称。

  - format=`<cloop | cow | qcow | qcow2 | qed | raw | vmdk>`

    virtio虚拟硬盘所采用的存储格式。

  - heads=`<integer>`

    强制指定虚拟硬盘物理几何参数中的head值。

  - iops=`<iops>`

    最大读写I/O速度，单位为个/秒。

  - iops_max=`<iops>`

    最大无限制读写I/O速度，单位为个/秒。

  - iops_max_length=`<seconds>`

    突发读写操作最大时间长度，单位为秒。

  - iops_rd=`<iops>`

    最大读I/O速度，单位为个/秒。

  - iops_rd_max=`<iops>`

    最大无限制读I/O速度，单位为个/秒。

  - iops_rd_max_length=`<seconds>`

    突发读操作最大时间长度，单位为秒。

  - iops_wr=`<iops>`
     
    最大写I/O速度，单位为个/秒。

  - iops_wr_max=`<iops>`

    最大无限制写I/O速度，单位为个/秒。

  - iops_wr_max_length=`<seconds>`

    突发读操作最大时间长度，单位为秒。

  - mbps=`<mbps>`

    最大读写操作速度，单位为MB/秒。

  - mbps_max=`<mbps>`

    最大无限制读写操作速度，单位为MB/秒。

  - mbps_rd=`<mbps>`

    最大读操作速度，单位为MB/秒。

  - mbps_rd_max=`<mbps>`

    最大无限制读操作速度，单位为MB/秒。

  - mbps_wr=`<mbps>`

    最大写操作速度，单位为MB/秒。

  - mbps_wr_max=`<mbps>`
    
    最大无限制写操作速度，单位为MB/秒。

  - media=`<cdrom | disk> `(default = disk)

    虚拟硬盘驱动器介质类型。

  - model=`<model>`

    虚拟硬盘的模型名，基于url编码格式，最大40字节。

  - replicate=`<boolean> `(default = 1)

    磁盘是否被调度复制。

  - rerror=`<ignore | report | stop>`

    读错误处理方式。

  - ro=`<boolean>`

    设置磁盘只读

  - secs=`<integer>`

    强制指定虚拟硬盘物理几何参数中的sector值。

  - serial=`<serial>`
 
    虚拟硬盘的序列号，基于url编码格式，最大20字节。

  - shared=`<boolean> `(default = 0)

    将本地管理卷标记为所有节点均可用。
    
    注意：该选项并不自动共享卷，只是假定该卷已经被共享。

  - size=`<DiskSize>`

    虚拟硬盘容量。仅供显示使用，并不能影响实际容量大小。

  - snapshot=`<boolean>`

    Qemu快照功能控制选项。设置后，对磁盘的改写会被当成临时的，并在虚拟机重启后全部丢弃。
  
  - ssd=`<boolean>`

    设置虚拟磁盘连接到虚拟机的方式，SSD或硬盘。

  - trans=`<auto | lba | none>`

    设置虚拟硬盘几何参数地址bios解释模式。

  - werror=`<enospc | ignore | report | stop>`

    写错误处理方式。

  - wwn=`<wwn>`

    驱动器的唯一名称，使用16字节hex字符串表示，前缀为0x。

- vmgenid: <UUID> (default = 1 (autogenerated))

  虚拟机生成ID（vmgenid）设备是一个可被客户机操作系统识别的128位整数标识符。当虚拟机配置发生改变时（例如执行快照或从模板恢复导致的变化），可凭此通知客户机操作系统。客户机操作系统接到通知后，就能做出合理响应，如将分布式数据库副本标记为脏，重新初始化随机数生成器等等。注意，手工修改配置文件并不能自动重新创建虚拟机生成ID，必须通过调用API/CLI提供的创建或更新接口才有效。

- vmstatestorage: <string>

  虚拟机状态卷/文件的默认存储。

- watchdog : [[model=]<i6300esb|ib700>] [,action=<enum>]

  创建虚拟看门狗设备。一旦启用（由虚拟机），虚拟机必须定期重置看门狗，否则虚拟机将自动重启（或执行指定的操作）。
  
  - action = <debug | none | pause | poweroff | reset | shutdown>
  
  看门狗超时后所要进行的操作。
  
  - model = <i6300esb | ib700> (default = i6300esb )
  
  虚拟看门狗类型。
