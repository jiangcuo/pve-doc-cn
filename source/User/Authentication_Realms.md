# 14.5认证域

Proxmox VE用户实际上其他外部认证域用户的一个副本。认证域信息都保存在/etc/pve/domains.cfg。以下是可用的认证域：

- Linux PAM 标准认证
  
  Linux PAM 是用于系统范围用户身份验证的框架。这些用户是使用 adduser 等命令在主机系统上创建的。如果 Proxmox VE 主机系统上存在 PAM 用户，则可以将相应的条目添加到 Proxmox VE，以允许这些用户通过其系统用户名和密码登录。

- Proxmox VE 认证服务器
  
  用户口令保存在Unix风格的口令文件（/etc/pve/priv/shadow.cfg）中。口令使用SHA-256哈希算法加密。该方式是小规模（或中等规模）环境下最便于使用的认证方式。用户在Proxmox VE内部即可完成身份认证，无须任何外部支持，所有用户身份都由Proxmox VE管理，并可在WebGUI界面直接修改口令。

- LDAP
  
  LDAP（轻量级目录访问协议）是一种开放的跨平台协议，用于使用目录服务进行身份验证。OpenLDAP是LDAP协议的流行开源实现。

- 微软活动目录(AD)

  Microsoft Active Directory （AD） 是 Windows 域网络的目录服务，支持将其作为 Proxmox VE 的身份验证领域。它支持 LDAP 作为身份验证协议。

- OpenID Connect
  
  OpenID Connect是作为OATH 2.0协议之上的身份层实现的。它允许客户端根据外部授权服务器执行的身份验证来验证用户的身份。

## 14.5.1. Linux PAM 标准认证

由于 Linux PAM 对应于主机系统用户，因此允许用户登录的每个节点上都必须存在一个系统用户。用户使用其常用系统密码进行身份验证。

默认情况下，此领域是添加的，无法删除。

在可配置性方面，管理员可以选择要求对来自领域登录名进行双重身份验证，并将领域设置为默认身份验证领域。

## 14.5.2. Proxmox VE 认证服务器

该领域是默认创建的，与 Linux PAM 一样，唯一可用的配置项目是能够要求该领域的用户进行双重身份验证，并将其设置为用于登录的默认领域。

与其他 Proxmox VE 领域类型不同，用户完全通过 Proxmox VE 创建和身份验证，而不是针对其他系统进行身份验证。因此，您需要在创建时为此类用户设置密码。

## LDAP


也可以使用LDAP服务器（例如openldap）进行用户身份认证。LDAP支持部署备用服务器，并允许通过加密的SSL连接传递认证信息。

LDAP将在基本域名（base_dn）下搜索用户属性名（user_attr）指定的用户名。

可以配置服务器和可选的回退服务器，并且可以通过 SSL 对连接进行加密。此外，可以为目录和组配置过滤器。过滤器允许您进一步限制领域的范围。

例如，如果一个用户的ldif身份信息记录如下:
```
# user1 of People at ldap-test.com
dn: uid=user1,ou=People,dc=ldap-test,dc=com
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: inetOrgPerson
uid: user1
cn: Test User 1
sn: Testers
description: This is the first test user.
```

则基本域名为“ou=People,dc=ldap-test,dc=com”，用户属性为“uid”。

如果Proxmox VE在请求验证用户身份前需要先认证（bind）ldap服务器的真实性，可以通过/etc/pve/domains.cfg中的bind_dn属性配置认证域名称。认证口令则保存在/etc/pve/priv/ldap/<realmname>.pw（例如/etc/pve/priv/ldap/my-ldap.pw），其中仅有一行明文口令信息。

要验证证书，您需要设置capath。您可以将其直接设置为LDAP服务器的CA证书，也可以设置为包含所有受信任CA证书（/etc/ssl/certs）的系统路径。此外，您需要设置验证选项，也可以通过Web界面完成。

LDAP领域主要配置如下:

- 领域（Realm）：Proxmox VE用户的领域标识符
- 基本域名（base_dn）：用户所在的目录
- 用户属性名称（user_attr）：包含用户将要登录的用户名的LDAP属性
- 服务器（server1）：LDAP目录所在的服务器
- 后备服务器（server2）：可选的后备服务器地址，以防无法访问主服务器
- 端口（port）：LDAP服务器监听端口

注意：为了允许特定用户使用LDAP服务器进行身份验证，您还必须在Proxmox VE服务器将他们添加为该领域的用户。这可以通过同步自动执行。

## 14.5.4. 微软活动目录 (AD)

要将Microsoft AD设置为Proxmox VE领域，需要指定服务器地址和身份验证域。Active Directory支持大多数与LDAP相同的属性，例如可选的后备服务器、端口和SSL加密。此外，配置后，用户可以通过同步操作自动添加到Proxmox VE中。

与LDAP一样，如果Proxmox VE在绑定到AD服务器之前需要进行身份验证，则必须配置绑定用户（bind_dn）属性。默认情况下，Microsoft AD通常需要此属性。

微软活动目录的主要配置是：

- 领域（Realm）：Proxmox VE用户的领域标识符
- 域名（domain）：AD服务器的域名
- 服务器（server1）：LDAP目录所在的服务器
- 后备服务器（server2）：可选的后备服务器地址，以防无法访问主服务器
- 端口（port）：LDAP服务器监听端口

## 14.5.5 同步基于LDAP的领域

可以自动同步基于LDAP领域的用户和组（LDAP和Microsoft Active Directory），而不必手动将它们添加到Proxmox VE。

您可以从Web界面`身份验证`面板的添加/编辑窗口或通过`pveum realm add/modfy`改命令访问同步选项。然后，您可以从GUI的`身份验证`面板或使用以下命令执行同步操作：

```
pveum realm sync <realm>

```
用户和组会同步到集群范围的配置文件`/etc/pve/user.cfg`。

**同步配置**

同步基于LDAP领域的配置选项可以在添加/编辑窗口的同步选项选项卡中找到。

主要配置选项如下：

- 绑定用户（bind_dn）:
  
  指定用于查询用户和组的LDAP帐户。此帐户需要能够访问所有所需的条目。如果设置了，搜索将以账户进行；否则，搜索将匿名进行。用户必须是完整的LDAP格式的名称（DN），例如cn=admin，dc=example，dc=com

- 群组名属性（group_name_attr）: 

  组名称，只有符合user.cfg的通常字符限制的条目才会同步。组与附加到名称的-$realm域同步，以避免命名冲突。请确保同步不会覆盖手动创建的组

- 用户类（user_classes）: 根据LDAP用户类筛选
- 群组对象类（group_classes）: 根据LDAP群组类筛选
- 用户筛选（filter）: 用于针对特定用户的更多筛选器选项。
- 群组筛选器（group_filter）: 有关针对特定组的更多筛选器选项。


筛选器允许您创建一组其他匹配条件，以缩小同步范围。有关可用 LDAP 筛选器类型及其用法的信息，请访问 ldap.com。

**同步选项**

- 范围：要同步的内容的范围。它可以是用户、组或一起。

- 启用新用户： 如果设置，则新同步的用户将启用并可以登录。默认值为 true。

- 完整：如果设置，同步将使用LDAP目录作为真值来源，覆盖在user.cfg中手动设置的信息，并在Proxmox VE上删除不在LDAP目录中的用户和组。如果未设置，则只会将新数据写入配置，不会删除陈旧用户


- 清除： 如果设置，同步会在删除用户和组时删除所有相应的 ACL。仅在勾选了'完整'时生效。

- 预览： 不会将任何数据写入配置。如果您想要查看哪些用户和组将同步到user.cfg，这将非常有用。在单击界面中的预览时设置。

## 14.5.6. OpenID Connect

主要的 OpenID Connect 配置选项包括：

- 发行人URL：
  
  这是授权服务器的 URL。Proxmox使用OpenID Connect Discovery协议来自动配置更多详细信息。

  虽然可以使用未加密的 http:// URL，但我们强烈建议使用加密 https://URL连接。

- 领域: 取一个领域名

- 客户端ID： OpenID 客户端ID

- 客户端密钥：OpenID 客户端密钥

- 自动创建用户：如果用户不存在，则自动创建用户。虽然身份验证是在 OpenID 服务器上完成的，但所有用户仍然需要 Proxmox VE 用户配置中的条目。您可以手动添加它们，也可以使用自动创建选项自动添加新用户。

- 用户名声明： 用于生成唯一用户名（主题用户名或电子邮件）的 OpenID 声明。

**用户名映射**

OpenID Connect 规范定义了一个唯一属性 （`claim` ）叫做`subject`。默认情况下，我们使用此属性的值来生成Proxmox VE用户名，只需添加@和领域名称：`${subject}@${realm}`

不幸的是，大多数OpenID服务器使用随机字符串作为`subject`，如DGH76OKH34BNG3245SB，因此典型的用户名看起来像DGH76OKH34BNG3245SB@yourrealm。虽然不会重复，但人类很难记住这些随机字符串，因此完全不可能将真实用户与此相关联。

`username-claim `设置允许您使用其他属性进行用户名映射。如果 OpenID Connect 服务器提供该属性并保证其唯一性，则最好将其设置为`username`。

另外一个选项就是使用`email`属性，这也能产生友好的用户名。同样，仅当服务器保证此属性的唯一时，才使用此设置。

**示例**

下面是使用 Google 创建 OpenID 域的示例。您需要将 --client-id 和 --client-key 替换为 Google OpenID 设置中的值。

```
pveum realm add myrealm1 --type openid --issuer-url  https://accounts.google.com --client-id XXXX --client-key YYYY --username-claim email
```

上述命令使用`--username-claim email`,这样Proxmox VE上的用户名就会像这样` example.user@google.com@myrealm1`

Keycloak (https://www.keycloak.org/)是一个流行的开源身份和访问管理工具，它支持OpenID Connect。在以下示例中，您需要将 --issuer-url 和 --client-id 替换为您的信息

`pveum realm add myrealm2 --type openid --issuer-url  https://your.server:8080/auth/realms/your-realm --client-id XXX --username-claim username`

使用--username-claim username 允许Proxmox VE使用`username`作为用户名，像这样 example.user@myrealm2.

注意！您需要确保不允许用户自己编辑用户名设置（在密钥保护服务器上）。




