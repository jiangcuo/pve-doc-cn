# 6.1. POSIX 兼容性

Pmxcfs 基于 FUSE 技术，其实现类似于 POSIX。但我们仅实现了必须的功能，因此 POSIX 标
准中的部分功能并未实现。
- 仅支持普通文件和目录，不支持符号链接。
- 不能重命名非空目录（以便于确保虚拟机 ID 的独一性）。
- 不能修改文件权限（文件权限基于路径确定）。
- O_EXCL 创建不是原子操作（类似老的 NFS）。
- O_TRUNC 创建不是原子操作（FUSE 的限制）

# 6.2. 文件访问权限
所有的文件和目录都属于root用户和www-data用户组。只有root用户有写权限，www-data
用户组对大部分文件有读权限。以下路径的文件只有 root 有权访问。

- /etc/pve/priv/
- /etc/pve/nodes/${NAME}/priv