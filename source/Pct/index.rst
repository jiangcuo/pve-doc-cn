
第11章 Proxmox容器管理工具
===============================

容器是完全虚拟化计算机 （VM） 的轻量级替代方案。它们使用运行它们的主机系统的内核，而不是模拟完整的操作系统 （OS）。这意味着容器可以直接访问主机系统上的资源。

容器的运行时成本很低，通常可以忽略不计。但是，需要考虑一些缺点：

- 容器内只能运行基于Linux的操作系统，比如你无法在容器内运行FreeBSD或MS Windows系统。

- 出于安全性的考虑，对主机资源的访问需要被有效控制。通常通过AppArmor，SecComp过滤器或Linux内核的其他组件来实现。这意味着在容器内无法调用一些Linux内核调用。

Proxmox VE使用Linux Containers（LXC）作为其底层容器技术。“Proxmox Container Toolkit”（pct）通过提供详细的任务界面，简化了LXC的使用和管理。

容器管理工具pct和Proxmox VE紧密集成在一起，不仅能够感知Proxmox VE集群环境，而且能够象虚拟机那样直接利用Proxmox VE的网络资源和存储资源。你甚至可以在容器上配置使用Proxmox VE防火墙和HA高可用性。

我们的主要目标是提供一个和虚拟机一样的容器运行环境，同时能避免不必要的代价。我们称之为“系统容器”，而不是“应用容器”

如果你想运行微容器（如docker），建议在KVM虚拟机中运行。这将为你提供应用程序容器化的所有功能，同时还提供VM所拥有的优势，例如与主机的强隔离和实时迁移功能，容器无法做到这一点。

.. toctree::
   :maxdepth: 2


   pcttech.md
   supportdist.md
   Container.md
   Container_Settings.md
   Security_Considerations.md
   Guest_Operating_System_Configuration.md
   Container_Storage.md
   Replication_of_Containers_mount_points.md
   Managing_Containers_with_pct.md
   Migration.md
   Configuration.md
   locks.md

