

注意
更新的常见问题将在追加在本节最后。

- 1.Proxmox VE基于哪个发行版？
  
  Proxmox VE基于Debian GNU/Linux。

- 2.Proxmox VE项目采用哪种开源协议？
  
  Promxox VE代码采用开源协议GNU Affero General Public License，version 3。

- 3.Proxmox VE支持32位CPU么？
  
  Proxmox VE仅支持64位CPU（AMD或Intel）。目前没有计划支持32位CPU。
	
注意:虚拟机和容器可以采用32位或64位操作系统。
	
- 4.我的CPU支持虚拟化么？  
  
  检测CPU的虚拟化兼容性，可用以下命令检测vmx或svm标记
  
  ``` 
  egrep '(vmx|svm)' /proc/cpuinfo
 
  ```

- 5.支持的Intel CPU列表

  支持Intel虚拟化技术（Intel VT-x）的64位CPU。（同时支持Intel VT和64位的IntelCPU列表）

- 6.支持的AMD CPU
  
  支持AMD虚拟化技术（AMD-V）的64位CPU。

- 7.容器，CT，VE，虚拟个人服务器，VPS都是什么？

  操作系统虚拟化是一种服务器虚拟化技术，也就是利用一个操作系统内核同时运行多个彼此隔离的操作系统用户空间实例，而不是仅运行一个操作系统用户空间实例。我们将每个实例称为容器。由于共享操作系统内核，容器仅限于运行Linux系统。

- 8.QEMU/KVM客户机（或VM）是什么？
  
  QEMU/KVM客户机（或VM）是一个虚拟化客户机系统，利用QEMU和Linux KVM内核模块运行在Proxmox VE上。

- 9.QEMU是什么？
  
  QEMU是一个通用的开源模拟器和虚拟化软件。QEMU利用Linux KVM内核模块直接在主机CPU运行客户机代码，从而获得接近于本地物理服务器的效率和性能。QEMU不仅能运行Linux客户机，还能运行任意操作系统客户机。

- 10.各版本的Proxmox VE最终支持期限是？

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
