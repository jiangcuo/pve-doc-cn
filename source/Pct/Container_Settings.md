# 11.4. 容器设置

## 11.4.1 通用设置

容器通用设置项如下：

- Node：容器所处的物理服务器

- CT ID：Proxmox VE用于标识容器的唯一序号。

- Hostname：容器的主机名。

- Resource Pool：逻辑上划分的一组容器和虚拟机。

- Password：容器的root口令。

- SSH Public Key：用于SSH连接登录root用户的公钥。

- Unprivileged container：该项目用于在容器创建阶段设置创建特权容器或非特权容器。

### 非特权容器

非特权容器采用了名为用户命名空间usernamespaces的内核新特性。容器内UID为0的root用户被影射至外部的一个非特权用户。也就是说，在非特权容器中常见的安全问题（容器逃逸，资源滥用等）最终只能影响到外部的一个随机的非特权用户，并最终归结为一个一般的内核安全缺陷，而非LXC容器安全性问题。LXC工作组认为非特权容器的设计是安全的。

注意： 如果容器使用 systemd 作为 init 系统，请注意，在容器内运行的 systemd 版本应等于或大于 220。


### 特权容器

容器中的安全性是通过使用强制访问控制（AppArmor）、seccomp 筛选器和 Linux 内核namespace来实现的。LXC团队认为特权容器技术是不安全的，并且不打算为新发现的容器逃逸漏洞申报CVE编号和发布快速修复补丁。。这就是为什么特权容器应仅在受信任的环境中使用的原因。

## 11.4.2 CPU

你可以通过cores参数项设置容器内可见的CPU数量。

该参数项基于Linux的cpuset cgroup（控制group）实现。

在pvestatd服务内有一个任务专门用于在CPU之间平衡容器工作负载。你可以用如下命令查看CPU分配情况：

```
pct cpusets
---------------------
102: 6 7
105: 2 3 4 5
108: 0 1
---------------------
```

容器能够直接调用主机内核，所以容器内的所有任务进程都由主机的CPU调度器直接管理。Proxmox VE默认使用Linux CFS（完全公平调度器），并提供以下参数项可以进一步控制CPU分配。

- cpulimit：	
  
  你可以设置该参数项进一步控制分配的CPU时间片。需要注意，该参数项类型为浮点数，因此你可以完美地实现这样的配置效果，即给容器分配2个CPU核心，同时限制容器总的CPU占用为0.5个CPU核心。具体如下：

    ```
    cores: 2
    cpulimit: 0.5
    ```

- cpuunits：	

  该参数项是传递给内核调度器的一个相对权重值。参数值越大，容器得到的CPU时间越多。
  
  具体得到的CPU时间片由当前容器权重占全部容器权重总和的比重决定。该参数默认值为1024，可以调大该参数以提高容器的优先权。

## 11.4.3 内存

容器内存由cgroup内存控制器管理。

- memory：容器的内存总占用量上限。对应于cgroup的memory.limit_in_bytes参数项。

- swap：	用于设置允许容器使用主机swap空间的大小。对应于cgroup的memory.memsw.limit_in_bytes参数项，cgroup的参数实际上是内存和交换分区容量之和（memory+swap）。

## 11.4.4 挂载点

容器的根挂载点通过rootfs属性配置。除此之外，你还可以再配置256个挂载点，分别对应于参数mp0到mp255。具体设置项目如下：

- rootfs:` [volume=]<volume> [,acl=<1|0>] [,mountoptions=<opt[;opt...]>] [,quota=<1|0>] [,replicate=<1|0>] [,ro=<1|0>] [,shared=<1|0>] [,size=<DiskSize>]`

  配置容器根文件系统存储卷。全部配置参数见后续内容。

- mp[n]:` [volume=]<volume> ,mp=<Path> [,acl=<1|0>] [,backup=<1|0>] [,mountoptions=<opt[;opt...]>] [,quota=<1|0>] [,replicate=<1|0>] [,ro=<1|0>] [,shared=<1|0>] [,size=<DiskSize>]`
  
  配置容器附加挂载点存储卷。使用STORAGE_ID:SIZE_IN_GiB语法分配新的存储卷。

  - acl=`<boolean>`
    
    启用/禁用acl。
  
  - backup=`<boolean>`
    
    用于配置在备份容器时是否将挂载点纳入备份范围。（仅限于附加挂载点）

  - `[,mountoptions=<opt[;opt...]>]`
    
    rootfs/mps挂载点的附加参数

  - mp=`<Path>`
    
    存储卷在容器内部的挂载点路径。

    - 注意: 出于安全性考虑，禁止含有文件链接。

  - quota=`<boolean>`
    
    在容器内启用用户空间配额（对基于zfs子卷的存储卷无效）。

  - replicate=`<boolean> `(default = 1)
  
    卷是否被可以被调度任务复制。

  - ro=`<boolean>`

    用于标识只读挂载点。

  - shared=`<boolean> `(default = 0)

    用于标识当前存储卷挂载点对所有节点可见。
    
    - 警告：设置该参数不等于自动共享挂载点，而仅仅表示当前挂载点被假定已经共享。

  - size=`<DiskSize>`
  
    存储卷容量（参数值只读）。

  - volume=`<volume>`

    存储卷命令，即挂载到容器的设备或文件系统路径。

目前主要有3类不同的挂载：基于存储服务的挂载，绑定挂载，设备挂载。

### 容器rootfs典型配置示例

```
rootfs: thin1:base-100-disk-1,size=8G
```

