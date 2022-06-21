# 10.13虚拟机配置文件

虚拟机配置文件保存在Proxmox集群文件系统中，并可以通过路径`/etc/pve/qemu-server/<VMID>.conf`访问。和`/etc/pve`下的其他文件一样，虚拟机配置文件会自动同步复制到集群的其他节点。

### 注意

小于100的VMID被Proxmox VE保留内部使用，并且在集群内的VMID不能重复。

## 虚拟机配置文件示例

```
boot: order=virtio0;net0
cores: 1
sockets: 1
memory: 512
name: webmail
ostype: l26
net0: e1000=EE:D2:28:5F:B6:3E,bridge=vmbr0
virtio0: local:vm-100-disk-1,size=32G
```

虚拟机配置文件就是普通文本文件，可以直接使用常见文本编辑器（vi，nano等）编辑。这也是日常对虚拟机配置文件进行细微调整的一般做法。但是务必注意，必须彻底关闭虚拟机，然后再启动虚拟机，修改后的配置才能生效。

因此，更好的做法是使用qm命令或WebGUI来创建或修改虚拟机配置文件。Proxmox VE能够直接将大部分变更直接应用到运行中的虚拟机，并即时生效。该特性称为“热插拔“，并无需重启虚拟机。

## 10.13.1配置文件格式
虚拟机配置文件使用英文冒号字符“:“为分隔符的键/值格式。格式如下：

```
# this is a comment
OPTION: value
```

空行会被自动忽略，以字符`#`开头的行按注释处理，也会被自动忽略。
