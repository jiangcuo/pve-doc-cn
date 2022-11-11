第五章 集群管理
===============================

Proxmox VE集群管理工具pvecm用于创建一个由多个物理服务器节点构成的“组”。这样的一组服务器称为一个“集群”。我们使用 `Corosync Cluster Engine <http://www.corosync.org/>`_ 来确保集群通信的稳定可靠。集群没有限制节点数量。实际上，集群内的节点数量会受到主机和网络影响。现在（2021）有用户反馈了，有超过50个节点的生产集群（使用的是企业级硬件）。

使用pvecm可以创建新的集群，可以向集群新增节点，可以从集群删除节点，可以查看集群状态信息，也可以完成其他各种集群管理操作。Proxmox VE集群文件系统（pmxcfs）用于确保配置信息透明地发送到集群中所有节点，并保持一致。

以集群方式使用Proxmox VE有以下优势：

- 集中的web管理
- 多主集群架构：从任何一个节点都可以管理整个集群
- pmxcfs：以数据库驱动的文件系统保存配置文件，并通过corosync在确保所有节点的配置信息实时同步。
- 虚拟机和容器可方便地在物理服务器节点之间迁移。
- 快速部署。
- 基于集群的防火墙和HA服务。

.. toctree::
   :maxdepth: 2

   Requirements.md
   Preparing_Nodes.md
   Create_a_Cluster.md
   Adding_Nodes_to_the_Cluster.md
   Remove_a_Cluster_Node.md
   Quorum.md
   Cluster_Network.md
   Corosync_Redundancy.md
   Role_of_SSH_in_Proxmox_VE_Clusters.md
   Corosync_External_Vote_Support.md
   Corosync_Configuration.md
   Cluster_Cold_Start.md
   Guest_Migration.md
