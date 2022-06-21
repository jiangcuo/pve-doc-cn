# 10.8 Cloud-Init支持

Cloud-Init兼容多个Linux发行版，主要用于虚拟机初始化配置。通过Cloud-Init，虚拟机管理器可以直接配置虚拟机网络设备和ssh密钥。当虚拟机首次启动时，Cloud-Init能够在虚拟机内部启用相关配置。

很多Linux发行版都提供了可直接使用的Cloud-Init镜像，多数都为OpenStack创建。这些镜像也可以直接用于Proxmox VE。尽管可以直接使用官方镜像，但最好还是自己创建Cloud-Init镜像。自己创建镜像的好处是可以完全控制所安装的软件包，并可以按照自己的需求进行定制。

建议将创建的Cloud-Init镜像转换为虚拟机模板，并用该模板链接克隆快速创建虚拟机。启动虚拟机之前只需要完成网络配置（或许还有ssh密钥）即可。

推荐使用Cloud-Init提供的基于SSH密钥认证的方式登录虚拟机。当然也可以使用用户名口令的方式进行登录，但由于Cloud-Init会保存加密后的口令，所以基于SSH密钥的认证方式更安全。

Proxmox VE通过ISO镜像方式向虚拟机传递配置数据。因此所有Cloud-Init虚拟机需要配置一个虚拟CDROM驱动器。很多Cloud-Init镜像会假定拥有串口控制台，为此推荐增加一个串口控制台并用于显示虚拟机信息。

## 10.8.1准备Cloud-Init镜像

使用Cloud-Init的第一步是准备虚拟机。理论上可以使用任何虚拟机。只需在虚拟机内部安装Cloud-Init软件包即可。例如在基于Debian/Ubuntu的虚拟机上，执行以下命令即可：
```
apt-get install cloud-init
```
很多Linux发行版都提供可直接使用的Cloud-Init镜像（以.qcow2文件形式），因此也可以直接下载并导入这类镜像。下面的例子就使用

Ubuntu在https://cloud-images.ubuntu.com提供的云镜像。

```
 download the image
wget https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img
# create a new VM
qm create 9000 --memory 2048 --net0 virtio,bridge=vmbr0
# import the downloaded disk to local-lvm storage
qm importdisk 9000 bionic-server-cloudimg-amd64.img local-lvm
# finally attach the new disk to the VM as scsi drive
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-1

```

- 注意
 - 在Ubuntu的Cloud-Init镜像中使用SCSI磁盘时，需要配置virtio-scsi-pci控制器。

### 增加Cloud-Init CDROM驱动器

接下来要为虚拟机配置CDROM驱动器，以便传递Cloud-Init配置数据。

```
qm set 9000 --ide2 local-lvm:cloudinit
```

为直接启动Cloud-Init镜像，需要将bootdisk设置为scsi0，并设置仅从磁盘启动。这可以省去虚拟机BIOS的自检并加速启动过程。

```
qm set 9000 --boot c --bootdisk scsi0
```


此外还需要配置一个串口控制台，并用于显示虚拟机信息。由于这是OpenStack镜像的标准要求，所以有很多Cloud-Init镜像都依赖这种配置。

```
qm set 9000 --serial0 socket --vga serial0
```

最后，可以将虚拟机转换为模板。通过该模板，可以用链接克隆快速创建新的虚拟机。这种部署方式比完整克隆（复制）要快得多。

```
qm template 9000
```

## 10.8.2部署Cloud-Init模板

利用模板可以轻松克隆并部署虚拟机

```
qm clone 9000 123 –name ubuntu2
```
然后设置登录认证SSH公钥，并配置IP地址：

```
qm set 123 --sshkey ~/.ssh/id_rsa.pub
qm set 123 --ipconfig0 ip=10.0.10.123/24,gw=10.0.10.1
```

可以通过一个命令行配置Cloud-Init的全部参数项。上面的例子是为了避免命令行过长而做了拆分。此外，需要注意确保IP配置符合你的网络环境要求。

## 10.8.3自定义Cloud-Init配置

Cloud-Init允许用户使用自定义配置文件。具体可以通过cicustom选项实现，具体如下：

```
qm set 9000 --cicustom "user=<volume>,network=<volume>,meta=<volume>"
```

用户的配置文件必须在共享存储上，且必须是虚拟机所在节点能够访问的，否则虚拟机将不能启动。示例如下：

```
qm set 9000 --cicustom "user=local:snippets/userconfig.yaml"
```

一共有三类配置。第一类是上面例子中的user配置参数。第二类是network配置，第三类是meta配置。三类参数都可以同时设定，或根据需要任意组合匹配。如果未使用自定义配置，系统将自动产生一个配置并启用该配置。
自动生成的配置可作为用户自定义配置的基础模板。

```
qm cloudinit dump 9000 user
```

同样的命令也可以用于network和meta配置。


## 10.8.4 Cloud-Init参数

`    cicustom: [meta=<volume>] [,network=<volume>] [,user=<volume>]`

使用指定文件代替自动生成文件。

- meta=`<volume>`

 将包含所有元数据的指定文件通过cloud-init传递给虚拟机。该文件提供指定configdrive2和nocluod信息。

- network=`<volume>`

 将包含所有网络配置数据的指定文件通过cloud-init传递给虚拟机。

- user=`<volume>
`
 将包含所有用户配置数据的指定文件通过cloud-init传递给虚拟机。

- cipassword: `<string>`

 用户口令。通常推荐使用SSH密钥认证，不要使用口令方式认证。请注意，旧版Cloud-Init不支持口令hash加密。

- citype: `<configdrive2 | nocloud>`

 指定Cloud-Init配置数据格式。默认依赖于操作系统类型（ostype）。Linux可设置为nocloud，Windows可设置为configdrive2。

- ciuser: `<string>`

 指定用户名，同时不再使用镜像配置的默认用户。

- ipconfig[n]: [gw=<GatewayIPv4>] [,gw6=<GatewayIPv6>] [,ip=<IPv4Format/CIDR>] [,ip6=<IPv6Format/CIDR>]

  为对应端口设置IP地址和网关。

  IP地址采用CIDR格式，网关为可选项，也采用CIDR格式IP形式设置。

   在DHCP环境中可将IP地址设置为字符串dhcp，此时应将网关留空。在IPv6网络中，如需启用无状态自动配置，将IP设置为字符串auto即可。

   如未设置IPv4或IPv6地址，Cloud-Init默认将使用IPv4的dhcp。

- gw=`<GatewayIPv4>` IPv4的默认网关

- 注意
 - 要配合使用选项：ip

- gw6=`<GatewayIPv6>` IPv6的默认网关
 
  注意:要配合使用选项：ip6

- ip=`<IPv4Format/CIDR>` (default = dhcp) 

  IPv4地址，采用CIDR格式。

- ip=`<IPv6Format/CIDR>` (default = dhcp) 

   IPv6地址，采用CIDR格式。

- nameserver: `<string>`

  为容器设置DNS服务器IP地址。如未设置searchdomian及nameserver，将自动采用服务器主机设置创建有关配置。

- searchdomain: `<string>`
 
  为容器设置DNS搜索域。如未设置searchdomian及nameserver，将自动采用服务器主机设置创建有关配置。

- sshkeys: `<string>`

  设置SSH公钥（每行设置一个key，OpenSSH格式）。
