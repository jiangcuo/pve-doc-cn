## 16.7 配置文件

全局配置信息保存在`/etc/vzdump.conf`。该文件采用了冒号分隔的键/值配置格式。例子如下：
```
OPTION: value
```


空行会被自动忽略，以#开头的行将按注释处理，也会被自动忽略。该文件中的配置值被用作默认配置，如在命令行中指定了新值，则默认值将被覆盖。

目前支持的选项如下：

`bwlimit : <integer> (0 -N) (default = 0 )`

I/O带宽上限（单位KB/秒）。

`compress : <0 | 1 | gzip | lzo> (default = 0 )`

备份文件压缩设置。

`dumpdir : <string>`

指定备份文件保存位置。

`exclude-path : <string>`

排除指定的文件/目录（shell全局）。

`ionice : <integer> (0 -8) (default = 7 )`

设置CFQ ionice优先级。

`lockwait : <integer> (0 -N) (default = 180 )`

等待全局锁的最长时间（单位为分钟）。

`mailnotification : <always | failure> (default = always )`

设置电子邮件通知发送时机。

`mailto : <string>`

电子邮件通知发送地址列表，分隔符为逗号。

`maxfiles : <integer> (1 -N) (default = 1 )`

保存的单一虚拟机备份文件最大数量。

`mode : <snapshot | stop | suspend> (default = snapshot )`

备份模式。

`pigz : <integer> (default = 0 )`

设置N>0时，用pigz代替gzip进行压缩。设置N=1将使用服务器一半数量的核心，设置N>1将使用N个核心。

`pool: <string>`

备份资源池中的所有虚拟机。

`prune-backups: [keep-all=<1|0>] [,keep-daily=<N>] [,keep-hourly=<N>] [,keep-last=<N>] [,keep-monthly=<N>] [,keep-weekly=<N>] [,keep-yearly=<N>] (default = keep-all=1)`

使用这些保留选项，而不是存储配置中的保留选项。

此功能，建议直接使用PBS的调度模拟器查看备份计划！

   - `keep-all=<boolean>`
  
      勾选即保留所有的历史备份，且其他选项将不可选。

   - `keep-daily=<N>`

      以天为计算度量，保留最近N天的备份。一天若有多个备份，保留最新备份。

      在上面的基础上，若天设置为3，则会保留，昨天12：00，前天12：00，大前天12:00数据
     
   - `keep-hourly=<N>`

      以小时为计算度量，保留最近4次的小时备份。

      若计划，1：00，2：00，12：00备份，小时设置为4，则保留当天，12：00，2：00，1：00。


   - `keep-last=<N>`

     保留最近N次备份。


   - `keep-monthly=<N>`
    
      以月为计算度量，保留最近N月的备份

      在上面的基础上，若月设置为3，则会保留最近3个月30或31日的12：00的备份。

   - `keep-weekly=<N>`

      以周为计算度量，保留最近N周的备份。如果一周内有多个备份，则仅保留最新的备份
  
      在上面的基础上，若周设置为3，则会保存，之前三周，每周日12：00的备份

   - `keep-yearly=<N>`

      保留过去几年的备份，如果一年有多个备份，则会保留最新的备份。



`remove : <boolean> (default = 1 )`

当备份文件数量超过maxfiles时，自动删除最老的备份文件。

`script : <string>`

启用指定的勾子脚本。

`stdexcludes : <boolean> (default = 1 )`

排除临时文件和日志数据。

`stopwait : <integer> (0 -N) (default = 10 )`

等待虚拟机停止运行的最长时间（单位为分钟）。

`storage : <string>`

指定备份文件保存位置。

`tmpdir : <string>`

指定临时文件保存位置。

`zstd: <integer> (default = 1)`

Zstd 线程数量。N=0 使用一半的可用内核，N>0 使用 N 作为线程计数。


**vzdump.conf配置示例**

```
tmpdir: /mnt/fast_local_disk
storage: my_backup_storage
mode: snapshot
bwlimit: 10000
```
