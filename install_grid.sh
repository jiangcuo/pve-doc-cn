#!/bin/bash
#https://pve-doc-cn.readthedocs.io/zh_CN/pve-nvidia-vgpu/
#bash `install_grid.sh unlock` to install vgpu_unlock
nvidia_version=""
vgpu_unlock_rs_ver="v2.3.1"
vgpu_unlock_rs_url="https://foxi.buduanwang.vip/pan/vGPU/vgpu_unlock/rust/libvgpu_unlock_rs_$vgpu_unlock_rs_ver.so"
vgpu_unlock_rs_conf="https://foxi.buduanwang.vip/pan/vGPU/vgpu_unlock/vgpu_unlock.conf"
main_kernelver=$(uname -r|cut -d "." -f1)
minor=$(uname -r|cut -d "." -f2)

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
    echo 'root=ZFS=rpool/ROOT/pve-1 boot=zfs intel_iommu=on iommu=pt' > /etc/kernel/cmdline
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

install_grid(){
    curl -L -O $nvidia_url  || error_log "nvidia driver download failed!"
    sh $nvidia_pkg --dkms -q -s -z --no-x-check || error_log "nvidia driver install failed!"
    rm $nvidia_pkg
}

vgpu_unlock(){
    mkdir /etc/systemd/system/nvidia-vgpud.service.d/ -p
    mkdir /etc/systemd/system/nvidia-vgpu-mgr.service.d/ -p 
    mkdir /usr/share/vgpu_unlock_rs/ -p
    wget -P /tmp $vgpu_unlock_rs_url ||  error_log "vgpu unlock rust file download failed!"
    wget -P /tmp $vgpu_unlock_rs_conf || error_log "vgpu unlock rust config download failed!"
    cp /tmp/libvgpu_unlock_rs_$vgpu_unlock_rs_ver.so /usr/share/vgpu_unlock_rs/libvgpu_unlock_rs.so
    cp /tmp/vgpu_unlock.conf /etc/systemd/system/nvidia-vgpud.service.d/
    cp /tmp/vgpu_unlock.conf /etc/systemd/system/nvidia-vgpu-mgr.service.d/
    systemctl daemon-reload
    systemctl enable nvidia-vgpu-mgr.service 
    systemctl enable nvidia-vgpud.service 
    systemctl start nvidia-vgpud.service
    systemctl start nvidia-vgpu-mgr.service
}

error_log(){
    echo $1
    exit 1;
}


install_pkg(){
    apt update && apt install -y build-* mdevctl dkms pve-headers-`uname -r` || error_log "install pkg failed"
}


if [ ! -n "$nvidia_version" ];then
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
    elif [ "$main_kernelver" -eq 6 ];then
        if [ "$minor" -ge 1 ];then
            nvidia_version="535.129.03"
        else
            echo "$main_kernelver.$minor is not support"
            exit 0
        fi
    else
        echo "$main_kernelver.$minor is not support"
        exit 0
    fi
fi

echo  your kernel $main_kernelver.$minor match $nvidia_version

nvidia_pkg="NVIDIA-Linux-x86_64-$nvidia_version-vgpu-kvm-custom.run"
nvidia_url="https://foxi.buduanwang.vip/pan/vGPU/vgpu_unlock/drivers/$nvidia_pkg"

echo "这是一个自动配置Nvidia-vGPU的脚本"
echo "本脚本不检测硬件类型，请自己确保符合条件"

read -p "请按y/Y继续" configure
if [ "$configure" = "y" ] || [ "$configure" = "Y" ] 
then
install_pkg
echo "开始检测引导类型"
mkdir /opt/foxi_backup > /dev/null 2>&1
grub_check
else
echo "输入错误，脚本退出"
exit 0
fi
modiy_modules
install_grid
vgpu_unlock

echo "脚本执行完成，请重启"
echo "其中grub和modules文件已经备份到/opt/foxi_backup目录下"
echo "重启之后，请运行命令 lsmod|grep nvidia 有输出即代表成功"
