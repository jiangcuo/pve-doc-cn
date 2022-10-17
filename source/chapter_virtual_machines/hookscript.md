# 10.10 回调脚本


可以使用hookscript属性设置虚拟机回调脚本。

```
qm set 100 -hookscript local:snippets/hookscript.pl
```

该脚本会在虚拟机生命周期的多个阶段被调用。如需查看具体例子和相关文档，可以在`/usr/share/pve-docs/examples/guest-example-hookscript.pl`查看范例脚本。

