# 3.11. 证书管理

## 3.11.1. 集群内通信的证书

默认情况下，每个 Proxmox VE 集群都会创建自己的（自签名）证书颁发机构 （CA），并为每个节点生成一个证书，该证书由上述 CA 签名。这些证书用于与集群的 pveproxy 服务和命令行管理程序/控制台功能（如果使用 SPICE）进行加密通信。

CA 证书和密钥存储在 Proxmox Cluster File System （pmxcfs） 中。

## 3.11.2. API 和 Web GUI 的证书

REST API 和 Web GUI 由 pveproxy 服务提供，该服务在每个节点上运行。

对于 pveproxy 使用的证书，您有以下选项：

- 1. 默认情况下，使用 /etc/pve/nodes/NODENAME/pve-ssl.pem 中特定于节点的证书。此证书由群集 CA 签名，因此浏览器和操作系统不会自动信任此证书。

- 2. 使用外部提供的证书（例如，由商业 CA 签名）。

- 3. 使用ACME（Let's Encrypt）获得具有自动续订功能的可信证书，这也集成在Proxmox VE API和Webinterface中。

对于选项 2 和 3，使用文件 /etc/pve/local/pveproxy-ssl.pem和 /etc/pve/local/pveproxy-ssl.key（私钥需要没有密码）。

**注意**
请记住，/etc/pve/local 是指向 /etc/pve/nodes/NODENAME 的特定于节点的符号链接。

证书使用 Proxmox VE 节点管理命令进行管理（参见 pvenode（1） 手册页）。

```
请勿替换或手动修改 /etc/pve/local/pve-ssl.pem 和 /etc/pve/local/pve-ssl.key中自动生成的节点证书文件，也不要替换或手动修改 /etc/pve/pve-root-ca.pem 和 /etc/pve/priv/pve-root-ca.key中的群集 CA 文件。
```

## 3.11.3. 上传自定义证书

如果您已经有一个要用于Proxmox VE节点的证书，您只需通过Web界面上传该证书即可。

请注意，证书密钥文件（如果提供）不得受密码保护。

## 3.11.4. 通过 Let's Encrypt （ACME） 获得的可信证书

Proxmox VE包括Automatic Certificate Management Environment ACME协议的实现，允许Proxmox VE管理员使用像Let's Encrypt这样的ACME提供程序，以便轻松设置TLS证书，这些证书在现代操作系统和Web浏览器上是开箱即用的接受和信任的。

目前，实现的两个 ACME 终结点是 Let's Encrypt （LE） 生产及其过渡环境。我们的 ACME 客户端支持使用内置 Web 服务器验证 http-01 挑战，并使用支持所有 DNS API 端点的 DNS 插件验证 dns-01 挑战，acme.sh就是做的。

### acme账户
您需要向要使用的终端节点注册每个集群的 ACME 帐户。用于该帐户的电子邮件地址将用作来自 ACME 终结点的续订到期通知或类似通知的联系点。

您可以通过 Web 界面"数据中心-> ACME"或使用 pvenode 命令行工具注册和停用 ACME 帐户。

```
 pvenode acme account register account-name mail@example.com
```
**注意**
由于速率限制，您应该使用 LE 暂存进行实验，或者如果您是第一次使用 ACME。

### ACME 插件
ACME插件任务是提供自动验证，证明您以及您操作下的Proxmox VE集群是域的真正所有者。这是自动证书管理的基础构建基块。

ACME 协议指定不同类型的挑战，例如 http-01，其中 Web 服务器提供具有特定内容的文件以证明它控制域。有时这是不可能的，要么是因为技术限制，要么是因为无法从公共互联网访问记录的地址。在这些情况下，可以使用 dns-01挑战。通过在域的区域中创建特定的 DNS 记录，可以应对此挑战。

Proxmox VE开箱即用地支持这两种挑战类型，您可以通过数据中心->ACME下的Web界面或使用pvenode acme插件add命令配置插件。

ACME 插件配置存储在 /etc/pve/priv/acme/plugins.cfg。插件可用于群集中的所有节点。

### 节点域

每个域都是特定于节点的。您可以在"节点 ->证书"下或使用 pvenode config 命令添加新的域条目或管理现有域条目。

screenshot/gui-node-certs-add-domain.png
为节点配置所需的域并确保选择了所需的 ACME 帐户后，可以通过 Web 界面订购新证书。成功后，接口将在 10 秒后重新加载。

续订将自动进行


## 3.11.5. ACME HTTP 挑战插件

始终有一个隐式配置的独立插件，用于通过端口 80 上生成的内置 Web 服务器验证 http-01 挑战。独立名称意味着它可以自己提供验证，而无需任何第三方服务。因此，此插件也适用于群集节点。

有一些先决条件，可以使用它与Let's Encrypts ACME进行证书管理。

- 您必须接受Let's Encrypt的ToS才能注册一个帐户。

- 节点的端口 80 需要可从互联网访问。

- 端口 80 上不得有其他侦听器。

- 请求的（子）域需要解析为节点的公共 IP。

## 3.11.6. ACME DNS API 挑战插件

在无法或不希望通过 http-01 方法进行外部访问以进行验证的系统上，可以使用 dns-01 验证方法。此验证方法需要一个允许通过 API 预配 TXT 记录的 DNS 服务器。


### 配置用于验证的 ACME DNS API

Proxmox VE重用了为 acme.sh[4]项目开发的DNS插件，有关特定API配置的详细信息，请参阅其文档。

使用 DNS API 配置新插件的最简单方法是使用 Web 界面（数据中心 -> ACME）。

选择 DNS 作为质询类型。然后，您可以选择您的 API 提供商，输入凭据数据以通过其 API 访问您的帐户。

请参阅 acme.sh 如何使用 DNS API wiki，了解有关获取提供商的 API 凭据的更多详细信息。

由于有许多DNS提供商和API端点，Proxmox VE会自动为某些提供商的凭据生成表单。对于其他人，您将看到一个更大的文本区域，只需复制其中的所有凭据KEY=VALUE对即可。

### 通过别名进行 DNS 验证
可以使用特殊的别名模式来处理不同域/DNS 服务器上的验证，以防您的主/真实 DNS 不支持通过 API 进行预配。手动为指向 _acme-challenge.domain2.example _acme-challenge.domain1.example 设置永久 CNAME 记录，并将 Proxmox VE 节点配置文件中的别名属性设置为 domain2.example，以允许 domain2.example 的 DNS 服务器验证 domain1.example 的所有质询。

### 插件组合
如果您的节点可以通过具有不同要求/DNS配置功能的多个域访问，则可以将 http-01 和 dns-01 验证相结合。通过为每个域指定不同的插件实例，也可以混合使用来自多个提供商或实例的 DNS API。通过多个域访问同一服务会增加复杂性，应尽可能避免使用。

## 3.11.7. 自动续订 ACME 证书

如果已使用 ACME 提供的证书（通过 pvenode 或 GUI）成功配置了节点，则该证书将由 pve-daily-update.service 自动续订。目前，如果证书已过期，或者将在接下来的 30 天内过期，则将尝试续订。


## 3.11.8.  pvenode 配置ACME示例

### 例1：使用 Let's Encrypt 证书的示例 pvenode 调用

```
root@proxmox:~# pvenode acme account register default mail@example.invalid
Directory endpoints:
0) Let's Encrypt V2 (https://acme-v02.api.letsencrypt.org/directory)
1) Let's Encrypt V2 Staging (https://acme-staging-v02.api.letsencrypt.org/directory)
2) Custom
Enter selection: 1

Terms of Service: https://letsencrypt.org/documents/LE-SA-v1.2-November-15-2017.pdf
Do you agree to the above terms? [y|N]y
...
Task OK
root@proxmox:~# pvenode config set --acme domains=example.invalid
root@proxmox:~# pvenode acme cert order
Loading ACME account details
Placing ACME order
...
Status is 'valid'!

All domains validated!
...
Downloading certificate
Setting pveproxy certificate and key
Restarting pveproxy
Task OK
```
### 例2：设置用于验证域的 OVH API
无论使用哪个插件，帐户注册步骤都是相同的，并且此处不再重复。
根据 OVH API 文档，需要从 OVH 获取OVH_AK和OVH_AS
首先，您需要获取所有信息，以便您和Proxmox VE可以访问API。

```
root@proxmox:~# cat /path/to/api-token
OVH_AK=XXXXXXXXXXXXXXXX
OVH_AS=YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY
root@proxmox:~# source /path/to/api-token
root@proxmox:~# curl -XPOST -H"X-Ovh-Application: $OVH_AK" -H "Content-type: application/json" \
https://eu.api.ovh.com/1.0/auth/credential  -d '{
  "accessRules": [
    {"method": "GET","path": "/auth/time"},
    {"method": "GET","path": "/domain"},
    {"method": "GET","path": "/domain/zone/*"},
    {"method": "GET","path": "/domain/zone/*/record"},
    {"method": "POST","path": "/domain/zone/*/record"},
    {"method": "POST","path": "/domain/zone/*/refresh"},
    {"method": "PUT","path": "/domain/zone/*/record/"},
    {"method": "DELETE","path": "/domain/zone/*/record/*"}
]
}'
{"consumerKey":"ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ","state":"pendingValidation","validationUrl":"https://eu.api.ovh.com/auth/?credentialToken=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"}

(open validation URL and follow instructions to link Application Key with account/Consumer Key)

root@proxmox:~# echo "OVH_CK=ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" >> /path/to/api-token
```
现在，您可以设置 ACME 插件：
```
root@proxmox:~# pvenode acme plugin add dns example_plugin --api ovh --data /path/to/api_token
root@proxmox:~# pvenode acme plugin config example_plugin
┌────────┬──────────────────────────────────────────┐
│ key    │ value                                    │
╞════════╪══════════════════════════════════════════╡
│ api    │ ovh                                      │
├────────┼──────────────────────────────────────────┤
│ data   │ OVH_AK=XXXXXXXXXXXXXXXX                  │
│        │ OVH_AS=YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY  │
│        │ OVH_CK=ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ  │
├────────┼──────────────────────────────────────────┤
│ digest │ 867fcf556363ca1bea866863093fcab83edf47a1 │
├────────┼──────────────────────────────────────────┤
│ plugin │ example_plugin                           │
├────────┼──────────────────────────────────────────┤
│ type   │ dns                                      │
└────────┴──────────────────────────────────────────┘
```
最后，您可以配置要为其获取证书的域并为其下达证书顺序：
```
root@proxmox:~# pvenode config set -acmedomain0 example.proxmox.com,plugin=example_plugin
root@proxmox:~# pvenode acme cert order
Loading ACME account details
Placing ACME order
Order URL: https://acme-staging-v02.api.letsencrypt.org/acme/order/11111111/22222222

Getting authorization details from 'https://acme-staging-v02.api.letsencrypt.org/acme/authz-v3/33333333'
The validation for example.proxmox.com is pending!
[Wed Apr 22 09:25:30 CEST 2020] Using OVH endpoint: ovh-eu
[Wed Apr 22 09:25:30 CEST 2020] Checking authentication
[Wed Apr 22 09:25:30 CEST 2020] Consumer key is ok.
[Wed Apr 22 09:25:31 CEST 2020] Adding record
[Wed Apr 22 09:25:32 CEST 2020] Added, sleep 10 seconds.
Add TXT record: _acme-challenge.example.proxmox.com
Triggering validation
Sleeping for 5 seconds
Status is 'valid'!
[Wed Apr 22 09:25:48 CEST 2020] Using OVH endpoint: ovh-eu
[Wed Apr 22 09:25:48 CEST 2020] Checking authentication
[Wed Apr 22 09:25:48 CEST 2020] Consumer key is ok.
Remove TXT record: _acme-challenge.example.proxmox.com

All domains validated!

Creating CSR
Checking order status
Order is ready, finalizing order
valid!

Downloading certificate
Setting pveproxy certificate and key
Restarting pveproxy
Task OK
```
### 例3 从暂存目录切换到常规 ACME 目录

不支持更改帐户的 ACME 目录，但由于 Proxmox VE 支持多个帐户，因此您只需创建一个以生产（受信任的）ACME 目录作为终结点的新帐户。您还可以停用暂存帐户并重新创建它。

### 例4 使用 pvenode 将默认 ACME 帐户从暂存更改为目录

```
root@proxmox:~# pvenode acme account deactivate default
Renaming account file from '/etc/pve/priv/acme/default' to '/etc/pve/priv/acme/_deactivated_default_4'
Task OK

root@proxmox:~# pvenode acme account register default example@proxmox.com
Directory endpoints:
0) Let's Encrypt V2 (https://acme-v02.api.letsencrypt.org/directory)
1) Let's Encrypt V2 Staging (https://acme-staging-v02.api.letsencrypt.org/directory)
2) Custom
Enter selection: 0

Terms of Service: https://letsencrypt.org/documents/LE-SA-v1.2-November-15-2017.pdf
Do you agree to the above terms? [y|N]y
...
Task OK
```
