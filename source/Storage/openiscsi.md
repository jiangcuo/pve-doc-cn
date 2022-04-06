## 7.13基于Open-iSCSI的后端存储

存储池类型：iscsi

iSCSI是一种广泛应用于服务器和存储设备之间连接的协议。几乎所有的存储厂商都有兼容iSCSI的设备。目前也有多种开源的iSCSI target解决方案，例如基于Debian系统的OpenMeidaVault。

你需要先手工安装open-iscsi软件包才可以使用基于Open-iSCSI的后端存储服务。Proxmox VE默认不安装该Debian软件包。
```
apt-get install open-iscsi
```

底层的iscsi管理任务可以通过iscsiadm命令完成。

## 7.13.1配置方法

Open-iSCSI后端存储支持公共存储服务属性content、nodes、disable，以及如下的iSCSI特有属性：

- portal
用于设置iSCSI Portal（可设置为IP地址或DNS域名）。
- target
用于设置iSCSI target。

配置示例（`/etc/pve/storage.cfg`）

```
iscsi: mynas
     portal 10.10.10.1
     target iqn.2006-01.openfiler.com:tsn.dcb5aaaddd
content none
```


提示:

如果需要在iSCSI上创建LVM存储服务，最好启用content none。这样就防止直接在iSCSI LUN上创建虚拟机镜像。

## 7.13.2文件命名规范

iSCSI协议本身未定义分配空间或删除数据的接口，而是将这部分工作交由各存储厂商自行实现。一般情况下，iSCSI上分配的存储卷都以LUN序号的形式输出，所以Proxmox VE就以Linux内核获取的LUN信息命名iSCSI存储卷。


## 7.13.3存储功能
iSCSI属于块存储解决方案，但并未提供任何管理接口。所以，最佳时间是配置并输出一个很大的iSCSI LUN，然后再配置创建LVM进行管理。你可以使用Proxmox VE的LVM插件直接管理iSCSI LUN的存储空间。

表 12.后端 iscsi 的存储功能

|数据类型 |镜像格式 |支持共享| 支持快照 |支持链接克隆|
|-----|-----|-----|----|-----|
|虚拟机镜像 容器镜像 |RAW |是|否|否|

## 7.13.4示例	

以下命令用于扫描远端的iSCSI portal，并列出可用的target：

```
pvesm iscsiscan -portal <HOST[:PORT]>
```