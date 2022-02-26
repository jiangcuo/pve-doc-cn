2.2使用安装介质
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

可以从http://www.proxmox.com/en/downloads/category/iso-images-pve下载ISO镜像。

目前官方提供的Proxmox VE安装介质是一种混合型的ISO镜像。有两种使用方法：
- 将ISO镜像烧录到CD上使用
- 将裸区块镜像（IMG）文件直接复制到闪存介质上（USB盘）

用U盘安装Proxmox VE不仅速度快而且更加方便，也是推荐使用的安装方式。

2.2.1 使用一个U盘作为安装介质
------------------------------------------

U盘需要至少有1 GB的可用存储。

**注意**
不要用UNetbootin或Rufus。

**重要**
请确保U盘没有被挂载，并且没有任何重要数据。


2.2.2 GNU/Linux下的制作过程
---------------------------------------

你可以直接用dd命令制作U盘镜像。首先下载ISO镜像，然后将U盘插入计算机。找出U盘的设备名，然后运行如下命令：

``dd if=proxmox-ve_* .iso of=/dev/XYZ bs=1M``

**注意**
请用正确的设备名替换上面命令中的/dev/XZY。

**警告**
请务必小心，不要把硬盘数据覆盖掉！

如何找到U盘的设备名

你可以比较U盘插入计算机前后dmesg命令输出的最后一行内容，也可以用lsblk。

打开命令行终端，运行命令

``lsblk``

然后将U盘插入计算机，再次运行命令

``lsblk``

你会发现有新的设备，这个新设备就是你所要操作的U盘。

2.2.3 OSX下的制作过程
-----------------------------------
打开命令行终端（在Spotlight中query Terminal）。

用hdiutil的convert选项将.iso文件转换为.img格式，示例如下。

``hdiutil convert  -format  UDRW  -o  proxmox-ve_*.dmg  proxmox-ve_*.iso``

**提示**
OS X倾向于自动为输出文件增加.dmg后缀名。

运行命令获取当前设备列表：

``diskutil list``

然后将U盘插入计算机，再次运行命令，获取分配给U盘的设备节点名称（例如 /dev/diskX）。
``diskutil list``

``diskutil unmountDisk /dev/diskX``

**注意**
用前面命令中返回的设备序号替换X。

``sudo dd if=proxmox-ve_*.dmg of=/dev/rdiskX bs=1m``

**注意**
前面命令使用了rdiskX而不是diskX，这可以提高写入速度。


2.2.4 Windows下的制作过程
--------------------------------------
使用Etcher
>>>>>>>>>>>>>>>>>>>>
从https://etcher.io下载Etcher，选择ISO和你的U盘。

如不成功，可改用OSForenics USB installer，下载地址为http://www.osforensics.org/portability.html

使用Rufus
>>>>>>>>>>>>>>>>>>>>
Rufus是一个更轻量级的替代方案，但您需要使用DD模式才能使其工作。从https://rufus.ie/下载Rufus。要么直接安装，要么使用便携版本。选择目标驱动器和Proxmox VE ISO文件。

**重要**
启动后，您必须在要求下载不同版本的GRUB的对话框中单击否。在下一个对话框中，选择DD模式。