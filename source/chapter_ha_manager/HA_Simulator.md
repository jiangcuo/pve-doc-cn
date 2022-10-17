# HA 模拟器

![hamoniq](https://pve.proxmox.com/pve-docs/images/screenshot/gui-ha-manager-status.png)

通过HA仿真器，用户可以了解并测试Proxmox VE HA解决方案的所有功能。

默认情况下，可以通过HA仿真器测试带有6个虚拟机的3节点集群环境。用户还可以根据需要增加删除虚拟机或容器。

用户并不需要真的安装配置一个真实的集群环境。HA仿真器是开箱即用的。

只需要运行apt命令如下：

```
apt install pve-ha-simulator

```

用户甚至可以直接在Debian系统上运行该命令安装HA仿真器，而无需安装其他任何Proxmox VE软件包。只需下载软件包，然后复制到目标系统即可安装。如果使用apt命令在本地系统安装，依赖软件包将被自动安装。

如需通过远程启动HA仿真器，必须预先在本地操作系统配置好X11重定向。

如果你使用的是Linux操作系统，可以运行以下命令：


```
ssh root@<IPofPVE> -Y
```

如果使用的windows操作系统，可以尝试使用mobaxterm软件。

不管是在Proxmox VE服务器还是在Debian系统安装了HA仿真器后，都可以按以下步骤启动。

首先要为HA仿真器创建一个工作目录，以便保存当前状态并写入默认配置：
```
mkdir working

```
然后将创建的目录路径作为参数传递给pve-ha-simulator命令：
```
pve-ha-simulator working/
```
接下来就可以尝试启动、停止、迁移仿真HA服务，或检查节点故障时的现象。
