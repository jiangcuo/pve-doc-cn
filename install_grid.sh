#!/bin/bash
#https://pve-doc-cn.readthedocs.io/zh_CN/pve-nvidia-vgpu/
#bash install_grid.sh unlock to install vgpu_unlock
vgpu_unlock_rs_ver="v2.0.0"
vgpu_unlock_rs_url="https://foxi.buduanwang.vip/pan/foxi/Virtualization/vGPU/vgpu_unlock/rust/libvgpu_unlock_rs_$vgpu_unlock_rs_ver.so"
vgpu_unlock_rs_conf="https://foxi.buduanwang.vip/pan/foxi/Virtualization/vGPU/vgpu_unlock/vgpu_unlock.conf"
main_kernelver=$(uname -r|cut -d "." -f1)
minor=$(uname -r|cut -d "." -f2)
if [ "$main_kernelver" -eq 5 ];then
    if [ "$minor" -ge 16 ];then
        echo "$main_kernelver.$minor is not support"
        exit 0
    elif [ "$minor" -ge 3 ];then
        nvidia_version="510.47.03"
    else
        echo "$main_kernelver.$minor is not support"
        exit 0
    fi
elif [ "$main_kernelver" -eq 4 ];then
    if [ "$minor" -lt 16 ];then
        nvidia_version="470.103.02"
    else
        echo "$main_kernelver.$minor is not support"
        exit 0
    fi
else
echo "$main_kernelver.$minor is not support"
exit 0
fi
echo  your kernel $main_kernelver.$minor match $nvidia_version

nvidia_pkg="NVIDIA-Linux-x86_64-$nvidia_version-vgpu-kvm"
nvidia_url="https://foxi.buduanwang.vip/pan/foxi/Virtualization/vGPU/$nvidia_pkg"

grub_check(){
    if [ -e /etc/kernel/proxmox-boot-uuids ]
    then
    echo "引导为Systemd-boot"
    echo "正在修改cmdline"
    edit_cmdline
    else
    echo "引导为grub"
    echo "正在修改grub"    
    edit_grub
    fi
}

modiy_modules(){
    echo "正在修改内核参数"
    cp /etc/modules /opt/foxi_backup/modules_$(date +%s)
    echo vfio >> /etc/modules
    echo vfio_iommu_type1 >> /etc/modules
    echo vfio_pci >> /etc/modules
    echo vfio_virqfd >> /etc/modules
    sed -i '/nvidia/d' /etc/modprobe.d/*
    echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf 
    echo "blacklist nvidiafb" >> /etc/modprobe.d/blacklist.conf 
    update-initramfs -u > /dev/null 2>&1
    echo "内核参数修改完成"
}

edit_cmdline(){
    cp /etc/kernel/cmdline /opt/foxi_backup/cmdline_$(date +%s)
    echo 'GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt"' > /etc/kernel/cmdline
    proxmox-boot-tool refresh > /dev/null 2>&1
    echo "cmdline修改完成"
}

edit_grub(){
    cp /etc/default/grub  /opt/foxi_backup/grub_$(date +%s)
    sed -i '/GRUB_CMDLINE_LINUX_DEFAULT/d' /etc/default/grub
    sed -i '/GRUB_CMDLINE_LINUX/i GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt"' /etc/default/grub
    update-grub > /dev/null 2>&1
    echo "grub修改完成"
}

pkg_install(){
    apt update 
    apt install dkms build-essential jq pve-headers-`uname -r` -y || apt install -f dkms build-essential jq pve-headers-`uname -r` -y
    wget -P /tmp/ http://ftp.br.debian.org/debian/pool/main/m/mdevctl/mdevctl_0.81-1_all.deb
    dpkg -i /tmp/mdevctl_0.81-1_all.deb
}


install_grid(){
    curl -L -O $nvidia_url 
    sh $nvidia_pkg.run --dkms -z -s 
    rm $nvidia_pkg.run
}
install_unlock(){
    curl -L -O $nvidia_url.run
    curl -L -O $nvidia_url.patch
    sh $nvidia_pkg.run  --apply-patch $nvidia_pkg.patch
    sh $nvidia_pkg-custom.run  --dkms -z -s 
    rm $nvidia_pkg.run $nvidia_pkg.patch $nvidia_pkg-custom.run
}

vgpu_unlock(){
    mkdir /etc/systemd/system/nvidia-vgpud.service.d/
    mkdir /etc/systemd/system/nvidia-vgpu-mgr.service.d/
    mkdir /usr/share/vgpu_unlock_rs/
    wget -P /tmp $vgpu_unlock_rs_url
    wget -P /tmp $vgpu_unlock_rs_conf
    cp /tmp/libvgpu_unlock_rs_$vgpu_unlock_rs_ver.so /usr/share/vgpu_unlock_rs/libvgpu_unlock_rs.so
    cp /tmp/vgpu_unlock.conf /etc/systemd/system/nvidia-vgpud.service.d/
    cp /tmp/vgpu_unlock.conf /etc/systemd/system/nvidia-vgpu-mgr.service.d/
    systemctl daemon-reload
    systemctl enable nvidia-vgpu-mgr.service 
    systemctl enable nvidia-vgpud.service 
    systemctl start nvidia-vgpud.service
    systemctl start nvidia-vgpu-mgr.service
}


echo "这是一个自动配置Nvidia-vGPU的脚本"
echo "本脚本不检测硬件类型，请自己确保符合条件"

read -p "请按y/Y继续" configure
if [ "$configure" = "y" ] || [ "$configure" = "Y" ] 
then
echo "开始检测引导类型"
mkdir /opt/foxi_backup > /dev/null 2>&1
grub_check
else
echo "输入错误，脚本退出"
exit 0
fi
modiy_modules
pkg_install

if  [ "$1" = "unlock" ];then
install_unlock
vgpu_unlock
echo "vgpu_unlock done"
else
install_grid
fi


echo "脚本执行完成，请重启"
echo "其中grub和modules文件已经备份到/opt/foxi_backup目录下"
echo "重启之后，请运行命令 lsmod|grep nvidia 有输出即代表成功"
