# 15.1. 部署条件

在开始部署HA之前，需要满足以下条件：

- 集群最少有3个节点（以得到稳定的quorum）
- 为虚拟机和容器配置共享存储
- 硬件冗余（各个层面）
- 使用可靠的“服务器”硬件
- 硬件看门狗 - 如不具备，也可以退而求其次使用Linux内核的软件看门狗（softdog）
- 可选的硬件隔离设备

