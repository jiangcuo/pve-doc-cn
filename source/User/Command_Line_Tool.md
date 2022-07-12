# 14.8命令行工具

大部分用户使用WebGUI就能够完成用户管理任务了。但Proxmox VE还提供了一个全功能的命令行工具pveum（“Proxmox VE User Manager”的缩写）。由于Proxmox VE的命令行工具都通过封装API实现的，因此你也可以通过调用REST API来使用这些功能。

如下是一些使用示例。如需要显示帮助信息，可运行：

```
pveum
```

或（针对特定命令显示更详细的信息）
```
pveum help useradd
```

创建新用户：
```
pveum useradd testuser@pve -comment "Just a test"
```
设置或修改口令（不是所有认证域都支持该命令）：
````
pveum passwd testuser@pve
````

禁用用户：
```
pveum usermod testuser@pve -enable 0
```
创建新用户组：
```
pveum groupadd testgroup
```
创建新角色：
```
pveum roleadd PVE_Power-only -privs "VM.PowerMgmt VM.Console"
```