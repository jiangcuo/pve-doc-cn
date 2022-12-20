# 8.2初始化Ceph安装和配置

## 8.2.1. 使用基于 Web 的向导

Proxmox VE提供了简单易用的Ceph安装向导。选中集群中的一个节点，然后在菜单树中打开Ceph菜单区，您将看到一个提示您这样做的提示。

![](https://pve.proxmox.com/pve-docs/images/screenshot/gui-node-ceph-install.png "pve ceph")

安装向导有多个步骤，每个步骤都需要执行成功才可以完成Ceph安装。

首先，您需要选择要安装的 Ceph 版本。首选其他节点中的一个。如果这是您安装 Ceph 的第一个节点，则选择最新的。

![](https://pve.proxmox.com/pve-docs/images/screenshot/gui-node-ceph-install-wizard-step0.png)


开始安装操作后，向导会自动从Proxmox VE的ceph软件源下载软件包并完成安装。

完成安装步骤后，还需要创建配置。对每个集群，生成的配置信息会通过第7章所述Proxmox VE集群文件系统（pmxcfs）自动分发到其他节点，所以该操作只需要执行一次即可。

创建的配置包括以下信息：

- Public Network 

为避免影响集群通信等其他对网络延迟敏感的服务，也为了提高Ceph性能，强烈建议为Ceph准备一个专门的独立网络，将Ceph流量隔离开来。

- Cluster Network

进一步，还可以设置Cluster Network，将OSD复制和心跳流量隔离出来。这将有效降低public network的负载，并有效改善大规模Ceph集群的性能。


以下两个参数项属于高级配置功能，仅供专家级用户使用。

- Number of replicas

设置副本数量。

- Mininum replicas

设置最小副本数量，副本数低于该阀值时，数据将会被标记为不完全状态。

此外，还需要选择第一个监视器节点（必须）。

所有配置完成后，系统会提示配置成功，并给出下一步安装指令。

此时系统现在已准备好开始使用Ceph。首先需要创建一些额外的监视器、 OSD和一个池。

本章的其余部分将指导您充分利用基于 Proxmox VE 的 Ceph 设置。这包括前面提到的技巧和更多内容，例如CephFS，它对您的新 Ceph 集群很有帮助。

## 通过CLI安装Ceph

除了在Web界面上使用推荐的Proxmox VE Ceph安装向导之外，您还可以在每个节点上使用以下 CLI 命令：

`pveceph install`

该命令将创建apt软件源/etc/apt/sources.list.d/ceph.list，并安装所需软件。


## 8.2.3. 通过 CLI 进行初始 Ceph 配置

使用 Proxmox VE Ceph 安装向导（推荐）或在一个节点上运行以下命令：

`pveceph init –network 10.10.10.0/24`

该命令将创建为ceph创建一个专用网络，并将初始配置写入文件/etc/pve/ceph.conf。

该文件将通过第6章介绍的pmxcfs自动分发到所有Proxmox VE服务器节点。该命令还将创建符号链接/etc/ceph/ceph.conf指向该配置文件，以便直接运行Ceph命令，无需另外创建配置文件。


