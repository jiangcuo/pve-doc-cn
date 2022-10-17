# 18.1. pvesubscription – 订阅管理工具

Promxox VE订阅管理工具。

# 18.2 pveperf – Proxmox性能测试脚本

用于收集CPU/硬盘性能数据的工具。硬盘可用对应的文件系统路径PATH指定（默认为/）：
- CPU BOGOMIPS
所有CPU的bogomips总和。
- REGEX/SECOND
每秒正则表达式（perl性能测试）测试结果。应大于300000。
- HD SIZE
硬盘容量。
- BUFFERED READS
简单硬盘读测试。主流硬盘至少应达到40MB/秒。
- AVERAGE SEEK TIME
平均寻道时间测试。快速SCSI硬盘应<8毫秒。一般IDE/SATA硬盘应在15-20毫秒。
- FSYNCS/SECOND
该测试值应高于200（如使用RAID卡，在具备后备电池缓存时，应启用writeback缓存模式）。
- DNS EXT
解析外部DNS域名的平均时间。
- DNS INT
解析本地DNS域名的平均时间。

# 18.3 Proxmox VE API的命令行工具
Proxmox VE管理工具（pvesh）可以直接调用API函数，无需通过REST/HTTPS服务器。

注意:只有root用户有此权限。

## 18.3.1示例

显示集群节点列表
```
pvesh get /nodes
```

显示数据中心可用选项

```
pvesh usage cluster/options -v
```
将HTML5 NoVNC控制台设置为数据中心默认控制台

```
pvesh set cluster/options -console html5
```