# 3.5.外部监控服务器
在Proxmox VE中，您可以定义外部监控服务器，这些服务器将定期接收有关主机，虚拟来宾和存储的各种统计信息。

当前支持的有如下两种：
- Graphite （参考 https://graphiteapp.org）
- InfluxDB  （参考 https://www.influxdata.com/time-series-platform/influxdb/ ）

外部监控服务器配置保存在`/etc/pve/status.cfg`中，并且可以通过 Web 界面进行编辑。

## 3.5.1. Graphite 服务器配置
默认端口设置为 2003，默认Graphite的路径为proxmox。
默认情况下，Proxmox VE 通过 UDP 发送数据，因此必须将Graphite服务器配置为接受此参数。在这里，可以根据实际情况配置，而无需采用默认的 1500 MTU 。

您也可以配置插件使用TCP。为了不阻塞`pvestatd`统计收集守护进程，需要一个超时来处理网络问题。


## 3.5.2. Influxdb 配置
Proxmox VE服务器使用udp协议发送监控数据，所以influxdb服务器需要进行相应配置。也可以在这里配置mtu
下面是一个influxdb配置示例（配置在influxdb服务器上）：
```
[[udp]]
   enabled = true
   bind-address = "0.0.0.0:8089"
   database = "proxmox"
   batch-size = 1000
   batch-timeout = "1s"
```
使用此配置，您的服务器将侦听端口 8089 上的所有 IP 地址，并将数据写入 proxmox 数据库中。




