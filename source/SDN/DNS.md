# 12.7 DNS

Proxmox VE SDN中的DNS插件用于连接一个DNS API服务器，以注册虚拟机的主机名和 IP 地址。DNS 配置与一个或多个区域相关联，可为某个区域，配置的所有子网 IP 提供 DNS 注册。

## 12.7.1. PowerDNS 插件

https://doc.powerdns.com/authoritative/http-api/index.html

您需要在 PowerDNS 配置中启用 Web 服务器和 API：

```
api=yes
api-key=sui-ji-yi-ge-zi-fu-chuan
webserver=yes
webserver-port=8081
```

Powerdns有如下属性:

- url

  REST-API地址: http://yourpowerdnserver.domain.com:8081/api/v1/servers/localhost

- key
  
  API访问密钥

- ttl

  默认的ttl记录值

