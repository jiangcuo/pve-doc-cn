第13章 Proxmox VE 防火墙
===============================
Proxmox VE防火墙为你的IT基础设施提供了一种简单易用的防护手段。你既可以为集群内的所有主机设置防火墙策略，也可以为单个虚拟机和容器定义策略。防火墙宏，安全组，IP集和别名等特性将大大简化策略配置管理。

尽管所有的防火墙策略都保存在集群文件系统，但基于iptables的防火墙服务在每个节点都是独立运行的，从而为虚拟机提供了完全隔离的防护。这套分布式部署的防火墙较传统防火墙提供了更高的带宽。

Proxmox VE防火墙完全支持IPv4和IPv6。IPv6的支持是完全透明的，我们默认自动对两种协议通信同时进行过滤和检测。所以没有必要为IPv6专门建立并维护防火墙策略。


.. toctree::
   :maxdepth: 3


   Zones.md
   Configuration_Files.md
   Firewall_Rules.md
   Security_Groups.md
   IP_Aliases.md
   IP_Sets.md
   Services_and_Commands.md
   Default_firewall_rules.md
   Logging_of_firewall_rules.md
   Tips_and_Tricks.md
   Notes_on_IPv6.md
   Ports_used_by_Proxmox_VE.md
