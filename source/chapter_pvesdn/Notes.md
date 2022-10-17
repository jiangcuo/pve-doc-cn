# 12.9. Notes

## 12.9.1. VXLAN IPSEC 加密

如果您需要在VXLAN之上添加加密，则可以通过`strongswan`方式使用IPSEC进行加密。您需要将 MTU减少 60 个字节 （IPv4） 或 80 个字节 （IPv6） 来处理加密。

因此，对于默认的实际 1500 MTU，您需要使用 MTU 1370（1370 + 80 （IPSEC） + 50 （VXLAN） == 1500）。


### 安装strongswan

```
apt install strongswan
```

在 '/etc/ipsec.conf' 中添加配置。我们只需要加密来自VXLAN UDP 4789端口的流量。

```
conn %default
    ike=aes256-sha1-modp1024!  # the fastest, but reasonably secure cipher on modern HW
    esp=aes256-sha1!
    leftfirewall=yes           # this is necessary when using Proxmox VE firewall rules

conn output
    rightsubnet=%dynamic[udp/4789]
    right=%any
    type=transport
    authby=psk
    auto=route

conn input
    leftsubnet=%dynamic[udp/4789]
    type=transport
    authby=psk
    auto=route
```

然后生成一个预共享密钥

```
openssl rand -base64 128
```

并复制密钥到'/etc/ipsec.secrets'中，使文件内容看起来像这样：

```
: PSK <generatedbase64key>
```

您需要在其他节点上复制 PSK 和配置。



