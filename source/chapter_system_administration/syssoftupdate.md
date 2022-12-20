# 3.2. 系统软件更新
Proxmox定期为所有存储库提供更新。要安装更新，请使用基于 Web 的 GUI 或以下 CLI 命令：

```
# apt-get update
# apt-get dist-upgrade
```
**注意**
apt软件包管理系统非常灵活，有无数的选项和特性。可以运行man apt-get或查看[Hertzog13]获取相关信息。


你应该定期执行以上升级操作，也可以在我们发布安全更新时执行升级。重大系统升级通知会通过Proxmox VE Community Forum发布。随升级通知发布的还会有具体的升级细节。


