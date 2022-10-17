# 14.9 实际应用示例

## 14.8.1 管理员组

一个很实用的特性是创建一组具有全部管理权限的管理员用户（不使用root用户）。

定义管理员组：
```
pveum groupadd admin -comment "System Administrators"

```
赋予权限：
```
pveum aclmod / -group admin -role Administrator

```
向管理员组添加管理员用户：
```
pveum usermod testuser@pve -group admin
```

## 14.8.2 审计员

赋予用户或用户组PVEAuditor角色就可以赋予相应用户对系统的只读权限。

例1：允许用户joe@pve查看系统所有对象
```
pveum aclmod / -user joe@pve -role PVEAuditor
```
例2：允许用户joe@pve查看所有虚拟机
```
pveum aclmod /vms -user joe@pve -role PVEAuditor
```

## 14.8.3 分配用户管理权限

如果需要将用户管理权限赋予joe@pve，可以运行如下命令：
```
pveum aclmod /access -user joe@pve -role PVEUserAdmin

```
之后，joe@pve用户就可以添加和删除用户，修改其他用户的口令和属性。这是一个权限非常大的角色。你应该将该权限限制在指定的认证域和用户组。

以下是限制joe@pve仅能修改pve认证域中customers用户组用户的示例：
```
pveum aclmod /access/realm/pve -user joe@pve -role PVEUserAdmin
pveum aclmod /access/groups/customers -user joe@pve -role PVEUserAdmin
```
- 注意
  
  执行以上命令后，joe@pve用户能够添加用户，但添加的用户只能属于pve认证域中的customers用户组。

## 14.8.4 只用于监控的API权限

给定在所有虚拟机上具有PVEVMAdmin角色的用户Joe@pve：
```
pveum aclmod /vms -user joe@pve -role PVEVMAdmin
```
添加具有单独权限的新API token，该令牌仅允许查看VM信息(例如，用于监视目的)：
```
pveum user token add joe@pve monitoring -privsep 1 
pveum aclmod /vms -token ’joe@pve!monitoring’ -role PVEAuditor 
```

验证用户和token的权限：
```
pveum user permissions joe@pve 
pveum user token permissions joe@pve monitoring 
```

## 14.8.5资源池

一个企业往往设立有多个部门，将资源和管理权限分配给各个部门是很常见的做法。资源池是一组虚拟机和存储服务的集合，你可以在WebGUI创建资源池，然后向资源池添加资源（虚拟机，存储服务）。

你可以向资源池赋予访问权限，这些权限会被其成员自动继承获取。

假定你有一个软件开发部，首先创建用户组

```
pveum groupadd developers -comment "Our software developers"
```
然后为该组创建一个新用户
```
pveum useradd developer1@pve -group developers –password
```
- 注意
  
  参数-password将会提示你设立用户口令。

假定你已经通过WebGUI创建资源池“dev-pool”，现在我们可以向该资源池赋予访问权限：
```
pveum aclmod /pool/dev-pool/ -group developers -role PVEAdmin
```
现在我们的软件开发部门就可以管理该资源池中的资源了。

