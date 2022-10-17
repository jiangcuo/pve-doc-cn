# 7.8 Proxmox  备份服务器

存储池类型：pbs

此后端允许将Proxmox备份服务器直接集成到Proxmox VE中，就像任何其他存储类型一样。pbs存储可以直接通过Proxmox VE api，cli或者web界面上直接添加。

## 7.8.1 配置

后端存储支持全部的公共存储服务属性，但 shared 标识例外。此外具有以下特殊属性：

- server

服务器的IP或者DNS名称，必填。

- usernmae
  
Proxmox备份服务器的用户名，必填。

提示：不要忘记将领域添加到用户名中。例如，root@pam或archiver@pbs。

- password

用户的密码，该值将保存在 `/etc/pve/priv/storage/<STORAGE-ID>.pw` 下的文件中，并且访问权限仅限于 root 用户。必填。

- datastore

要使用的 Proxmox 备份服务器数据存储的 ID。必填。

- fingerprint

Proxmox Backup Server API TLS 证书的指纹。您可以在服务器仪表板中或使用 `proxmox-backup-manager cert info `命令获取它。对于自签名证书或不被主机信任的ca证书，都需要。

- encryption-key

用于从客户端加密备份数据的密钥。目前仅支持非密码保护（无密钥派生函数 （kdf））。将保存在` /etc/pve/priv/storage/<STORAGE-ID>.enc` 下的文件中，访问权限仅限于 root 用户。使用 `proxmox-backup-client key create --kdf none <path> `自动生成一个新值。可选。

- master-pubkey

用于在备份任务中加密备份加密密钥的公用 RSA 密钥。加密的副本将附加到备份中，并存储在Proxmox备份服务器实例上以进行恢复。可选，需要加密密钥。

配置示例（`/etc/pve/storage.cfg`)
```
pbs: backup
        datastore main
        server enya.proxmox.com
        content backup
        fingerprint 09:54:ef:..snip..:88:af:47:fe:4c:3b:cf:8b:26:88:0b:4e:3c:b2
        maxfiles 0
        username archiver@pbs
```
## 7.8.2. 存储功能

|数据类型 |镜像格式 |支持共享| 支持快照 |支持链接克隆|
|-----|-----|-----|----|-----|
|虚拟机备份|否|是|否|否|


## 7.8.3. 加密

（可选）您可以在 GCM 模式下使用 AES-256 配置客户端加密。加密可以通过 Web 界面进行配置，也可以使用加密密钥选项在 CLI 上进行配置（见上文）。密钥将保存在文件 /etc/pve/priv/storage/<STORAGE-ID>.enc 中，该文件只能由 root 用户访问。

注意：

如果没有其密钥，将无法访问备份。因此，您应该将密钥保持有序，并且与要备份的内容分开。例如，您可能会使用整个系统上的密钥备份整个系统。如果系统由于任何原因而无法访问并且需要恢复，则这是不可能的，因为加密密钥将与损坏的系统一起丢失。


建议您确保密钥安全，但易于访问，以便快速灾难恢复。因此，将其存储在密码管理器中的最佳位置，可以立即恢复。作为对此的备份，您还应该将密钥保存到USB驱动器并将其存储在安全的地方。这样，它可以与任何系统分离，使在紧急情况下能够很容易恢复。最后，为了应对最坏的情况，您还应该考虑将钥匙的纸质副本锁在安全的地方。`paperkey` 子命令可用于创建密钥的 QR 编码版本。以下命令将 `paperkey` 命令的输出发送到文本文件，以便于打印。

```
proxmox-backup-client key paperkey /etc/pve/priv/storage/<STORAGE-ID>.enc --output-format text > qrkey.txt
```


此外，还可以使用单个 RSA 主密钥对进行密钥恢复：将执行加密备份的所有客户端配置为使用单个公钥，并且所有后续加密备份将包含已用 AES 加密密钥的 RSA 加密副本。相应的私有主密钥允许恢复 AES 密钥并解密备份，即使客户端系统不再可用。


注意：与常规加密密钥一样，主密钥对的安全保存规则也适用。没有私钥的副本，恢复是不可能的！paperkey 命令支持生成私有主密钥的纸质副本，以便存储在安全的物理位置。

由于加密是在客户端管理的，因此您可以在服务器上使用相同的数据存储进行未加密的备份和加密的备份，即使它们是使用不同的密钥加密的。但是，在具有不同密钥的备份之间进行重复数据删除是不可能的，因此通常最好创建单独的数据存储。

提示：如果加密没有好处，请不要使用加密，例如，当您在受信任的网络中本地运行服务器时。从未加密的备份中恢复总是更容易。



## 7.8.4. 示例：通过 CLI 添加存储

然后，您可以使用以下命令将此共享作为存储添加到整个 Proxmox VE 集群中：

```
pvesm add pbs <id> --server <server> --datastore <datastore> --username <username> --fingerprint 00:B4:... --password
```