# 8.7 Ceph CRUSH和设备类别

Ceph是以算法Controlled Replication Under Scalable Hashing（CRUSH[ CRUSH详见https://ceph.com/wp-content/uploads/2016/08/weil-crush-sc06.pdf]）为基础创建的。

CRUSH算法用于计算数据存取的位置，且无需中心索引服务的支持。CRUSH基于构成存储池pool的OSD、buckets（设备位置）和rulesets（数据复制规则）来完成计算。

- 注意：
  -  关于CRUSH map的进一步信息，可以查看Ceph官方文档中CRUSH map[ CRUSH map参见http://docs.ceph.com/docs/luminous/rados/operations/crush-map/]一节。

调整该图可以反映不同层次的复制关系。对象副本可以分布在不同地方（例如，各故障区域），并同时保持期望的分布。

常见用法是为不同的Ceph pool配置不同类别的磁盘。为此，Ceph luminous引入了设备类的概念，以简化ruleset的创建。

设备类信息可以用命令ceph osd tree查看。各个类代表了各自的根位置。命令如下。

```
ceph osd crush tree –show-shadow
```

以上命令的输出示例如下：

```
ID  CLASS WEIGHT  TYPE NAME
-16  nvme 2.18307 root default~nvme
-13  nvme 0.72769     host sumi1~nvme
 12  nvme 0.72769         osd.12
-14  nvme 0.72769     host sumi2~nvme
 13  nvme 0.72769         osd.13
-15  nvme 0.72769     host sumi3~nvme
 14  nvme 0.72769         osd.14
 -1       7.70544 root default
 -3       2.56848     host sumi1
 12  nvme 0.72769         osd.12
 -5       2.56848     host sumi2
 13  nvme 0.72769         osd.13
 -7       2.56848     host sumi3
 14  nvme 0.72769         osd.14
```

如果要让pool将对象保存在指定设备类上，需要用指定设备类创建ruleset。

```
ceph osd crush rule create-replicated <rule-name> <root> <failure-domain> <class>
```

