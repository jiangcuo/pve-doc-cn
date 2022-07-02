#  11.5 安全注意事项

由于容器直接使用主机Linux内核，所以恶意用户可利用的攻击面非常宽泛。如果你计划向不可信的用户提供容器服务，必须认真考虑该问题。一般来说，基于全虚拟化的虚拟机能够达到更好的隔离效果。

好消息是，LXC利用了Linux内核的众多安全特性，例如AppArmor、CGroups以及PID和用户namespaces，这大大改善了容器的使用安全性。


## 11.5.1 AppArmor

AppArmor配置文件用于限制对可能存在危险的操作的访问。某些系统调用(即mount)被禁止执行。

要跟踪AppArmor活动，请使用：
```
dmesg | grep apparmor
```

尽管不建议使用AppArmor，可以对容器禁用AppArmor。但这就带来了安全风险。如果系统配置错误或存在LXC或Linux内核漏洞，则某些syscall在容器内执行时可能会导致权限提升。

要禁用容器的AppArmor，请将以下行添加到位于/etc/pve/lxc/CTID.conf的容器配置文件中：

```
lxc.apparmor.profile = unconfined

```

- 注意： 
  
  请不要用于生产环境!

## 11.5.2. Control Groups (cgroup)

`cgroup`是Linux内核的一个功能，用来限制、控制与分离一个进程组的资源。

通过cgroup控制的主要资源是CPU、内存和swap限制以及对主机设备的访问。cgroups还用于在拍摄快照之前“冻结”容器。

目前有2个版本的cgroups可用， `legacy`和`cgroupv2`.

从Proxmox VE 7.0开始，默认的是纯`cgroupv2`环境。以前使用“混合”设置，其中资源控制主要在cgroupv1中完成，并使用额外的cgroupv2控制器，该控制器可以通过cgroup_no_v1内核命令行参数接管一些子系统。（有关详细信息，请参阅[内核参数](https://www.kernel.org/doc/html/latest/admin-guide/kernel-parameters.html)文档。）

### CGroup版本兼容性

关于Proxmox VE的纯cgroupv2和旧`混合`环境的主要区别在于，内存和swap现在由cgroupv2独立控制。容器的内存和swap设置可以直接映射到这些值，而以前只能限制内存限制以及内存和交换的总和限制。

另一个重要区别是，设备控制的配置方式完全不同。因此，目前在纯cgroupv2环境中不支持文件系统配额。

在纯cgroupv2环境中运行需要容器操作系统支持cgroupv2。运行systemd 231或更高版本的容器支持cgroupv2 [44]，不使用systemd作为init系统的容器也不支持。

> CentOS 7和Ubuntu 16.10是两个著名的Linux发行版，它们的系统版本太旧了，无法在cgroupv2环境中运行，您可以执行下面方案：

>> - 将整个发行版升级到新版本。对于上面的例子，可以是Ubuntu 18.04或20.04，以及CentOS 8（或RHEL/CentOS衍生产品，如AlmaLinux或Rocky Linux）。这有利于获得最新的错误和安全修复，通常还有新功能，并延长了EOL日期。

>> - 升级容器systemd版本。如果发行版提供了一个`backports`存储库，这可能是一个简单快捷的权宜之计。

>> - 将容器或其服务移动到kvm虚拟机。虚拟机与主机的交互要少得多，这也是大家要用虚拟机装远古系统的原因。

>> - 切换回旧版cgroup控制器。请注意，虽然它可能是一个有效的解决方案，但它不是一个永久性的解决方案。未来的Proxmox VE主要版本（例如8.0）很可能无法再支持legacy控制器。

### 更改cgroup版本

  - 注意：如果不需要文件系统配额，并且所有容器都支持cgroupv2，建议坚持新的默认值（cgroupv2）。

要切换回以前的版本，可以使用以下内核命令行参数：

```
systemd.unified_cgroup_hierarchy=0
```

编辑内核引导命令行请参考3.12.6，以了解在哪里添加参数。