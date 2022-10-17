

注意
更新的常见问题将在追加在本节最后。

## 1.Proxmox VE基于哪个发行版？
  
  Proxmox VE基于Debian GNU/Linux。

## 2.Proxmox VE项目采用哪种开源协议？
  
  Promxox VE代码采用开源协议GNU Affero General Public License，version 3。

## 3.Proxmox VE支持32位CPU么？
  
  Proxmox VE仅支持64位CPU（AMD或Intel）。目前没有计划支持32位CPU。
	
注意:虚拟机和容器可以采用32位或64位操作系统。

## 4. 我的CPU支持虚拟化么？  
  
  检测CPU的虚拟化兼容性，可用以下命令检测vmx或svm标记
  
  ``` 
  egrep '(vmx|svm)' /proc/cpuinfo
 
  ```
## 5. 支持的Intel CPU列表

  支持Intel虚拟化技术（Intel VT-x）的64位CPU。（同时支持Intel VT和64位的IntelCPU列表）

## 6. 支持的AMD CPU
  
  支持AMD虚拟化技术（AMD-V）的64位CPU。

## 7. 容器，CT，VE，虚拟个人服务器，VPS都是什么？

  操作系统虚拟化是一种服务器虚拟化技术，也就是利用一个操作系统内核同时运行多个彼此隔离的操作系统用户空间实例，而不是仅运行一个操作系统用户空间实例。我们将每个实例称为容器。由于共享操作系统内核，容器仅限于运行Linux系统。

## 8. QEMU/KVM客户机（或VM）是什么？
  
  QEMU/KVM客户机（或VM）是一个虚拟化客户机系统，利用QEMU和Linux KVM内核模块运行在Proxmox VE上。

## 9. QEMU是什么？
  
  QEMU是一个通用的开源模拟器和虚拟化软件。QEMU利用Linux KVM内核模块直接在主机CPU运行客户机代码，从而获得接近于本地物理服务器的效率和性能。QEMU不仅能运行Linux客户机，还能运行任意操作系统客户机。

## 10.各版本的Proxmox VE最终支持期限是？

  Proxmox VE的支持周期和debian对[oldstable](https://wiki.debian.org/DebianOldStable)的支持相同。Proxmox VE使用滚动发布模型，并且始终建议使用最新的稳定版本。

| Proxmox VE Version | Debian Version       | First Release | Debian EOL | Proxmox EOL  |
|--------------------|----------------------|---------------|------------|--------------|
| Proxmox VE 7.x     | Debian 11 (Bullseye) | Jul-21        | tba        | tba          |
| Proxmox VE 6.x     | Debian 10 (Buster)   | Jul-19        | Jul-22     | Jul-22       |
| Proxmox VE 5.x     | Debian 9 (Stretch)   | Jul-17        | Jul-20     | Jul-20       |
| Proxmox VE 4.x     | Debian 8 (Jessie)    | Oct-15        | Jun-18     | Jun-18       |
| Proxmox VE 3.x     | Debian 7 (Wheezy)    | May-13        | Apr-16     | Feb-17       |
| Proxmox VE 2.x     | Debian 6 (Squeeze)   | Apr-12        | May-14     | May-14       |
| Proxmox VE 1.x     | Debian 5 (Lenny)     | Oct-08        | Mar-12     | Jan-13       |

## 11. 如何升级Proxmox VE

  小版本升级，例如从Proxmox VE 5.1升级到5.2，可以按日常升级操作进行。具体可以通过Web GUI的Node→Updates控制面板进行，也可以执行以下命令
  ```
  apt update
  apt full-upgrade
  ```
  注意：无论何时，在正式升级前都请务必确保按照[](../hostsysmgr/aptsource.md)正确设置了软件源，并且apt update命令没有任何报错。

  大版本升级，例如从Proxmox VE 4.4升级到5.0，也是可以做到的，但是必须要预先进行充分的准备，包括认真规划升级方案，测试方案可行性，做好备份。永远不要在未做备份的情况下升级。根据部署情况的不同，具体升级过程会有个性化步骤，但官方还是有一个一般性的升级建议方案：
  
  - [从 Proxmox VE 6.x 升级到 7.0](https://pve.proxmox.com/wiki/Upgrade_from_6.x_to_7.0)

  - [从 Proxmox VE 5.x 升级到 6.0](https://pve.proxmox.com/wiki/Upgrade_from_5.x_to_6.0)

  - [从 Proxmox VE 4.x 升级到 5.0](https://pve.proxmox.com/wiki/Upgrade_from_4.x_to_5.0)

  - [从 Proxmox VE 3.x 升级到 4.0](https://pve.proxmox.com/wiki/Upgrade_from_3.x_to_4.0)


##  12.LXC vs LXD vs Proxmox容器 vs Docker
    
  LXC是Linux内核容器的用户空间接口。通过强大的API和易用的工具，Linux用户能够轻松地创建并管理系统容器。LXC，及其前任OpenVZ，专注于系统虚拟化，也就是让你在容器内运行完整的操作系统，其中你可以ssh方式登录，增加用户，运行apache服务器等。

  LXD基于LXC创建，并提供了更好的用户体验。在底层，LXD通过liblxc调用LXC及其Go绑定来创建和管理容器。LXD基本上是LXC工具和模板系统的的另一个选择，只是增加了诸如远程网络控制等新的特性。

  Proxmox容器也专注于系统虚拟化，并使用LXC作为其底层服务。Proxmox容器工具称为pct，并和Proxmox VE紧密集成在一起。这意味着pct能够利用集群特性，并像虚拟机那样充分利用相同的网络和存储服务。你甚至可以使用Proxmox VE防火墙，备份和恢复，设置容器HA。可以使用Proxmox VE API通过网络管理容器的全部功能。

  Docker专注于在容器内运行单一应用。你可以用docker工具在主机上管理docker实例。但不推荐直接在Proxmox VE主机上运行docker。