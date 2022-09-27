# 第二章 准备Nvidia vGPU驱动环境

## 2.1 安装必要的软件源

修改`/etc/apt/sources.list`使其如下：

pve6
```
#使用清华源
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ buster main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ buster-updates main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ buster-backports main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian-security buster/updates main contrib non-free
#清华pve源镜像
deb https://mirrors.tuna.tsinghua.edu.cn/proxmox/debian buster pve-no-subscription
```

pve7
```
#使用清华源
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-updates main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-backports main contrib non-free
deb https://mirrors.tuna.tsinghua.edu.cn/debian-security bullseye/updates main contrib non-free
#清华pve源镜像
deb https://mirrors.tuna.tsinghua.edu.cn/proxmox/debian bullseye pve-no-subscription
```


## 2.2 调整相关内核参数

禁用`nouveau` 驱动,使Nvidia显卡不被其占用，从而能够顺利安装Nvidia vGPU驱动。

```
echo  "blacklist nouveau" >>/etc/modprobe.d/disable-nouveau.conf
echo  "options nouveau modeset=0" >>/etc/modprobe.d/disable-nouveau.conf
```

*提示：如果当前主机不方便重启，可以解绑`nouveau`模块。*

```
cd /sys/bus/pci/drivers/nouveau
ls  #查看你的PCIe设备号
echo 0000:xxxxxxxxxxxxx > unbind  #将000xx替换成PCIe设备号
```


允许不安全中断
```
echo "options vfio_iommu_type1 allow_unsafe_interrupts=1" >/etc/modprobe.d/iommu_unsafe_interrupts.conf
echo "options kvm ignore_msrs=1" > /etc/modprobe.d/kvm.conf
```

配置好之后，需要更新内核以应用内核参数。
`update-initramfs -k all -u`

## 2.3 开启iommu
编辑`/etc/default/grub`，在cmdline中添加iommu参数
如下
```
#intel_cpu
GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on"

#amd_cpu
GRUB_CMDLINE_LINUX_DEFAULT="quiet amd_iommu=on"
```

最后使用`update-grub`更新系统引导。

注意：

如果使用`Systemd-boot`引导的系统，应该编辑 `/etc/kernel/cmdline`文件。
使用`proxmox-boot-tool refresh`更新系统引导。

## 2.4 安装依赖

安装`dkms`和`pve-headers`，用于安装驱动。`jq`和`uuid-runtime`用于配合`mdevctl`管理Nvidia vGPU设备。
```
apt install dkms build-essential pve-headers pve-headers-`uname -r` dkms jq uuid-runtime -y

```

安装`mdevctl`
```
curl http://ftp.br.debian.org/debian/pool/main/m/mdevctl/mdevctl_0.81-1_all.deb -o /tmp/mdevctl.deb && dpkg -i /tmp/mdevctl.deb
```




