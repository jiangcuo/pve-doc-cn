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

- acpi : <boolean> (default = 1 )
  
  启用/禁用 ACPI。

- agent: [enabled=]<1|0> [,fstrim_cloned_disks=<1|0>]

  启用/禁用Qemu GuestAgent及其属性。

- enabled=<boolean> (default = 0)

  启用/禁用Qemu GuestAgent。

- fstrim_cloned_disks=<boolean> (default = 0)

  在克隆/迁移虚拟磁盘后运行fstrim。

- arch: <aarch64 | x86_64>

  虚拟CPU架构。默认为host。

- args : <string>

  传递给kvm的任意参数，例如：
  
  ```
  args: -no-reboot -no-hpet
  ```

  注意:args仅供专家使用。

- audio0: device=<ich9-intel-hda|intel-hda|AC97> [,driver=<spice|none>]
 
  配置虚拟声卡，与Spice/QXL配合很有用。

  device=<ich9-intel-hda|intel-hda|AC97> 选择声卡的类型

  driver=<none | spice> (default = spice) 选择声卡的后端驱动，默认为spice


- autostart : <boolean> (default = 0 )

  虚拟机崩溃后自动启动（目前该属性会被自动忽略）

- balloon : <integer> (0 -N)

  为虚拟机配置的目标内存容量，单位为MB。设为0表示禁用ballon驱动程序。
  
- bios : <ovmf | seabios> (default = seabios )

  设置BIOS类型。

- boot: [[legacy=]<[acdn]{1,4}>] [,order=<device[;device...]>]

  legacy=<[acdn]{1，4}> （default = cdn)，虚拟机启动顺序，软驱（a），硬盘（c），光驱（d），或网络（n）。现已弃用，请改用`order`

  order=<device[;d evice...]>,虚拟机将按照此规则进行启动。磁盘、光驱和直通存储USB设备将直接从中启动，NIC将加载PXE，PCIe设备如果是磁盘（Nvme）就会启动或加载OPTION ROM（例如RAID控制器、硬件NIC）。

  注意，只有在这里被标记成可启动设备，才能由虚拟机的（BIOS/UEFI）加载。如果您需要多个磁盘进行引导（例如software-raid），则需要在此处指定所有磁盘。
  
  使用order将会忽略legacy的值

- bootdisk: (ide|sata|scsi|virtio)\d+
 
  指定启动磁盘，已经弃用，请使用 `boot: order=xx`

- cdrom:<volume>

  光驱，相当于-ide2的别名。

- cicustom: [meta=<volume>] [,network=<volume>] [,user=<volume>] [,vendor=<volume>]

  使用指定文件代替自动生成文件。

 - meta=<volume>，将包含所有元数据的指定文件通过cloud-init传递给虚拟机。该文件提供指定configdrive2和nocluod信息。

 - network=<volume>，将包含所有网络配置数据的指定文件通过cloud-init传递给虚拟机。

 - user=<volume> ，将包含所有用户配置数据的指定文件通过cloud-init传递给虚拟机。