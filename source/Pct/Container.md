# 容器映像

容器镜像（有时也称为“模板”或“应用程序”）是包含运行容器的所有内容的tar包。

Proxmox VE本身为最常见的Linux发行版提供了多种基本模板。可以使用 GUI 或 pveam（Proxmox VE Appliance Manager 的缩写）命令行实用程序下载它们。此外，还提供 TurnKey Linux 容器模板下载。

可用模板的列表通过 pve-daily-update 计时器每天更新。您还可以通过执行以下命令手动触发更新：

```
pveam update
```

要查看可用映像的列表，请运行：

```
 pveam available
```
 
该列表包含了很多镜像，你可以指定查看感兴趣的小节，例如可以指定查看系统镜像：

列出可用镜像

```
pveam available --section system
system          alpine-3.12-default_20200823_amd64.tar.xz
system          alpine-3.13-default_20210419_amd64.tar.xz
system          alpine-3.14-default_20210623_amd64.tar.xz
system          archlinux-base_20210420-1_amd64.tar.gz
system          centos-7-default_20190926_amd64.tar.xz
system          centos-8-default_20201210_amd64.tar.xz
system          debian-9.0-standard_9.7-1_amd64.tar.gz
system          debian-10-standard_10.7-1_amd64.tar.gz
system          devuan-3.0-standard_3.0_amd64.tar.gz
system          fedora-33-default_20201115_amd64.tar.xz
system          fedora-34-default_20210427_amd64.tar.xz
system          gentoo-current-default_20200310_amd64.tar.xz
system          opensuse-15.2-default_20200824_amd64.tar.xz
system          ubuntu-16.04-standard_16.04.5-1_amd64.tar.gz
system          ubuntu-18.04-standard_18.04.1-1_amd64.tar.gz
system          ubuntu-20.04-standard_20.04-1_amd64.tar.gz
system          ubuntu-20.10-standard_20.10-1_amd64.tar.gz
system          ubuntu-21.04-standard_21.04-1_amd64.tar.gz
```

在使用此类模板之前，需要将它们下载到其中一个存储上。如果不确定是哪一个，可以local存储。对于群集环境，最好使用共享存储，以便所有节点都能访问这些镜像。

```
pveam download local debian-10.0-standard_10.0-1_amd64.tar.gz
```

现在，你已准备好使用该映像创建容器，并且可以在本地存储上列出所有下载的映像，如下所示：

```
pveam list local
local:vztmpl/debian-10.0-standard_10.0-1_amd64.tar.gz  219.95MB
```

提示:您还可以使用Proxmox VE Web界面GUI下载，列出和删除容器模板。

pct使用它们来创建新容器，例如：

```
 pct create 999 local:vztmpl/debian-10.0-standard_10.0-1_amd64.tar.gz
```

上述命令显示完整的 Proxmox VE 卷标识符。它们包括存储名称，大多数其他 Proxmox VE 命令都可以使用它们。例如，您可以稍后通过以下方式删除该图像：

```
 pveam remove local:vztmpl/debian-10.0-standard_10.0-1_amd64.tar.gz
 ```

