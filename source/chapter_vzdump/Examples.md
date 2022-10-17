# 16.10. 示例

简单备份`777`的客户机，没有快照，只是简单的备份磁盘文件和配置信息并储存到默认的备份文件夹中 (通常是 `/var/lib/vz/dump/`)。

```
vzdump 777
```

使用暂停模式备份，会创建一个快照，随后再备份。（停机时间最少）

```# vzdump 777 --mode suspend```


备份所有的客户机，并在备份完成之后，发送邮件给root和admin

```# vzdump --all --mode suspend --mailto root --mailto admin```


使用快照模式备份，并指定备份文件夹。（没有停机时间）

```# vzdump 777 --dumpdir /mnt/backup --mode snapshot```

备份多个客户机，并且发送邮件。

```# vzdump 101 102 103 --mailto root```

备份除101，102以外的所有客户机。

```# vzdump --mode suspend --exclude 101,102```

还原一个容器777备份到新容器600。

```# pct restore 600 /mnt/backup/vzdump-lxc-777.tar```


还原一个虚拟机。

```# qmrestore /mnt/backup/vzdump-qemu-888.vma 601```

利用pipe管道，克隆一个101容器，并还原成300，顺便把rootfs设置成4G。

```# vzdump 101 --stdout | pct restore --rootfs 4 300 -```