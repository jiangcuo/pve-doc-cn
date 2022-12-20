第十六章  备份和恢复
===============================
备份在所有IT环境中都是一个非常重要的需求，Proxmox VE内置了一个完整的备份解决方案，能够对在任意存储服务上的任意类型虚拟机进行备份。

此外，系统管理员还可以通过mode选项在备份数据一致性和虚拟机停机时间长度之间进行取舍。

Proxmox VE目前只支持全备份 – 包括虚拟机/容器的配置以及全部数据。备份命令可以通过WebGUI或vzdump命令行工具发出。

备份存储

在进行备份前，首先要定义一个备份用存储服务。关于添加存储服务的步骤，可以参考存储服务相关章节。鉴于备份采用文件形式保存，备份用存储必须是文件级存储服务。

大部分情况下，NFS服务器是备份用存储的良好选择。备份虚拟机后，你可以进一步将相关文件保存在磁带上以用于离线归档。

调度备份

也可以调度方式执行备份操作，以便在指定的日期和时间自动备份指定节点上的虚拟机。
调度备份的配置可在WebGUI中的数据中心配置界面进行，配置的调度任务会自动保存到 `/etc/pve/jobs.cfg`文件中，该文件会被`pvescheduler`守护程序读取并执行。
备份作业由日历事件来定义计划


.. toctree::
   :maxdepth: 3

   Backup_modes.md
   Backup_File_Names.md
   Backup_File_Compression.md
   Backup_Encryption.md
   Backup_Retention.md
   Restore.md
   Configuration.md
   Hook_Scripts.md
   File_Exclusions.md
   Examples.md