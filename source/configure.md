# 第四章 配置vGPU

## 4.1. 认识vGPU的配置

截至目前2022-9-27，Nvidia共有4中vGPU配置。

下面是Nvidia 官方的介绍：

- vCS：NVIDIA 虚拟计算服务器，加速基于 KVM 的基础架构上的虚拟化 AI 计算工作负载。
- vWS： NVIDIA RTX 虚拟工作站，适用于使用图形应用程序的创意和技术专业人士的虚拟工作站。
- vPC： NVIDIA 虚拟 PC，适用于使用办公效率应用程序和多媒体的知识工作者的虚拟桌面 (VDI)。
- vApp： NVIDIA 虚拟应用程序，采用远程桌面会话主机 (RDSH) 解决方案的应用程序流。

不同的vGPU配置使用不同的许可证进行授权。若无授权，则会阶梯降低性能。更多访问：[关于 NVIDIA vGPU 软件许可 - 参考](https://www.nvidia.com/content/Control-Panel-Help/vLatest/zh-cn/mergedProjects/nvlicCHS/About_GRID_Licensing_-_Reference.htm)

## 4.2. 使用mdevctl查看vGPU配置

`mdevctl`可以查看当前系统下的mdev设备。

下面是一个安装了P40的机器的`mdevctl`的输出:
```
root@pve:~# mdevctl types
0000:06:00.0          #此处是显卡设备号
  nvidia-156          #mdev设备显示名称
    Available instances: 0      #当前可用数量
    Device API: vfio-pci 
    Name: GRID P40-2B      #mdev设备友好名称.
    Description: num_heads=4, frl_config=45, framebuffer=2048M, max_resolution=5120x2880, max_instance=12       #mdev设备描述
  nvidia-283
    Available instances: 0
    Device API: vfio-pci
    Name: GRID P40-4C      #C是vGPU配置类型,Q=vWS,C=vCS,B=vPC,A=vApps
    Description: num_heads=1, frl_config=60, framebuffer=4096M, max_resolution=4096x2160, max_instance=6
  nvidia-46
    Available instances: 20
    Device API: vfio-pci
    Name: GRID P40-1Q      #最后面的字母前代表的是现存，1=1G,4=4G
    Description: num_heads=4, frl_config=60, framebuffer=1024M, max_resolution=5120x2880, max_instance=24

  ```
参考下面链接[https://docs.nvidia.com/grid/14.0/grid-vgpu-user-guide/index.html#virtual-gpu-types-grid](https://docs.nvidia.com/grid/14.0/grid-vgpu-user-guide/index.html#virtual-gpu-types-grid)


在Proxmox VE的web面板上，我们只能看到mdev设备的显示名称，而不是友好名称，所以我们不好判断是否分配了我们想要分配的设备。如下：

![](https://foxi.buduanwang.vip/wp-content/uploads/2022/04/QQ20220428-141320.png)

所以，要分配正确的设备给虚拟机，建议先使用`mdevctl`先对应，否则分配到了错误的vGPU，可能会导致无法安装驱动或者无法授权等等。

## 4.3. vGPU分配规则

### 4.3.1 基于时间分片（Time-Sliced）

- 同一张卡上，同显存的C和Q可以同时分配。
- 同一张卡上，不能同时分配不同显存的vGPU
- 不同卡上，不同显存可以同时分配，但必须满足上一原则。

### 4.3.2 基于MIG（Sriov）

- 更加灵活

此部分参考：[https://docs.nvidia.com/grid/14.0/grid-vgpu-user-guide/index.html#valid-vgpu-configurations-one-gpu](https://docs.nvidia.com/grid/14.0/grid-vgpu-user-guide/index.html#valid-vgpu-configurations-one-gpu)


## 4.4. 将vGPU配置至Proxmox VE 虚拟机

打开虚拟的`硬件选项`，点击`添加`，选择`PCI设备`。

在`添加：PCI设备`弹窗中，在`设备`中选择物理显卡，随后会出现`MDev类型`选择框，请选择自己需要的vGPU类型。

### 4.4.1 将vGPU作为PCIe设备直通

当虚拟机机型为I440FX时，虚拟机没有PCIe通道，所以vGPU会成为一个PCI设备。

当虚拟机机型为Q35时，虚拟有PCIe通道，此时可以选择将vGPU作为PCI设备或者PCIe设备。

若要将vGPU作为PCIe设备，请点击`高级`，勾选`PCI-Express`.

### 4.4.2 主GPU选项

勾选主GPU选项时，会将`x-vga=on`参数传递给kvm，同时将取消虚拟的默认vga设备，所以虚拟机控制台此时不能使用。只能通过系统内部的VNC或者其他远程协议访问。

并不建议开启此选项。


### 4.4.3 vGPU额外配置

在PVE7.2, qemu-server软件包低于7.2-4之前，需要手动给虚拟机添加UUID，才能够启动分配了vGPU的虚拟机。

否则会出现如下错误

```
vfio 00000000-0000-0000-0000-000000000102: failed to get region 0 info: Input/output error
TASK ERROR: start failed: QEMU exited with code 1
```


方法1:

```
添加下面行到虚拟机conf中

args: -uuid 00000000-0000-0000-0000-000000000100
注意的是，uuid最后的值需要改成你的vmid。如果你的vmid为3333，那么你应该改成

args: -uuid 00000000-0000-0000-0000-000000003333

如果你的vmid是121，那么你应该改成

args: -uuid 00000000-0000-0000-0000-000000000121

注意，uuid的长度和格式是不能变的，根据自己的vmid，替换尾数。
```

方法2：

升级到qemu-server=7.2-4

方法3：

参考qemu-server=7.2-4中对nvidia vgpu的支持，修改源文件

[https://git.proxmox.com/?p=qemu-server.git;a=commitdiff;h=bbf96e0f1ea0977c1b37e1ae3bbd9a9aed900c26](https://git.proxmox.com/?p=qemu-server.git;a=commitdiff;h=bbf96e0f1ea0977c1b37e1ae3bbd9a9aed900c26)

