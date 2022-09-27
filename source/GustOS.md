# 第五章 在虚拟机中安装Nvidia 驱动程序

## 5.1. GRID虚拟机驱动程序版本限制与开放

Nvidia vGPU管理程序允许虚拟机使用旧版本GRID驱动，但是有一个最小的版本。

Nvidia vGPU管理程序不允许虚拟机使用比管理程序高的GRID驱动。

参考：[https://docs.nvidia.com/grid/14.0/grid-vgpu-release-notes-generic-linux-kvm/index.html#vm-old-drivers-gpu-start-failure](https://docs.nvidia.com/grid/14.0/grid-vgpu-release-notes-generic-linux-kvm/index.html#vm-old-drivers-gpu-start-failure)

## 5.2. 在Windows上安装GRID驱动程序

请先在GuestOS 中安装好远程环境，例如Vnc Server，RDP等。双击vGPU驱动程序中的Windows程序，和常规的Nvidia 驱动安装步骤相同。
请参考vGPU 软件附带的`user-guide`FDF中的`Installing the NVIDIA vGPU Software Graphics Driver on Windows`部分

## 5.3. 在Linux上安装GRID驱动程序

与Linux的NVIDIA驱动程序安装步骤类似，请参考vGPU 软件附带的`user-guide`FDF中的`Installing the NVIDIA vGPU Software Graphics Driver on Linux`部分

