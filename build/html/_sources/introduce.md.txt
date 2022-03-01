# 第一章 认识vGPU
要为VM提供图形引擎，一般分为3种。
- 软件模拟图形-性能差
- 显卡直通-性能最好，一个虚拟机独享一个显卡
- vGPU-性能好，多个虚拟机共享一个显卡

在市面上主要有如下3种vGPU解决方案。

|intel|amd|nvidia|
|----|-----|----|
|GVT-g|MxGPU|Nvidia vGPU|

本文主要介绍Nvdia vGPU

## 1.1. Nvidia vGPU架构

下图为Nvidia vGPU系统架构
![Nvidia vGPU架构](https://docs.nvidia.com/grid/13.0/common/graphics/architecture-grid-vgpu-overview.png)

从上图中可以看到在Hypervisor的硬件上存在Nvidia物理上的GPU，软件上存在Nvidia vGPU管理器。

那么不难看出，要实现Nvidia vGPU不仅要物理GPU，还需要相应的管理程序。

## 1.2. Nvidia vGPU支持的显卡
具体型号请参考下面链接
[https://docs.nvidia.com/grid/13.0/product-support-matrix/index.html](https://docs.nvidia.com/grid/13.0/product-support-matrix/index.html)

大致如下
- A10
- A16
- A30
- A40, A10
- M6, M10, M60
- P4, P6, P40, P100, P100 12GB
- T4
- V100
- RTX A5000
- RTX A6000
- RTX 6000, RTX 6000 passive, RTX 8000, RTX 8000 passive

## 1.3. Nvidia vGPU支持的系统

不同的Hypervisor和不同的驱动软件对系统的支持性不一样。完整的兼容性，请参考对应的Grid文档

那么笔者归纳大致有如下：
- ubuntu
- redhat
- Windows
- SUSE 

## 1.4. 获取Nvidia vGPU软件和支持

请前往Nvidia 官网获取软件和支持。

