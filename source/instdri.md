# 第三章 安装Nvidia vGPU驱动

## 3.1. 下载Nvidia vGPU驱动

Proxmox VE作为KVM平台。自然需要下载KVM版本的驱动。

Nvidia vGPU驱动和Proxmox VE平台的兼容性（在未使用patch得情况下，直接能够安装好驱动，判定为兼容）

| PVE版本 | 内核版本 | grid9 | grid10 | grid11.2 | grid12.2 | grid13.2 | grid14.2 |
|-------|------|-------|--------|----------|----------|----------|----------|
|  pve5 | 4.10 | x     | x      | √        | √        | √        |          |
| pve5  | 4.13 | x     | x      | √        | √        | √        |          |
| pve5  | 4.15 | x     | x      | √        | √        | √        |          |
| pve6  | 5.4  | x     | x      | √        | √        | √        | √        |
| pve6  | 5.11 | x     | x      | x        | x        | √        | √        |
| pve7  | 5.13 | x     | x      | x        | x        | √        | √        |
| pve7  | 5.15 | x     | x      | x        | x        | √        | √        |
| pve7  | 5.19 | x     | x      | x        | x        | x        | x        |

可以前往Nvidia官网下载驱动，也可以去下面下载。

https://foxi.buduanwang.vip/pan/foxi/Virtualization/vGPU/

## 3.2 安装Nvidia vGPU驱动

这里以460.73.01为例

给驱动添加可执行权限

`chmod +x /opt/NVIDIA-Linux-x86_64-460.73.01-grid-vgpu-kvm.run`

以dkms方式安装驱动

`sh -c /opt/NVIDIA-Linux-x86_64--grid-vgpu-kvm.run `

运行命令后，会提示是否用dkms方式安装，选择yes，回车继续

![dkms安装驱动](https://foxi.buduanwang.vip/wp-content/uploads/2022/04/QQ20220426-164428.png)

出现xorg告警，忽略

![忽略xorg](https://foxi.buduanwang.vip/wp-content/uploads/2022/04/QQ20220426-164609.png)

询问是否启用32位兼容库。这里可选可不选

![](https://foxi.buduanwang.vip/wp-content/uploads/2022/04/QQ20220426-164649.png)

开始安装驱动

![安装驱动](https://foxi.buduanwang.vip/wp-content/uploads/2022/04/QQ20220426-164746.png)

进度条走完就ok，可能会有点时间。

![](https://foxi.buduanwang.vip/wp-content/uploads/2022/04/QQ20220426-164816.png)

成功之后，可以执行`dkms status`查看

```
root@pve:~# dkms status
nvidia, 460.73.01, 5.4.203-1-pve, x86_64: installed
```

## 3.3 升级或者降级内核

升级或者降级内核务必参考上表的兼容性，否则可能会导致驱动和内核不兼容，使设备无法驱动。

dkms的优势就是动态安装内核模块，升降内核自动触发模块编译，十分方便。

注意的是，dkms需要内核的header，所以当你准备升级或者降级内核的时候，务必安装header，否则dkms会无法编译模块。

例如安装5.11内核

```
apt install -y pve-kernel-5.11.22-5-pve pve-headers-5.11.22-5-pve
```

若内核升级降级之前，忘记安装headers，可以在新内核启动之后，手动安装header

```
pve-headers-`uname -r`
```

再执行dkms 安装

```
dkms install -m nvidia -v <YOUR_VERSION>
```

