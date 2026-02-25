#!/bin/bash
# Debian 12 安装 Proxmox VE 8 (PVE) 一键脚本

# 1. 设置非交互模式，避免 postfix 安装时弹出提示框卡住脚本执行进程 [6]
export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none

# 2. 自动获取本机的主 IPv4 地址 (排除 127.0.0.1)
IPV4=$(ip -4 route get 8.8.8.8 | awk '{print $7}' | tr -d '\n')
HOSTNAME="pve01"

# 检查当前是否为第二阶段（重启后）的继续执行
if [ ! -f /root/.pve_stage2 ]; then
    echo "================================================="
    echo " 第一阶段：环境准备、替换源与安装 PVE 专属内核"
    echo "================================================="

    # 修改主机名
    hostnamectl set-hostname $HOSTNAME

    # 将主机名与真实 IP 的映射写入 /etc/hosts，避免解析为回环地址导致面板报错
    sed -i '/127.0.1.1/d' /etc/hosts
    if ! grep -q "$IPV4 $HOSTNAME" /etc/hosts; then
        echo "$IPV4 $HOSTNAME" >> /etc/hosts
    fi
    
    echo "当前主机名解析结果: $(hostname --ip-address) (结果不能为127.0.0.1)"

    # 添加 PVE 官方仓库并下载 GPG 密钥
    echo "deb [arch=amd64] http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-install-repo.list
    wget https://enterprise.proxmox.com/debian/proxmox-release-bookworm.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg

    # 更新软件包列表并升级当前系统包
    apt update && apt full-upgrade -y

    # 安装 PVE 专属内核
    apt install proxmox-default-kernel -y

    # 创建第二阶段标志文件，供重启后脚本判断进度
    touch /root/.pve_stage2

    echo "================================================="
    echo " 第一阶段执行完毕！系统即将重启以加载 PVE 内核。"
    echo " 重启完成后，请重新连接 SSH 并再次运行本脚本。"
    echo " 倒计时 5 秒后自动重启..."
    echo "================================================="
    sleep 5
    systemctl reboot
else
    echo "================================================="
    echo " 第二阶段：安装 PVE 软件包与清理工作"
    echo "================================================="

    # 安装 PVE 核心软件包及相关依赖 (结合之前的免交互设定，自动处理 postfix)
    apt install proxmox-ve postfix open-iscsi chrony -y

    # 移除原生的 Debian 默认旧内核及 os-prober 避免冲突 [1]
    apt remove linux-image-amd64 'linux-image-6.1*' -y
    apt remove os-prober -y

    # 更新 GRUB 引导记录，确保以 PVE 专用内核启动 [1]
    update-grub

    # 清除阶段标志文件
    rm -f /root/.pve_stage2

    echo "================================================="
    echo " Proxmox VE 安装完成！"
    echo " 您现在可以使用以下地址连接到 Proxmox VE 的 Web 管理界面 [1]："
    echo " https://$IPV4:8006"
    echo " 请使用用户名 'root' 和您的系统 root 密码进行登录。"
    echo "================================================="
fi