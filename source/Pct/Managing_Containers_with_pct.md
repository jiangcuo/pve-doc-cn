# 11.9 使用pct管理容器

Proxmox VE使用pct命令管理容器。你可以用pct命令创建或销毁容器，也可以控制容器的运行（启动，关闭，迁移等）。你还可以用pct命令设置相关配置文件中的参数，例如网络配置或内存上限。

## 11.9.1命令行示例

使用Debian模板创建一个容器（假定你已经通过Web界面下载了模板）

```
pct create 100 /var/lib/vz/template/cache/debian-8.0-standard_8.0-1_amd64.tar.gz
```

启动100号容器

```
pct start 100
```

通过getty启动登录控制台

```
pct console 100
```

进入LXC命名空间并使用root用户启动一个shell

```
pct enter 100
```

显示容器配置

```
pct config 100
```

在容器运行的状态下增加名为eth0的虚拟网卡，同时设置桥接虚拟交换机vmbr0，IP地址和网关。

```
pct set 100 -net0 name=eth0,bridge=vmbr0,ip=192.168.15.147/24,gw=192.168.15.1
```

调整容器内存减少到512MB

```
pct set 100 -memory 512
```

删除容器总是会将其从访问控制列表和防火墙配置中移除，如果你想将容器从备份任务、复制或者HA资源中移除，你还需要添加选项--purge

```
 pct destroy 100 --purge
```

移动挂载点到其他的存储

```
pct move-volume 100 mp0 other-storage
```

