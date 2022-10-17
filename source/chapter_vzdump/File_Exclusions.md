# 16.9. 排除文件

注意: 此选项仅适用于容器备份。

`vzdump`指令默认排除以下文件（可通过参数`--stdexcludes 0`禁用默认排除）

```
/tmp/?*
/var/tmp/?*
/var/run/?*pid
```

可以手动指定排除路径，如

```
vzdump 777 --exclude-path /tmp/ --exclude-path '/var/foo*'
```

上面命令将排除`/tmp/`文件夹和在`/var/`下的任何`foo`开头的文件，如`/var/foo, /var/foobar`。

如果路径不以`/`开头，`vzdump`会匹配任何的子目录，不会匹配根目录，如

```
vzdump 777 --exclude-path bar
```

上面命令命令将排除任何`bar`文件夹，如`/var/bar,/bar,/var/foo/bar`等，但不会排除`/bar2`。

备份文件存储在备份包（`/etc/vzdump/`）中，并将正确还原。


