# LMAE: Linux Mint Arch Edition
*创建您自己的基于 Arch Linux 的发行版的综合指南*
*具有 Linux Mint 的优雅*

## 目录

- [介绍](#介绍)
- [第1章：基础 - 安装 Arch Linux](#第1章基础---安装-arch-linux)
  - [1.1 准备基础](#11-准备基础)
  - [1.2 初始系统配置](#12-初始系统配置)
  - [1.3 分区的艺术](#13-分区的艺术)
  - [1.4 优化镜像（可选但推荐）](#14-优化镜像可选但推荐)
  - [1.5 安装系统核心](#15-安装系统核心)
  - [1.6 新安装系统的配置](#16-新安装系统的配置)
  - [1.7 GRUB 引导加载器](#17-grub-引导加载器)
  - [1.8 首次启动](#18-首次启动)
- [第2章：转变 - 创建桌面环境](#第2章转变---创建桌面环境)
  - [2.1 准备阶段](#21-准备阶段)
  - [2.2 安装视觉组件](#22-安装视觉组件)
  - [2.3 基本配置](#23-基本配置)
  - [2.4 启用 AUR - Arch 的魔法](#24-启用-aur---arch-的魔法)
  - [2.5 视觉变身 - 使其看起来像 Linux Mint](#25-视觉变身---使其看起来像-linux-mint)
  - [2.6 附加功能](#26-附加功能)
- [第3章：完成体验 - Linux Mint 应用程序](#第3章完成体验---linux-mint-应用程序)
  - [3.1 生产力应用程序和实用工具](#31-生产力应用程序和实用工具)
  - [3.2 互联网和通信应用程序](#32-互联网和通信应用程序)
  - [3.3 办公套件](#33-办公套件)
  - [3.4 开发工具](#34-开发工具)
  - [3.5 多媒体](#35-多媒体)
  - [3.6 管理工具](#36-管理工具)
  - [3.7 配置和偏好](#37-配置和偏好)
  - [3.8 系统工具和命令行](#38-系统工具和命令行)
  - [3.9 笔记本优化（可选）](#39-笔记本优化可选)
- [结论](#结论)
- [系统维护](#系统维护)

---

## 介绍

本指南解释了如何将 Arch Linux 的坚实滚动发布基础与 Cinnamon 桌面环境和 Linux Mint 应用程序相结合。结果是一个保持 Arch 灵活性的系统，同时提供 Linux Mint 的视觉和功能体验。

过程分为三个主要阶段：
- Arch Linux 安装
- Cinnamon 桌面环境配置
- 安装 Linux Mint 的特色应用程序

每个部分包括必要命令和配置的清晰解释。

# 第1章：基础 - 安装 Arch Linux

安装 Arch Linux 将是系统的基石。

虽然 Arch 以复杂著称，但按照这些步骤依次操作可以使过程相当简单。

## 1.1 准备基础

### 下载安装映像

从官方 Arch Linux 网站下载最新的 ISO 映像：[https://archlinux.org/download/](https://archlinux.org/download/)。

确保使用官方版本以避免安全问题。

### 创建安装媒体

下载 ISO 后，使用以下工具之一将其刻录到 USB 或 DVD：
- **balenaEtcher**：直观且跨平台
- **Rufus**：快速且高效的 Windows 工具
- **Win32 Disk Imager**：经典且可靠的选项

### 从安装媒体启动

从您刚创建的 USB 或 DVD 启动计算机。

这可能需要更改 BIOS/UEFI 中的启动顺序。

## 1.2 初始系统配置

### 将键盘调整为您的语言

默认情况下，键盘配置为英语。要更改它，首先列出可用的键盘映射：
```bash
ls /usr/share/kbd/keymaps/**/*.map.gz
```

然后应用您需要的映射。例如，对于英国键盘：
```bash
loadkeys uk
```

> **注意：** 其他常见布局：`de`（德语）、`fr`（法语）、`es`（西班牙语）、`us`（美国英语）。

### 验证互联网连接

Arch Linux 在安装期间需要互联网连接以下载软件包。
验证您的网络接口是否可用：
```bash
ip link
```

如果使用 Wi-Fi，请使用以下命令配置：
```bash
iwctl
```

按照屏幕上的说明连接到您的网络。

确认连接正常工作：
```bash
ping 8.8.8.8
```

如果您看到响应，则连接正常工作。

### 同步系统时钟

使用互联网时间服务器设置正确时间，以避免安全证书问题：

```bash
timedatectl set-ntp true
```

### 识别启动模式

现代系统可以以 UEFI 或传统 BIOS 模式启动。识别您使用的是哪种：

```bash
ls /sys/firmware/efi/efivars
```

如果命令显示文件，则您处于 UEFI 模式。如果显示“没有此类文件”，则您处于传统 BIOS 模式。此信息对于以下步骤很重要。

## 1.3 分区的艺术

分区需要注意和小心，以避免数据丢失。

### 识别您的磁盘

列出所有可用磁盘：

```bash
fdisk -l
```

识别您的主磁盘：通常是 `/dev/sda`（SATA/IDE 磁盘）、`/dev/nvme0n1`（NVMe 磁盘）或 `/dev/mmcblk0`（SD/eMMC 卡）。

**仔细验证哪个是您的目标磁盘**，然后继续。

### 创建分区

我们将使用 GPT 分区方案。配置取决于启动模式：

**对于 UEFI 系统与 GPT：**
- `/dev/sda1`：EFI 系统，1024 MiB 或更多，挂载：`/mnt/boot`
- `/dev/sda2`：Linux swap，请参见注释，挂载：（swap）
- `/dev/sda3`：Linux 文件系统，其余磁盘，挂载：`/mnt`

**对于 BIOS 系统与 GPT：**
- `/dev/sda1`：BIOS 引导，8 MiB，挂载：（未挂载）
- `/dev/sda2`：EFI 引导，1024 MiB 或更多，挂载：`/mnt/boot`
- `/dev/sda3`：Linux swap，请参见注释，挂载：（swap）
- `/dev/sda4`：Linux 文件系统，其余磁盘，挂载：`/mnt`

**对于 BIOS 系统与 MBR（DOS 分区表）：**
- `/dev/sda1`：引导加载器，1024 MiB 或更多，挂载：`/mnt/boot`
- `/dev/sda2`：Linux swap，请参见注释，挂载：（swap）
- `/dev/sda3`：Linux，其余磁盘，挂载：`/mnt`

**Swap 大小建议：**
- **RAM 最多 4 GB**：Swap = 1.5 × RAM（如果想要休眠）或等于 RAM（没有休眠）
- **4-16 GB RAM**：4 GB swap 通常足够
- **超过 16 GB RAM**：4 GB + (0.1 × 总 RAM) 是一个很好的通用规则
- **推荐最小值**：任何情况下 2 GB

> **注意：** 挂载点 `/mnt` 和 `/mnt/boot` 是安装环境的特定点。一旦系统安装，它们将被挂载为 `/` 和 `/boot`。

打开 `cfdisk` 创建分区：

```bash
cfdisk /dev/sda
```

> **注意：** 将 `/dev/sda` 替换为您的磁盘。

cfdisk 中的步骤：
1. 如果磁盘为空，选择表类型：
   - **"gpt"** 用于 UEFI 或现代 BIOS 系统（推荐）
   - **"msdos"** 仅用于需要 MBR 的旧 BIOS 系统
2. 根据您的启动模式方案创建分区
3. 为每个分区分配正确的类型
4. 写入更改并退出

### 格式化分区

使用适当的文件系统格式化分区：

**对于 UEFI 系统与 GPT：**
```bash
mkfs.fat -F 32 /dev/sda1  # EFI 分区 (FAT32)
mkswap /dev/sda2          # Swap 分区
mkfs.ext4 /dev/sda3       # 主文件系统 (ext4)
```

**对于 BIOS 系统与 GPT：**
```bash
# BIOS 引导分区 (/dev/sda1) 不格式化
mkfs.fat -F 32 /dev/sda2  # EFI 引导分区 (FAT32)
mkswap /dev/sda3          # Swap 分区
mkfs.ext4 /dev/sda4       # 主文件系统 (ext4)
```

**对于 BIOS 系统与 MBR：**
```bash
mkfs.fat -F 32 /dev/sda1  # 引导加载器分区 (FAT32)
mkswap /dev/sda2          # Swap 分区
mkfs.ext4 /dev/sda3       # 主文件系统 (ext4)
```

**关于文件系统的附加信息：**

如果您想探索其他格式化选项，这里是最常见的命令及其推荐选项：

*EFI/ESP 分区（包：dosfstools）：*
```bash
mkfs.fat -F 32 /dev/sdaX               # EFI 分区始终 FAT32 (-F 32)
mkfs.fat -F 32 -n "EFI" /dev/sdaX      # 带卷标 (-n)
```

*Swap 分区（包：util-linux - 包含在 base 中）：*
```bash
mkswap /dev/sdaX                       # 无附加选项
mkswap -L "swap" /dev/sdaX             # 带卷标 (-L)
```

*主文件系统：*

- **ext4**（包：e2fsprogs - 包含在 base 中）- 大多数推荐，稳定且成熟：
```bash
mkfs.ext4 /dev/sdaX                              # 默认选项（推荐）
mkfs.ext4 -L "ArchLinux" /dev/sdaX               # 带卷标 (-L)
mkfs.ext4 -L "ArchLinux" -O metadata_csum,64bit -E lazy_itable_init=0,\
lazy_journal_init=0 /dev/sdaX  # SSD 优化选项
```

- **XFS**（包：xfsprogs）- 适用于大文件和高性能，无法缩小：
```bash
mkfs.xfs /dev/sdaX                               # 默认选项
mkfs.xfs -L "ArchLinux" /dev/sdaX                # 带卷标 (-L)
mkfs.xfs -L "ArchLinux" -m crc=1,finobt=1 /dev/sdaX  # 推荐现代选项
```

- **Btrfs**（包：btrfs-progs）- 现代，具有快照和压缩，需要更多知识：
```bash
mkfs.btrfs /dev/sdaX                             # 默认选项
mkfs.btrfs -L "ArchLinux" /dev/sdaX              # 带卷标 (-L)
mkfs.btrfs -L "ArchLinux" -f /dev/sdaX           # 强制格式化 (-f)
如果分区已有数据
```

*选项解释：*
- `-L` 或 `-n`：设置卷标（用于识别和按标签挂载）
- `-f`：强制格式化，即使有数据（谨慎使用）
- ext4 在 SSD 上：`metadata_csum` 提高完整性，`lazy_*=0` 立即初始化一切
- XFS：`crc=1` 启用元数据校验和，`finobt=1` 改善许多文件的性能

> **注意：** 对于桌面/笔记本，ext4 是最安全和最成熟的选项。

> XFS 为具有大文件的工作站提供良好性能（无法缩小）。

> Btrfs 提供高级功能（快照、压缩、重复数据删除），但需要维护和恢复的更多知识。

**关于 Timeshift 的备份重要考虑：**
- **Btrfs**：Timeshift 可以使用 Btrfs 本机功能创建即时系统快照。这非常快且空间高效。
- **ext4/XFS/其他**：Timeshift 使用 rsync 创建完整文件副本，这消耗更多时间和磁盘空间。

### 挂载分区

挂载分区以使用它们：

**对于 UEFI 系统与 GPT：**
```bash
mount /dev/sda3 /mnt      # 挂载主文件系统
swapon /dev/sda2          # 激活 swap 分区
mkdir /mnt/boot           # 创建 EFI 挂载点
mount /dev/sda1 /mnt/boot # 挂载 EFI 分区
```

**对于 BIOS 系统与 GPT：**
```bash
mount /dev/sda4 /mnt      # 挂载主文件系统
swapon /dev/sda3          # 激活 swap 分区
mkdir /mnt/boot           # 创建 EFI 挂载点
mount /dev/sda2 /mnt/boot # 挂载 EFI 引导分区
# BIOS 引导分区不挂载
```

**对于 BIOS 系统与 MBR：**
```bash
mount /dev/sda3 /mnt      # 挂载主文件系统
swapon /dev/sda2          # 激活 swap 分区
mkdir /mnt/boot           # 创建引导加载器挂载点
mount /dev/sda1 /mnt/boot # 挂载引导加载器分区
```

## 1.4 优化镜像（可选但推荐）

如果软件包下载速度慢，您可以在安装前优化镜像列表：

```bash
pacman -S --needed reflector
reflector --country "China, Japan, South Korea" --age 12 --protocol https \
--sort rate --save /etc/pacman.d/mirrorlist
```

*将 "China, Japan, South Korea" 替换为您位置最近的国家。您可以使用 `reflector --list-countries` 查看完整国家列表。*

**Reflector 自动化（可选）：** 如果您希望每周自动更新镜像，您可以在安装基础系统后启用 reflector 计时器：
```bash
systemctl enable reflector.timer
```

这将每周更新镜像列表。您可以在安装后编辑 `/etc/xdg/reflector/reflector.conf` 来自定义 reflector 选项。

## 1.5 安装系统核心

安装 Arch Linux 基础系统和基本软件包：

**对于 BIOS 系统：**
```bash
pacstrap /mnt base linux linux-firmware networkmanager \
grub vim sudo nano
```

**对于 UEFI 系统（添加 efibootmgr）：**
```bash
pacstrap /mnt base linux linux-firmware networkmanager grub efibootmgr \
vim sudo nano
```

**对于双启动系统（添加 os-prober）：**

如果您有 BIOS：
```bash
pacstrap /mnt base linux linux-firmware networkmanager grub os-prober \
vim sudo nano
```

如果您有 UEFI：
```bash
pacstrap /mnt base linux linux-firmware networkmanager grub efibootmgr \
os-prober vim sudo nano
```

已安装组件：
- **base**：Arch Linux 基础系统
- **linux**：Linux 内核
- **linux-firmware**：常见硬件的固件驱动
- **networkmanager**：网络管理
- **grub**：引导加载器
- **efibootmgr**：管理 UEFI 引导条目的工具（仅 UEFI）
- **os-prober**：检测其他操作系统用于双启动（可选）
- **vim**：高级文本编辑器
- **sudo**：允许以管理权限执行命令
- **nano**：简单文本编辑器

过程可能需要几分钟，取决于您的连接。

## 1.6 新安装系统的配置

### 生成 fstab 文件

`fstab` 文件定义启动时如何挂载分区：

```bash
genfstab -pU /mnt >> /mnt/etc/fstab
```

### 进入新系统

访问新安装的系统：

```bash
arch-chroot /mnt
```

从这里开始，命令在新的 Arch Linux 系统中执行。

### 配置时区

设置您的地理位置。将 "Region" 和 "City" 替换为您的位置：

```bash
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
```

墨西哥城示例：
```bash
ln -sf /usr/share/zoneinfo/America/Mexico_City /etc/localtime
```

同步硬件时钟：
```bash
hwclock --systohc
```

### 语言和本地化配置

编辑 `/etc/locale.gen`（使用 `nano /etc/locale.gen` 或 `vim /etc/locale.gen`）并取消注释您需要的语言。至少包括 `en_US.UTF-8` 和您的本地语言（例如，`es_ES.UTF-8` 或 `es_MX.UTF-8`）。

生成语言：
```bash
locale-gen
```

为您的主要语言创建 `/etc/locale.conf`：
```bash
echo "LANG=en_US.UTF-8" > /etc/locale.conf
```

> **注意：** 您可以使用 `LANG=es_ES.UTF-8` 或其他语言作为您喜欢的。

在 `/etc/vconsole.conf` 中永久配置键盘：
```bash
echo "KEYMAP=la-latin1" > /etc/vconsole.conf
```

### 网络配置

在 `/etc/hostname` 中为您的计算机分配名称：
```bash
echo "my-arch-mint" > /etc/hostname
```

配置 `/etc/hosts`：
```bash
cat >> /etc/hosts << EOF
127.0.0.1      localhost
::1            localhost
127.0.1.1      my-arch-mint
EOF
```

> **注意：** 使用您在 `/etc/hostname` 中放置的相同名称。

### 配置管理员密码

为 root 用户设置密码：
```bash
passwd
```

### 可选 pacman 配置

**在 pacman 中启用颜色：**

编辑 `/etc/pacman.conf` 并取消注释 Color 行：
```bash
nano /etc/pacman.conf
```

查找并取消注释（删除 `#`）：
```ini
# Misc options
#UseSyslog
Color
#NoProgressBar
```

**启用 multilib 仓库（用于 32 位应用程序）：**

如果您计划使用 32 位应用程序、Steam、Wine 或一些游戏，您需要启用 multilib。

在同一个 `/etc/pacman.conf` 文件中，在文件末尾取消注释这些行：
```ini
[multilib]
Include = /etc/pacman.d/mirrorlist
```

然后更新软件包数据库：
```bash
pacman -Syu
```

> **注意：** Multilib 对于 Steam、Wine、一些专有 32 位应用程序和游戏的 32 位图形驱动是必需的。

## 1.7 GRUB 引导加载器

GRUB 允许系统启动。安装因启动模式而异：

### 对于传统 BIOS 系统

```bash
grub-install --verbose --target=i386-pc /dev/sda
```

> **注意：** 将 `/dev/sda` 替换为您的磁盘（不带分区号）。

### 对于 UEFI 系统

```bash
grub-install --verbose --target=x86_64-efi --efi-directory=/boot
--bootloader-id=GRUB
```

### 启用微码更新

现代处理器受益于微码更新以提高稳定性和安全性：

**对于 Intel 处理器：**
```bash
pacman -S intel-ucode
```

- **intel-ucode**：Intel 处理器的微码更新

**对于 AMD 处理器：**
```bash
pacman -S amd-ucode
```

- **amd-ucode**：AMD 处理器的微码更新

### 生成最终 GRUB 配置

```bash
grub-mkconfig -o /boot/grub/grub.cfg
```

**如果您为双启动安装了 `os-prober`**，请先启用它：
```bash
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
```

命令应该检测您的 Arch Linux 系统和任何其他已安装的操作系统。

## 1.8 首次启动

启动新系统：

```bash
exit                    # 退出 chroot 环境
umount -R /mnt         # 卸载分区
sync                   # 同步磁盘
reboot now            # 重启
```

在启动前移除安装媒体。您应该看到 GRUB 菜单，然后是文本模式登录屏幕。

以 "root" 身份登录，使用您的密码。

### 安装后调整

启用 NetworkManager 以进行连接：

```bash
systemctl enable --now NetworkManager
```

要在文本模式下配置网络，请使用：
```bash
nmtui
```

您已完成 Arch Linux 基础安装。下一章涵盖桌面环境安装。

### 第1章检查清单

- [ ] 下载了 Arch Linux ISO 映像
- [ ] 创建了安装媒体（USB/DVD）
- [ ] 成功从安装媒体启动
- [ ] 键盘正确配置
- [ ] 互联网连接验证
- [ ] 系统时钟同步
- [ ] 启动模式识别（UEFI/BIOS）
- [ ] 磁盘识别和分区创建
- [ ] 分区正确格式化
- [ ] 分区挂载到 `/mnt`
- [ ] 镜像优化（可选）
- [ ] 使用 pacstrap 安装基础系统
- [ ] fstab 文件生成
- [ ] 使用 arch-chroot 进入系统
- [ ] 时区配置
- [ ] 语言和本地化配置
- [ ] 网络配置（主机名和主机）
- [ ] Root 密码设置
- [ ] 可选 pacman 配置应用
- [ ] GRUB 安装和配置
- [ ] 微码安装（如果适用）
- [ ] 系统重启和首次启动成功
- [ ] NetworkManager 启用

---

# 第2章：转变 - 创建桌面环境

本章涵盖 Cinnamon 桌面环境的安装和配置，这是 Linux Mint 使用的相同环境。

## 2.1 准备阶段

### 为桌面创建用户

推荐为日常任务创建常规用户：

```bash
useradd -m -G wheel user
passwd user
```

*将 "user" 替换为您喜欢的名称。`-G wheel` 选项将用户添加到 wheel 组，这是 Arch 中具有 sudo 权限用户的标准实践。*

## 2.2 安装视觉组件

安装桌面所需的组件：

```bash
pacman -S xorg xorg-apps xorg-drivers mesa lightdm lightdm-slick-greeter \
cinnamon cinnamon-translations gnome-terminal xdg-user-dirs \
xdg-user-dirs-gtk
```

已安装组件：
- **xorg**：X11 图形服务器
- **xorg-apps**：X11 的基本应用程序
- **xorg-drivers**：X11 的输入驱动
- **mesa**：开源图形驱动
- **lightdm**：登录管理器（显示管理器）
- **lightdm-slick-greeter**：具有 Linux Mint 风格的登录屏幕
- **cinnamon**：Linux Mint 的桌面环境
- **cinnamon-translations**：Cinnamon 的翻译（语言支持）
- **gnome-terminal**：终端仿真器
- **xdg-user-dirs**：创建标准用户目录（下载、文档等）
- **xdg-user-dirs-gtk**：GTK 用户目录管理集成

### 配置 LightDM

编辑 `/etc/lightdm/lightdm.conf`（使用 `nano /etc/lightdm/lightdm.conf` 或 `vim /etc/lightdm/lightdm.conf`）并在 `[Seat:*]` 部分添加或取消注释：

```ini
[Seat:*]
greeter-session=lightdm-slick-greeter
```

### 测试桌面

在永久化之前测试 LightDM：

```bash
systemctl start lightdm
```

如果正常工作，请使其永久：

```bash
systemctl enable lightdm
```

重启并以您的用户身份登录。您将看到 Cinnamon 桌面。

## 2.3 基本配置

### 调整键盘布局

在图形环境中配置您的键盘。转到：

**Cinnamon 菜单 → 键盘 → 布局**

- 使用 (+) 按钮添加您的布局
- 使用 (-) 按钮移除您不使用的布局

> **注意：** 在撰写本文时（2025 年 11 月），键盘布局仅在 X11 会话中工作。Wayland 支持正在开发中，即使在 2025 年，KDE 和 GNOME 默认也有它。

### 为您的用户配置 sudo

sudo 软件包已安装，但您需要配置它以便您的用户可以执行管理命令。

切换到 root 用户：
```bash
su
```

编辑 sudoers 配置：
```bash
EDITOR=vim visudo
```

**基本 vim 指令：**
1. 使用箭头键在文件中移动
2. 查找 " ## User privilege specification " 部分
3. 在该部分的末尾按 `o` 创建新行
4. 输入：`user ALL=(ALL) ALL`（将 "user" 替换为您的用户名）
5. 按 `Esc` 退出编辑模式
6. 输入 `:wq` 并按 Enter 保存并退出

**它应该看起来像这样：**
```bash
## User privilege specification
##
root ALL=(ALL) ALL
user ALL=(ALL) ALL
```

*如果您在步骤 2.1 中将用户添加到 wheel 组，则可以取消注释 `%wheel ALL=(ALL) ALL` 行而不是单独添加您的用户。*

如果您更喜欢使用 nano 而不是 vim：
```bash
EDITOR=nano visudo
```

使用 nano 更简单：编辑文件，按 `Ctrl+O` 保存，Enter 确认，`Ctrl+X` 退出。

返回您的用户：
```bash
su user
```

## 2.4 启用 AUR - Arch 的魔法

AUR（Arch User Repository）包含数千个附加软件包。安装 `yay` 以便轻松访问：

```bash
sudo pacman -S --needed git base-devel
cd ~
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf ./yay/
yay -Syy
```

已安装软件包：
- **git**：版本控制系统（需要克隆 AUR 仓库）
- **base-devel**：具有基本构建工具的软件包组
- **yay**：简化从 AUR 安装社区软件包的 AUR 助手

使用 `yay`，您可以访问 Linux 可用的几乎任何软件。

## 2.5 视觉变身 - 使其看起来像 Linux Mint

安装赋予 Linux Mint 其特色外观的视觉组件。

### 安装 Linux Mint 字体

安装必要的字体：

```bash
yay -S --needed noto-fonts noto-fonts-emoji noto-fonts-cjk \
noto-fonts-extra
yay -S --needed ttf-ubuntu-font-family
```

- **noto-fonts**：Noto 字体家族（广泛语言覆盖）
- **noto-fonts-emoji**：具有表情符号支持的 Noto 字体
- **noto-fonts-cjk**：CJK 语言的 Noto 字体（中文、日语、韩语）
- **noto-fonts-extra**：附加 Noto 字体
- **ttf-ubuntu-font-family**：Ubuntu 字体家族（Linux Mint 的默认）

在 **Cinnamon 菜单 → 字体选择** 中配置它们：

- 默认字体：      Ubuntu Regular,    大小 10
- 桌面字体：      Ubuntu Regular,    大小 10
- 文档字体：     Sans Regular,      大小 10
- 等宽字体：    Monospace Regular, 大小 10
- 窗口标题字体： Ubuntu Medium,     大小 10

### 安装官方主题和图标

安装 Linux Mint 主题和图标：

```bash
yay -S --needed mint-themes mint-l-theme mint-y-icons mint-x-icons \
mint-l-icons bibata-cursor-theme xapp-symbolic-icons
```

- **mint-themes**：官方 Linux Mint 桌面主题
- **mint-l-theme**：Linux Mint Legacy 桌面主题
- **mint-y-icons**：Mint-Y 图标集（现代风格）
- **mint-x-icons**：Mint-X 图标集（经典风格）
- **mint-l-icons**：Mint-L 图标集
- **bibata-cursor-theme**：Bibata 光标主题
- **xapp-symbolic-icons**：XApp 应用程序的符号图标

在 **Cinnamon 菜单 → 主题** 中选择主题。

对于登录屏幕：
```bash
yay -S --needed lightdm-settings
```

- **lightdm-settings**：自定义 LightDM 的图形配置器

### Linux Mint 壁纸

安装官方壁纸：

**⚠️ 警告：** 这些软件包下载大文件（每个 70+ MiB）。如果连接有限，请跳过此步骤。

```bash
yay -S --needed mint-backgrounds mint-artwork
```

- **mint-backgrounds**：官方 Linux Mint 壁纸集合
- **mint-artwork**：Linux Mint 的附加艺术和图形资源

在 **Cinnamon 菜单 → 背景** 中选择壁纸。

## 2.6 附加功能

### 打印机支持

打印文档：

```bash
yay -S --needed cups system-config-printer
sudo systemctl enable --now cups
```

- **cups**：CUPS 打印系统（通用 Unix 打印系统）
- **system-config-printer**：配置打印机的图形界面

### 音频（PipeWire）

现代 Linux Mint 和 Arch Linux 使用 PipeWire 作为音频服务器，替换 PulseAudio 和 JACK。PipeWire 提供更好的延迟和对专业音频的支持。

安装必要的 PipeWire 组件：

```bash
yay -S --needed pipewire-audio wireplumber pipewire-alsa pipewire-pulse \
pipewire-jack
```

已安装组件：
- **pipewire-audio**：包含 PipeWire、WirePlumber 和 ALSA/PulseAudio/JACK 支持的元软件包
- **wireplumber**：PipeWire 的推荐会话管理器（替换 pipewire-media-session）
- **pipewire-alsa**：PipeWire 的 ALSA 支持
- **pipewire-pulse**：替换 PulseAudio 的 PulseAudio 兼容实现
- **pipewire-jack**：专业音频应用程序的 JACK 支持

PipeWire 用户服务在您登录时自动启动。要验证它是否工作：

```bash
pactl info
```

您应该在输出中看到 `Server Name: PulseAudio (on PipeWire x.y.z)`。

> **注意：** Cinnamon 有自己的内置音量控制。如果您需要更高级的控制（例如，更改设备配置文件或配置单个应用程序），您可以选择安装：

```bash
yay -S --needed pavucontrol
```

- **pavucontrol**：高级音量控制（可选，与 PipeWire 通过 PulseAudio 兼容性一起工作）

### 蓝牙

完整蓝牙支持（键盘、鼠标、耳机等）：

```bash
yay -S --needed bluez bluez-utils
sudo systemctl enable --now bluetooth
```

已安装组件：
- **bluez**：Linux 的蓝牙协议栈
- **bluez-utils**：命令行工具（bluetoothctl 等）

从终端配对设备，使用 `bluetoothctl`：

```bash
bluetoothctl
```

bluetoothctl 中的基本命令：
- `power on` - 开启蓝牙适配器
- `scan on` - 搜索附近设备
- `pair XX:XX:XX:XX:XX:XX` - 与设备配对（将 XX... 替换为 MAC 地址）
- `trust XX:XX:XX:XX:XX:XX` - 信任设备以自动重新连接
- `connect XX:XX:XX:XX:XX:XX` - 连接到设备
- `exit` - 退出 bluetoothctl

> **注意：** 稍后在本指南中，我们将安装 Blueberry，Linux Mint 的图形蓝牙管理器，使从 GUI 配对更容易。

**对于蓝牙耳机/扬声器：**

蓝牙音频支持已包含在 `pipewire-audio` 中。蓝牙音频设备一旦配对并连接，应该自动作为可用音频输出出现。

### 第2章检查清单

- [ ] 常规用户创建
- [ ] 视觉组件安装（Xorg、LightDM、Cinnamon）
- [ ] LightDM 配置为 Slick Greeter
- [ ] 桌面测试和工作
- [ ] 在 Cinnamon 中配置键盘布局
- [ ] 为用户配置 sudo
- [ ] Yay 安装和 AUR 启用
- [ ] Linux Mint 字体安装和配置
- [ ] Mint 主题和图标安装
- [ ] Mint 壁纸安装（可选）
- [ ] 打印机支持安装（可选）
- [ ] PipeWire 安装和工作
- [ ] 蓝牙安装和配置（可选）

---

# 第3章：完成体验 - Linux Mint 应用程序

本章涵盖默认在 Linux Mint 中安装的应用程序。

## 3.1 生产力应用程序和实用工具

### 系统工具和附件

基本 Linux Mint 应用程序：

```bash
yay -S --needed file-roller yelp warpinator mintstick xed \
gnome-screenshot redshift seahorse onboard sticky xviewer \
gnome-font-viewer bulky xreader gnome-disk-utility gucharmap \
gnome-calculator
```

每个应用程序的功能：
- **file-roller**：归档管理器
- **yelp**：系统帮助查看器
- **warpinator**：网络设备之间的文件传输
- **mintstick**：可启动 USB 创建器
- **xed**：高级文本编辑器
- **gnome-screenshot**：截图捕获
- **redshift**：蓝光过滤器
- **seahorse**：密码和密钥管理器
- **onboard**：屏幕虚拟键盘
- **sticky**：便签
- **xviewer**：图像查看器
- **gnome-font-viewer**：字体查看器
- **bulky**：批量文件重命名器
- **xreader**：PDF 文档查看器
- **gnome-disk-utility**：磁盘实用工具
- **gucharmap**：字符映射
- **gnome-calculator**：计算器

### 图形应用程序

用于图像工作和扫描：

```bash
yay -S --needed simple-scan pix drawing
```

- **simple-scan**：扫描应用程序
- **pix**：照片整理器和基本编辑器
- **drawing**：绘图应用程序

## 3.2 互联网和通信应用程序

```bash
yay -S --needed firefox webapp-manager thunderbird \
transmission-gtk
```

- **firefox**：网页浏览器
- **webapp-manager**：将网站转换为桌面应用程序
- **thunderbird**：电子邮件客户端
- **transmission-gtk**：BitTorrent 客户端

> **注意：** 关于 HexChat：此应用程序在 AUR 中可用但需要 GTK2，也在 AUR 中。安装 HexChat 将涉及使用 `yay` 编译 GTK2 和 HexChat。此外，HexChat 不再接收主动维护。虽然它是 Linux Mint 的一部分，但根据是否值得编译工作，将其安装留给用户自行决定。

## 3.3 办公套件

生产力和时间管理：

```bash
yay -S --needed gnome-calendar libreoffice-fresh
```

- **gnome-calendar**：集成日历
- **libreoffice-fresh**：完整办公套件

## 3.4 开发工具

用于编程：

```bash
yay -S --needed python
```

- **python**：Python 解释器（许多系统应用程序的基础）

## 3.5 多媒体

音频和视频应用程序：

```bash
yay -S --needed celluloid hypnotix rhythmbox
```

- **celluloid**：基于 MPV 的视频播放器
- **hypnotix**：IPTV 和流媒体客户端
- **rhythmbox**：音乐播放器和库管理器

## 3.6 管理工具

系统管理和监控：

```bash
yay -S --needed baobab gnome-logs timeshift
```

- **baobab**：磁盘使用分析器（图形化可视化使用空间）
- **gnome-logs**：系统日志查看器（用于诊断和故障排除）
- **timeshift**：系统备份工具（允许创建和恢复快照）

## 3.7 配置和偏好

系统自定义：

```bash
yay -S --needed gufw blueberry mintlocale gnome-online-accounts-gtk
```

- **gufw**：防火墙图形界面（可视化管理网络规则）
- **blueberry**：蓝牙设备管理器（连接耳机、键盘等）
- **mintlocale**：系统语言配置（Linux Mint 接口）
- **gnome-online-accounts-gtk**：在线账户集成（Google、Microsoft 等）

启用防火墙：
```bash
sudo systemctl enable --now ufw
```

- **ufw**（Uncomplicated Firewall）：保护您的系统免受未经授权连接的防火墙

## 3.8 系统工具和命令行

### 文件系统兼容性

不同存储类型的兼容性：

```bash
yay -S --needed ntfs-3g dosfstools mtools exfatprogs
```

- **ntfs-3g**：NTFS 分区的读/写支持（Windows）
- **dosfstools**：FAT 文件系统的实用工具
- **mtools**：访问 MS-DOS 磁盘的工具
- **exfatprogs**：exFAT 文件系统的支持

*高级文件系统的可选：*
```bash
yay -S --needed btrfs-progs xfsprogs e2fsprogs
```

- **btrfs-progs**：Btrfs 文件系统的实用工具
- **xfsprogs**：XFS 文件系统的实用工具
- **e2fsprogs**：ext2/ext3/ext4 文件系统的实用工具

### 压缩工具

使用任何压缩文件格式：

```bash
yay -S --needed unrar unace unarj arj lha lzo lzop unzip zip \
cpio pax p7zip
```

- **unrar**：RAR 文件解压缩器
- **unace**：ACE 文件解压缩器
- **unarj**：ARJ 文件解压缩器
- **arj**：ARJ 压缩器/解压缩器
- **lha**：LHA 压缩器/解压缩器
- **lzo** 和 **lzop**：快速 LZO 压缩器
- **unzip** 和 **zip**：ZIP 压缩器/解压缩器
- **cpio**：cpio 归档实用工具
- **pax**：POSIX 归档实用工具
- **p7zip**：7-Zip 压缩器/解压缩器

> **注意：** AUR 中的 `rar` 软件包可能与 `unrar` 冲突。根据您的需要选择。

### 与 Nemo 文件管理器的附加集成

```bash
yay -S --needed xviewer-plugins nemo-fileroller gvfs-goa \
gvfs-onedrive gvfs-google
```

- **xviewer-plugins**：图像查看器的附加插件
- **nemo-fileroller**：Nemo 中的压缩/解压缩集成
- **gvfs-goa**：文件管理器中的 GNOME Online Accounts 支持
- **gvfs-onedrive**：从文件管理器访问 OneDrive
- **gvfs-google**：从文件管理器访问 Google Drive

## 3.9 笔记本优化（可选）

如果您在笔记本上安装，这些工具可以显著改善电源管理和整体体验：

### 电源和电池管理

您有两个主要选项（仅选择一个）：

**选项 1：TLP（推荐用于最大电源节省）**

```bash
yay -S --needed tlp tlp-rdw
sudo systemctl enable --now tlp
sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket
```

- **tlp**：笔记本的高级电源管理（自动优化电池）
- **tlp-rdw**：TLP 的扩展，用于管理无线设备（WiFi、蓝牙）

*`mask` 命令是必要的，因为 TLP 直接管理 rfkill。*

**TLP 的有用可选依赖：**

```bash
yay -S --needed ethtool smartmontools
```

- **ethtool**：允许禁用 Wake-on-LAN 以节省电源
- **smartmontools**：在 `tlp-stat` 中显示磁盘 S.M.A.R.T. 数据

**选项 2：电源配置文件守护程序（更简单，桌面集成）**

```bash
yay -S --needed power-profiles-daemon
sudo systemctl enable --now power-profiles-daemon
```

- **power-profiles-daemon**：电源配置文件管理（性能、平衡、省电）

*比 TLP 简单但可配置性较差。更好的桌面小程序集成。*

⚠️ **重要**：不要同时安装两者，因为它们冲突。选择 TLP 以获得最大控制，或 power-profiles-daemon 以获得简单。

### 笔记本内核工具

```bash
yay -S --needed linux-tools-meta
```

- **linux-tools-meta**：包含有用内核工具的元软件包，如 `cpupower`、`turbostat` 等。

### 系统信息和传感器

```bash
yay -S --needed lm_sensors
sudo sensors-detect
```

- **lm_sensors**：检测和显示硬件传感器信息（温度、风扇、电压）

运行 `sensors-detect` 并接受默认选项。然后您可以使用 `sensors` 查看温度。

### 屏幕亮度控制

亮度控制应该自动与 Cinnamon 一起工作，但如果您有问题：

```bash
yay -S --needed brightnessctl
```

- **brightnessctl**：从命令行控制屏幕亮度的实用工具

### 高级触摸板支持

```bash
yay -S --needed xf86-input-synaptics xf86-input-libinput
```

- **xf86-input-synaptics**：Synaptics 触摸板的改进驱动（维护模式中的驱动）
- **xf86-input-libinput**：现代和默认触摸板和其他类似输入设备的驱动（libinput 等）

> **注意：** 大多数现代触摸板在默认 libinput 驱动下工作良好。只有在 libinput 中没有可用功能或兼容性时才安装 synaptics。

### 第3章检查清单

- [ ] 生产力应用程序安装
- [ ] 图形应用程序安装
- [ ] 互联网应用程序安装
- [ ] 办公套件安装
- [ ] 开发工具安装
- [ ] 多媒体应用程序安装
- [ ] 管理工具安装
- [ ] 配置和偏好安装
- [ ] 系统工具安装
- [ ] 笔记本优化应用（如果适用）

---

## 结论

您已完成创建您的 Linux Mint Arch Edition。该系统：

- 看起来和工作像 Linux Mint
- 保持 Arch 的基础和灵活性
- 访问 AUR 以获取额外软件

### 推荐后续步骤

1. 为自动备份配置 Timeshift
2. 根据您的喜好自定义桌面
3. 探索 AUR 以获取额外软件
4. 如果您安装了 TLP，请查看 `/etc/tlp.conf` 以进行自定义调整

## 系统维护

### 更新系统

Arch Linux 是一个滚动发布发行版，这意味着您接收连续更新。重要的是定期保持系统更新。

**更新官方软件包：**
```bash
sudo pacman -Syu
```

**更新 AUR 和官方软件包：**
```bash
yay -Syu
```

**建议：**
- 至少每周更新一次
- 更新前阅读 [https://archlinux.org/](https://archlinux.org/) 的新闻，以了解重要变化
- 如果您使用 AUR 软件，`yay -Syu` 将同时更新官方仓库和 AUR
- 重要内核更新后，考虑重启系统

**清理软件包缓存（可选）：**
```bash
sudo pacman -Sc
```

这从缓存中移除旧软件包以释放磁盘空间。

## 词汇表

- **AUR (Arch User Repository)**：Arch Linux 的社区维护软件包仓库，允许安装官方仓库中不可用的软件。
- **BIOS**：基本输入/输出系统，传统的计算机固件。
- **Cinnamon**：Linux Mint 开发的现代优雅桌面环境。
- **EFI (Extensible Firmware Interface)**：可扩展固件接口。
- **fstab**：定义系统分区如何在启动时挂载的文件。
- **GRUB**：允许在启动时选择操作系统的引导管理器。
- **pacman**：Arch Linux 软件包管理器。
- **PipeWire**：替换 PulseAudio 和 JACK 的现代音频和视频服务器。
- **UEFI**：统一可扩展固件接口，现代计算机固件的标准。
- **yay**：简化从 AUR 安装软件包的 AUR 助手。

## 有用链接

- [官方 Arch Linux 网站](https://archlinux.org/)
- [Arch Linux Wiki](https://wiki.archlinux.org/)
- [官方 Linux Mint 网站](https://linuxmint.com/)
- [Cinnamon 文档](https://linuxmint-user-guide.readthedocs.io/en/latest/)
- [Arch Linux 论坛](https://bbs.archlinux.org/)
- [AUR (Arch User Repository)](https://aur.archlinux.org/)