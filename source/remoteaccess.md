# 第六章 使用vGPU 

## Windows系统

Windows系统需要使用OS内部的远程显示协议，才能够使用vGPU硬件。

Proxmox VE控制台只能输出集成的虚拟vga图像，并且不能做解码编码。

所以需要一些特定的远程显示协议：

- VNC
- Parsec
- RustDesk
- sunshine
- todesk
- 向日葵
- ......


## Linux 系统

Proxmox VE控制台只能输出集成的虚拟vga图像，并且不能做解码编码。

所以需要一些特定的远程显示协议：

- VNC
- RustDesk
- todesk

如果并不是作为桌面使用，那么无需远程显示协议。


