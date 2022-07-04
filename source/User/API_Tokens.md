# 14.3 API Tokens

API Tokens允许另一个系统、软件或API客户端对REST API的大部分进行无状态访问。可以为单个用户生成Tokens，并且可以为其赋予单独的权限和到期日期，以限制访问的范围和持续时间。如果API Tokens受到危害，则可以在不禁用用户本身的情况下撤销Tokens。

API Tokens有两种基本类型：
- 权限分离：Token需要通过ACL显式访问，其有效权限由用户权限和Token权限相交计算得出。
- 完全权限：令牌权限与关联用户的权限相同。

> 警告: 
> 在生成令牌时，令牌值仅显示/返回一次。以后不能通过API再次检索！


要使用API Tokens，请在发出API请求时将HTTP头Authorization设置为PVEAPIToken=User@Realm!TOKENID=UUID形式的显示值，或参阅API客户端文档。

