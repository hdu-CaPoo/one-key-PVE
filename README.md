# PVE 一键安装脚本 (Debian 12)

本脚本用于在 **Debian 12** 系统上一键安装 Proxmox VE (PVE)。它会自动完成修改主机名、添加 PVE 源、免交互安装组件、加载专用内核并清理旧内核等繁杂操作。

> **⚠️ 重要提醒**：请务必在**纯净版 Debian 12** 环境下运行。如果使用的是服务商默认系统，建议先通过 DD 脚本重装一次，否则安装 PVE 后极易出现网卡丢失、机器失联的情况！

```bash
wget --no-check-certificate -qO InstallNET.sh 'https://raw.githubusercontent.com/leitbogioro/Tools/master/Linux_reinstall/InstallNET.sh' && chmod a+x InstallNET.sh

bash InstallNET.sh -debian 12 -port 22 -pwd yourspassword #请将yourspassword改为你自己的root密码


#1.修改 vps 主机名
```

## 🚀 使用方法

由于安装 PVE 必须重启加载新内核，本脚本分为**两次运行**：

### 1. 运行第一阶段
将脚本保存到服务器并执行：
```bash
wget 
bash install.sh
```
> **注意**：执行完毕后，脚本会倒计时 5 秒并**自动重启服务器**。此时 SSH 连接会断开。

### 2. 运行第二阶段
等待机器重启开机后，**重新连接 SSH**，并在原目录**再次运行该脚本**：
```bash
bash install.sh
```
脚本会自动接续执行剩余的软件包安装与旧内核清理工作。

### 3. 登录面板
终端提示安装完成后，在浏览器中访问管理后台：
* **后台地址**：`https://你的服务器IP:8006`
* **用户名**：`root`
* **密 码**：你的系统 root 密码
