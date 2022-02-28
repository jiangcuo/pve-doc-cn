# 3.1软件源
Proxmox VE像其他debian发行版一样，使用APT作为软件包管理器。

## 3.1.1. Proxmox VE的软件仓库
软件仓库收集了大量的软件，他们可以用来安装新程序或者更新旧程序。

*注意*  需要有效的Debian和Proxmox仓库才能获得安全更新、bug修复程序和新功能

`/etc/apt/sources.list`文件和`/etc/apt/sources.list.d/`目录下的`.list`文件，定义了软件仓库源列表。

### 软件仓库管理
从Proxmox VE 7.0以来，用户可以在网页上检查仓库状态。在节点摘要面板显示一个高级的状态视图，而`仓库`选项中可以看到更加详细的软件源列表、配置和状态。
这里仅是基础的软件仓库管理，比如启用和禁用软件仓库。

### Sources.list
软件源文件sources.list的每一行定义了一个软件源，最常用的软件源一般放在前面。在sources.list中，空行会被忽略，字符#及以后的内容会被解析为注释。可以用apt-get update命令获取软件源中的软件包信息。可以通过命令`apt-get`获取更新或者在GUI面板上点击`节点`——`更新`。

`/etc/apt/sources.list`文件
```
deb http://ftp.debian.org/debian bullseye main contrib
deb http://ftp.debian.org/debian bullseye-updates main contrib

# security updates
deb http://security.debian.org/debian-security bullseye-security main contrib
```
Proxmox VE提供了3个不同的软件仓库。

## 3.1.2. PProxmox VE企业版软件源
Proxmox VE企业版软件源是默认的、稳定的、推荐使用的软件源，供订阅了Proxmox VE企业版的用户使用。该软件源包含了最稳定的软件包，适用于生产环境使用。软件源pve-enterprise默认是启用的。

`/etc/apt/sources.list.d/pve-enterprise.list`文件
```
deb https://enterprise.proxmox.com/debian/pve bullseye pve-enterprise
```
`root@pam`用户将通过电子邮件收到有关可用更新的通知。单击 GUI 中的"更改日志"按钮可查看有关所选更新的更多详细信息。

请注意，你必须提供订阅密钥才可以访问企业版软件源。我们提供有不同级别的订阅服务，具体信息可以查看网址https://www.proxmox.com/en/proxmox-ve/pricing。

  **注意** 您可以通过使用 # 注释掉上面的行（在行首）来禁用此存储库。这可以防止在没有订阅密钥时出现错误消息。在这种情况下，请配置 pve-no-subscription 存储库。

## 3.1.3. Proxmox VE 无订阅储存库

这是推荐用于测试和非生产用途的存储库。它的软件包没有经过严格的测试和验证。您不需要订阅密钥即可访问 pve-no-subscription 存储库。

我们建议在 /etc/apt/sources.list 中配置此存储库。

`/etc/apt/sources.list` 文件

```
deb http://ftp.debian.org/debian bullseye main contrib
deb http://ftp.debian.org/debian bullseye-updates main contrib

# Proxmox VE 无订阅储存库由proxmox.com提供,
# 不建议在生产环境中使用
deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription

# security updates
deb http://security.debian.org/debian-security bullseye-security main contrib
```

## 3.1.4. Proxmox VE 测试存储库
此存储库包含最新的包，主要由开发人员用于测试新功能。要配置它，请将以下行添加到 `/etc/apt/sources.list`
```
deb http://download.proxmox.com/debian/pve bullseye pvetest
```
**仅用于测试新功能或错误修复。**

## 3.1.5. Ceph 太平洋仓库
**Ceph Pacific（16.2）在Proxmox VE 7.0中被宣布稳定**

此存储库包含主要的Proxmox VE Ceph Pacific软件包。它们适用于生产。如果您在 Proxmox VE 上运行 Ceph 客户端或完整的 Ceph 集群，请使用此存储库。

`/etc/apt/sources.list.d/ceph.list`文件

```
deb http://download.proxmox.com/debian/ceph-pacific bullseye main
```

## 3.1.6. Ceph Pacific 测试仓库
此 Ceph 存储库包含 Ceph Pacific 软件包，然后再将其移动到主存储库。它用于在Proxmox VE上测试新的Ceph版本。
`/etc/apt/sources.list.d/ceph.list`

```
deb http://download.proxmox.com/debian/ceph-pacific bullseye test
```
## 3.1.7. Ceph Octopus仓库
**Ceph Octopus（15.2）在Proxmox VE 6.3中宣布稳定，它将继续在6.x版本的剩余生命周期内获得更新，并且Proxmox VE 7.x将继续获得更新，直到Ceph Octopus上游EOL（〜2022-07）**

此储存库包含主要的 Proxmox VE Ceph Octopus 软件包。它们适用于生产。如果您在 Proxmox VE 上运行 Ceph 客户端或完整的 Ceph 集群，请使用此存储库。

`/etc/apt/sources.list.d/ceph.list`
```
deb http://download.proxmox.com/debian/ceph-octopus bullseye main

```
请注意，在较旧的Proxmox VE 6.x上，您需要在上面的存储库规范中bullseye 将更改为buster 

## 3.1.8. Ceph Octopus测试仓库
此 Ceph 存储库包含 Ceph 包，然后再将其移动到主存储库。它用于在Proxmox VE上测试新的Ceph版本。

`/etc/apt/sources.list.d/ceph.list`
```
deb http://download.proxmox.com/debian/ceph-octopus bullseye test
```
## 3.1.9. 安全安装
存储库中的发布文件使用 GnuPG 进行签名。APT 正在使用这些签名来验证所有包是否都来自受信任的源。

如果您从官方ISO映像安装Proxmox VE，则验证密钥已安装。

如果您在 Debian 之上安装 Proxmox VE，请使用以下命令下载并安装密钥：

`# wget https://enterprise.proxmox.com/debian/proxmox-release-bullseye.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg`
之后使用 sha512sum CLI 工具验证校验和：
```
# sha512sum /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg
7fb03ec8a1675723d2853b84aa4fdb49a46a3bb72b9951361488bfd19b29aab0a789a4f8c7406e71a69aabbc727c936d3549731c4659ffa1a08f44db8fdcebfa /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg
```
或 md5sum CLI 工具：
```
# md5sum /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg
bcc35c7173e0845c0d6ad6470b70f50e /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg
```
