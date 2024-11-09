# 10.9 PCI(e)直通

PCI(e)直通可以让虚拟机直接控制物理服务器的PCI硬件设备。与使用虚拟化硬件相比，这种方式的优势有低延迟，高性能以及其他功能特性（例如，任务卸载）。

主要缺点是，一旦采用直通方式，对应硬件就不能再被主机或其他虚拟机使用。

## 10.9.1通用要求

硬件直通往往需要硬件设备的支持，以下是启用该功能的前置检查项目和准备工作清单。

### 硬件设备

硬件设备需要支持IOMMU（I/O Memory Management Unit）中断重映射，这需要CPU和主板的支持。

通常，具备Intel VT-d功能的Intel硬件系统，或具备AMD-Vi功能的AMD硬件系统均可以满足要求。但这不意味着直通功能可以开箱即用，硬件设备缺陷，驱动软件不完备等因素都可能导致硬件直通无法正常工作。

一般来说，大部分硬件都可以支持该功能，但服务器级硬件一般比消费级硬件能更好支持直通功能。

可以联系硬件设备厂商，以确定你的硬件设备是否在Linux下支持直通功能。

### 配置

确定硬件支持直通功能后，还需要完成相应配置才行。

### IOMMU

首先需要在内核命令行启用IOMMU功能，见3.10.4节。命令行参数如下：

- Intel CPU
  
  Intel_iommu=on

- AMD CPU
  
  amd_iommu=on


### 内核模块

将以下内容添加到配置文件’/etc/modules‘中，确保内核加载相应模块

```
vfio
vfio_iommu_type1
vfio_pci
vfio_virqfd
```

然后还需要更新initramfs。命令行如下：

```
update-initramfs -u -k all
```

### 完成配置

配置完成后，需要重启以启用新配置。可用以下命令行查看新配置是否已启用。

```
dmesg | grep -e DMAR -e IOMMU -e AMD-Vi
```


如果显示IOMMU，Directed I/O或Interrupt Remapping已启用则表明配置已生效。具体显示内容随硬件类型而有所不同。

此外还需要确保直通硬件在独立的IOMMU组中。可用如下命令查看：

```
find /sys/kernel/iommu_groups/ -type 1
```

如硬件与其功能、根端口或PCI(e)桥在同一IOMMU组也可以正常直通，不受影响。


#### PCI(e)插槽

某些平台处理PCI(e)插槽的方式较为特别。如果发现硬件所在IOMMU组不符合直通要求，可以换个插槽试试看。


#### 不安全的中断

某些平台允许使用不安全的中断。如需启用该功能，可以在`/etc/modprobe.d/`目录下新增`.conf`配置文件，并在配置文件中增加以下内容：

```
options vfio_iommu_type1 allow_unsafe_interrupts=1
```

务必注意，启用该功能可能导致系统运行不稳定。


### GPU直通注意事项

首先，Web GUI的NoVNC和SPICE控制台都不能显示直通GPU的显存内容。

如果要通过直通GPU或vGPU显示图形输出，必须将物理显示器连接到显卡，或者通过虚拟机内的远程桌面软件（如VNC或RDP）才可以。

如果只是把GPU当做硬件加速器使用，比如运行OpenCL或CUDA程序，则不受以上所说情况影响。


## 10.9.2主机设备直通

大部分PCI(e)直通就是把整个PCI(e)卡直通，例如GPU或网卡直通。

### 主机配置

硬件设备一旦设为直通，主机将不能再使用。具体有两种配置方法：

#### 1.将设备IDs作为参数传递给vfio-pci模块

在/etc/modprobe.d/目录新增’.conf’配置文件，文件内容示例如下

`options vfio-pci ids=1234:5678,4321:8765`

其中1234:5678和4321:8765是厂商和设备IDs，具体可以执行以下命令查看获取

```
lspci -nn
```

#### 2.对主机屏蔽驱动以确保可供直通使用

在`/etc/modprobe.d/`目录新增`.conf`配置文件，文件内容示例如下

```
blacklist DRIVERNAME
```

两种方法都需要更新initramfs并重启系统确保配置生效，具体参见10.9.1节。

### 确认配置

为了确认上面的配置生效，你可以在重启之后，执行下面命令

```
    lspci -nnk
```
在输出的结果中，找到设备信息，如果有下面字段：

```
Kernel driver in use: vfio-pci
```

或者没有上面`in use`，也说明设备可以用于直通。

### 虚拟机配置


完成设备直通，还需要为虚拟机设置hostpciX参数，示例如下：

```
#qm set VMID -hostpci0 00:02.0
```

如果设备有多个功能（例如，`00:02.0`和`00:02.1`），可以用`00:02`即可将其一并直通。

另外，根据设备类型和客户机操作系统的不同，可能还需要设置一些附加参数：

- x-vga=on|off

  用于将PCI(e)设备标记为客户机的主GPU。启用该参数后，虚拟机的vga配置将被忽略。注意，某些设备不支持x-vga参数，则需要off。

- pcie=on|off

  通知Proxmox VE启用PCIe或PCI端口。某些客户机/设备组合需要启用PCIe，而不是PCI。而PCIe仅在某些q35类型的机器上可用。

- rombar=on|off

  用于设置ROM是否对客户机可见。默认为可见。某些PCI(e)设备需要设为对客户机不可见。

- Romfile=<path>
  
  用于设置设备ROM文件路径，为可选参数。该路径是相对于/usr/share/kvm/的相对路径。

#### 示例

下面的例子通过PCIe直通主GPU设备：

```
    qm set VMID -hostpci0 02:00,pcie=on,x-vga=on
```

#### 其他注意事项

为获得更好的兼容性，在直通GPU设备时，最好选择q35芯片组，并选择使用OVMF（针对虚拟机的EFI）代替SeaBIOS，选择PCIe代替PCI。注意，在使用OVMF时，同时需要准备好EFI ROM，否则还得使用SeaBIOS。


## 10.9.3 SR-IOV

另一种PCI(e)直通方法是利用设备自带的硬件虚拟化功能。当然，这需要硬件设备本身具备相应功能。

SR-IOV（Single-Root Input/Output Virtualization）技术可以支持硬件同时提供多个VF（Virtual Function）供系统使用。每个VF都可以用于不同虚拟机，不仅可以提供硬件的全部功能，而且比软件虚拟化设备性能更好，延迟更低。

目前，最常见的支持SR-IOV的设备是网卡（Network Interface Card）。能将单一物理端口虚拟化为多个VF，同时允许虚拟机调用校验卸载等等硬件特性，从而降低主机CPU负载。

### 主机配置

有两种方法可以启用硬件设备虚拟化功能VF。

#### 1.设置启用驱动程序中的相应参数
例如Intel驱动中的

```
max_vfs=4
```

该参数可以配置在/etc/modprobe.d/目录下的.conf配置文件中。（修改配置后不要忘记更新initramfs文件）

参数的具体信息和设置方法可以查看驱动程序文档。

#### 2.通过sysfs设置启用

如果设备硬件和驱动程序支持，可以在线调整VF数量。例如，可以通过以下命令在设备0000:01:00.0上启用4个VF：

```
#echo 4 > /sys/bus/pci/devices/0000:01:00.0/sriov_numvfs
```

如果需要将该配置永久生效，可以安装‘sysfsutils’软件包，并在/etc/sysfs.conf中配置相关参数，或在/etc/sysfs.d/目录下专门创建.conf配置文件也可以。

### 虚拟机配置

创建VF后，可以运行lspci命令查看相应的PCI(e)设备信息，并根据相应设备ID进行直通配置，具体步骤可参考10.9.2 节普通PCI(e)设备直通配置。

### 其他注意事项

配置SR-IOV直通，硬件平台支持是尤为重要的。有可能首先要在BIOS/EFI中设置启用相关功能，或使用特定PCI(e)端口。如有疑问，还要咨询平台厂商或查看有关手册才可以。


## 10.9.4中介设备（vGPU，GVT-g）

中介设备（mediated device）也是一种实现硬件功能和性能复用的硬件虚拟化技术，多见于GPU虚拟化配置中，如Intel GVT-g和Nvidia vGPU。

利用该技术，一个物理硬件设备可以创建多个虚拟设备，效果类似于SR-IOV。主要区别在于，中介设备不产生新的PCI(e)设备，并且只适用于虚拟机。

### 主机配置

首先，硬件卡需要支持中介设备技术。可以从厂商获取驱动以及相关配置文档。

Intel的GVG-g驱动已经集成在Linux内核，并可以在第5、6、7代Intel Core CPU直接使用，在E3 v4、E3 v5和E3 v6版本的Xeon CPU上也可以直接使用。

在Intel显卡上启用该技术，首先要确保已经加载kvmgt内核模块（例如将其写进配置文件/etc/modules），并按3.10.4节内核命令行相关内容，添加如下参数：

```
I915.enable_gvt=1
```

然后还要按10.9.1节内容更新initramfs，并重启服务器主机。

### 虚拟机配置


配置直通中介设备，只需要设置虚拟机的hostpciX参数的mdev属性即可。

具体可以通过sysfs查看所支持的硬件设备。如下例，列出0000:00:02.0下所有的设备类型：

```
#ls /sys/bus/pci/devices/0000:00:02.0/mdev_supported_types
```

每个条目都是一个目录，其中需要关注的重要文件有：

- available_instances

用于记录当前可用的实例数量，每在虚拟机中使用一个mdev，该计数都会减1。

- description

  包含该类设备的功能简短描述

- create

  是一个功能点，用于创建该类设备。如果hostpciX的mdev属性被配置启用，Proxmox VE会自动调用该功能点。

下面是针对Intel GVT-g vGPU（Intel Skylake 6700k）的配置示例：

```
qm set VMID -hostpci0 00:02.0,mdev=i915-GVTg_V5_4
```

执行以上命令后，Proxmox VE会在虚拟机启动时自动创建该设备，并在虚拟机停止时自动删除清理。

