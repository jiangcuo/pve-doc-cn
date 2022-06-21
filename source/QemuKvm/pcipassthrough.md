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

## 完成配置

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
lcpci -nn
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

