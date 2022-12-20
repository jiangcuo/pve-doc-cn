# 11.6 用户操作系统配置

我们通常会尝试检测容器中的操作系统类型，然后修改容器中的一些文件，以确保容器正常工作。以下是我们在容器启动时的例行操作清单：

- 设置/etc/hostname
  
  设置容器名称

- 修改/etc/hosts
  
  允许查找容器主机名

- 网络配置
  
  向容器传递完整的网络配置信息

- 配置DNS

  向容器传递DNS服务器配置信息

- 调整init系统初始化服务
  
  例如，修改getty进程数量

- 设置root口令
  
  创建新容器时，修改root口令

- 重新生成ssh_host_keys
  
  以确保每个容器的key都不重复

- 随机化crontab
  
  以确保各容器的cron调度任务不会同时启动


Proxmox VE会用如下注释行将修改内容标识出来

```
# --- BEGIN PVE ---
<data>
# --- END PVE ---
```

以上标识符会插入相关文件的合适位置。如果配置文件中已经有标识符，Proxmox VE会更新相关配置，并不再修改原标识符位置。

可以在配置文件相同路径下创建一个.pve-ignore文件，避免Proxmox VE修改该配置文件。例如，只要/etc/.pve-ignore.hosts文件存在，Proxmox VE就不会修改/etc/

hosts文件配置内容。用户用如下命令创建空文件即可：

```
# touch /etc/.pve-ignore.hosts
```

由于大部分配置修改都和操作系统类型相关，因此配置内容随Linux发行版和版本号改变而不同。你可以将ostype设置为unmanaged彻底禁止Proxmox VE修改配置。

OS类型检测是通过测试容器中的某些文件来完成的。Proxmox VE首先检查/etc/os-release文件[46]。如果该文件不存在，或者它不包含可明确识别的分发标识符，则检查以下特定于分发的发布文件。

- Ubuntu
  
  test/etc/lsb-release (DISTRIB_ID=Ubuntu)

- Debian
  
  test/etc/debian_version

- Fedora
  
  test/etc/fedora-release

- RedHat or CentOS
  
  test/etc/redhat-release

- ArchLinux

  test/etc/arch-release

- Alpine
  
  test/etc/alpine-release

- Gentoo
  
  test/etc/gentoo-release

- 注意

  如果配置的Ostype与自动检测的类型不同，则容器启动失败。

