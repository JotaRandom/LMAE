# LMAE: Linux Mint Arch Edition

*A step-by-step guide to recreate Linux Mint's visual and functional experience on Arch Linux (Cinnamon).*
*Includes base installation, desktop setup, applications, thumbnails and laptop optimizations.*
**Note:** Documentation available in English, Spanish and Chinese. Translations are automated and may contain errors; consult the English version for the original if in doubt.

## Table of Contents

- [Introduction](#introduction)
- [Chapter 1: The Foundation - Installing Arch Linux](#chapter-1-the-foundation---installing-arch-linux)
  - [1.1 Preparing the Ground](#11-preparing-the-ground)
  - [1.2 Initial System Configuration](#12-initial-system-configuration)
  - [1.3 The Art of Partitioning](#13-the-art-of-partitioning)
  - [1.4 Optimizing Mirrors (Optional but Recommended)](#14-optimizing-mirrors-optional-but-recommended)
  - [1.5 Installing the System Core](#15-installing-the-system-core)
  - [1.6 Configuration of the Newly Installed System](#16-configuration-of-the-newly-installed-system)
  - [1.7 The GRUB Boot Loader](#17-the-grub-boot-loader)
  - [1.8 The First Boot](#18-the-first-boot)
- [Chapter 2: The Transformation - Creating the Desktop Environment](#chapter-2-the-transformation---creating-the-desktop-environment)
  - [2.1 Preparing the Stage](#21-preparing-the-stage)
  - [2.2 Installing the Visual Components](#22-installing-the-visual-components)
  - [2.3 Essential Configurations](#23-essential-configurations)
  - [2.4 Enabling the AUR - The Magic of Arch](#24-enabling-the-aur---the-magic-of-arch)
  - [2.5 The Visual Metamorphosis - Making it Look Like Linux Mint](#25-the-visual-metamorphosis---making-it-look-like-linux-mint)
  - [2.6 Additional Functionality](#26-additional-functionality)
- [Chapter 3: Completing the Experience - Linux Mint Applications](#chapter-3-completing-the-experience---linux-mint-applications)
  - [3.1 Productivity Applications and Utilities](#31-productivity-applications-and-utilities)
  - [3.2 Internet and Communication Applications](#32-internet-and-communication-applications)
  - [3.3 Office Suite](#33-office-suite)
  - [3.4 Development Tools](#34-development-tools)
  - [3.5 Multimedia](#35-multimedia)
  - [3.6 Administration Tools](#36-administration-tools)
  - [3.7 Configuration and Preferences](#37-configuration-and-preferences)
  - [3.8 System Tools and Command Line](#38-system-tools-and-command-line)
  - [3.9 Thumbnails & x-app integration](#39-thumbnails--x-app-integration)
  - [3.10 Laptop Optimizations (Optional)](#310-laptop-optimizations-optional)
- [Conclusion](#conclusion)
- [System Maintenance](#system-maintenance)

---

## Introduction

This guide explains how to combine the solid rolling-release foundation
of Arch Linux with the Cinnamon desktop environment and Linux Mint
applications. The result is a system that maintains Arch's flexibility
while offering the visual and functional experience of Linux Mint.

The process is divided into three main stages:

- Arch Linux installation
- Cinnamon desktop environment configuration
- Installation of Linux Mint's characteristic applications

Optional sections (thumbnails, laptop optimizations, and advanced configurations) cover additional steps to customize and optimize the system.

Each section includes clear explanations of the necessary commands and
configurations.

# Chapter 1: The Foundation - Installing Arch Linux

Installing Arch Linux will be the system's foundation.

Although Arch has a reputation for being complex, following these steps
in order makes the process quite straightforward.

## 1.1 Preparing the Ground

### Downloading the installation image

Download the latest ISO image from the official Arch Linux website at
[https://archlinux.org/download/](https://archlinux.org/download/).

Make sure to use the official version to avoid security issues.

### Creating the installation media

Once the ISO is downloaded, burn it to a USB or DVD using one of these tools:

- **balenaEtcher**: Intuitive and cross-platform
- **Rufus**: Fast and efficient for Windows
- **Win32 Disk Imager**: A classic and reliable option

### Booting from the installation media

Boot your computer from the USB or DVD you just created.

This may require changing the boot order in BIOS/UEFI.

## 1.2 Initial System Configuration

### Adjusting the keyboard to your language

By default, the keyboard is configured for English. To change it, first
list available keyboard maps:

```bash
ls /usr/share/kbd/keymaps/**/*.map.gz
```

Then apply the one you need. For example, for a UK keyboard:

```bash
loadkeys uk
```

> **Note:** Other common layouts: `de` (German), `fr` (French),
> `es` (Spanish), `us` (US English).

### Verifying internet connection

Arch Linux needs an internet connection to download packages during
installation.
Verify your network interface is available:

```bash
ip link
```

If using Wi-Fi, configure it with:

```bash
iwctl
```

Follow the on-screen instructions to connect to your network.

Confirm the connection works:

```bash
ping 8.8.8.8
```

If you see responses, the connection is working correctly.

### Synchronizing the system clock

Set the correct time using internet time servers to avoid issues with
security certificates:

```bash
timedatectl set-ntp true
```

### Identifying the boot mode

Modern systems can boot in UEFI or legacy BIOS mode. Identify which
you're using:

```bash
ls /sys/firmware/efi/efivars
```

If the command shows files, you're in UEFI mode. If it shows "No such
file or directory", you're in legacy BIOS mode. This information will be
important for the following steps.

## 1.3 The Art of Partitioning

Partitioning requires attention and care to avoid data loss.

### Identifying your disk

List all available disks:

```bash
fdisk -l
```

Identify your main disk: usually it will be `/dev/sda` (SATA/IDE disks),
`/dev/nvme0n1` (NVMe disks), or `/dev/mmcblk0` (SD/eMMC cards).

**Carefully verify which is your target disk** before continuing.

### Creating the partitions

We'll use the GPT partition scheme. The configuration depends on the boot mode:

**For UEFI systems with GPT:**

- `/dev/sda1`: EFI System, 1024 MiB or more, mount: `/mnt/boot`
- `/dev/sda2`: Linux swap, see note below, mount: (swap)
- `/dev/sda3`: Linux filesystem, rest of disk, mount: `/mnt`

**For BIOS systems with GPT:**

- `/dev/sda1`: BIOS boot, 8 MiB, mount: (not mounted)
- `/dev/sda2`: EFI boot, 1024 MiB or more, mount: `/mnt/boot`
- `/dev/sda3`: Linux swap, see note below, mount: (swap)
- `/dev/sda4`: Linux filesystem, rest of disk, mount: `/mnt`

**For BIOS systems with MBR (DOS partition table):**

- `/dev/sda1`: Bootloader, 1024 MiB or more, mount: `/mnt/boot`
- `/dev/sda2`: Linux swap, see note below, mount: (swap)
- `/dev/sda3`: Linux, rest of disk, mount: `/mnt`

**Swap size recommendations:**

- **Up to 4 GB RAM**: Swap = 1.5 × RAM (if you want hibernation) or
  equal to RAM (without hibernation)
- **4-16 GB RAM**: 4 GB swap is usually sufficient
- **More than 16 GB RAM**: 4 GB + (0.1 × total RAM) is a good general rule
- **Recommended minimum**: 2 GB in any case

> **Note:** The mount points `/mnt` and `/mnt/boot` are specific to the

> installation environment. Once the system is installed, they will be

> mounted as `/` and `/boot` respectively.

Open `cfdisk` to create the partitions:

```bash
cfdisk /dev/sda
```

> **Note:** Replace `/dev/sda` with your disk.

Steps in `cfdisk`:

1. If the disk is empty, select the table type:
   - **"gpt"** for UEFI or modern BIOS systems (recommended)
   - **"msdos"** only if you need MBR for very old BIOS systems
2. Create partitions according to your boot mode scheme
3. Assign the correct types to each partition
4. Write changes and exit

### Formatting the partitions

Format the partitions with appropriate file systems:

**For UEFI systems with GPT:**

```bash
mkfs.fat -F 32 /dev/sda1  # EFI partition (FAT32)
mkswap /dev/sda2          # Swap partition
mkfs.ext4 /dev/sda3       # Main file system (ext4)
```

**For BIOS systems with GPT:**

```bash
# The BIOS boot partition (/dev/sda1) is not formatted
mkfs.fat -F 32 /dev/sda2  # EFI boot partition (FAT32)
mkswap /dev/sda3          # Swap partition
mkfs.ext4 /dev/sda4       # Main file system (ext4)
```

**For BIOS systems with MBR:**

```bash
mkfs.fat -F 32 /dev/sda1  # Bootloader partition (FAT32)
mkswap /dev/sda2          # Swap partition
mkfs.ext4 /dev/sda3       # Main file system (ext4)
```

**Additional information about file systems:**

If you want to explore other formatting options, here are the most
common commands with their recommended options:

*EFI/ESP partitions (package: dosfstools):*

```bash
mkfs.fat -F 32 /dev/sdaX               # Always FAT32 (-F 32) for EFI partitions
mkfs.fat -F 32 -n "EFI" /dev/sdaX      # With volume label (-n)
```

*Swap partition (package: util-linux - included in base):*

```bash
mkswap /dev/sdaX                       # No additional options needed
mkswap -L "swap" /dev/sdaX             # With volume label (-L)
```

*Main file system:*

- **ext4** (package: e2fsprogs - included in base) - recommended for most, stable and mature:

```bash
mkfs.ext4 /dev/sdaX                              # Default options (recommended)
mkfs.ext4 -L "ArchLinux" /dev/sdaX               # With volume label (-L)
mkfs.ext4 -L "ArchLinux" -O metadata_csum,64bit -E lazy_itable_init=0,\
lazy_journal_init=0 /dev/sdaX  # Optimized options for SSD
```

- **XFS** (package: xfsprogs) - good for large files and high performance, cannot be shrunk:

```bash
mkfs.xfs /dev/sdaX                               # Default options
mkfs.xfs -L "ArchLinux" /dev/sdaX                # With volume label (-L)
mkfs.xfs -L "ArchLinux" -m crc=1,finobt=1 /dev/sdaX  # Recommended
modern options
```

- **Btrfs** (package: btrfs-progs) - modern, with snapshots and compression, requires more knowledge:

```bash
mkfs.btrfs /dev/sdaX                             # Default options
mkfs.btrfs -L "ArchLinux" /dev/sdaX              # With volume label (-L)
mkfs.btrfs -L "ArchLinux" -f /dev/sdaX           # Force format (-f)
if partition already has data
```

*Options explained:*

- `-L` or `-n`: Sets a volume label (useful for identification and
  mounting by label)
- `-f`: Forces formatting even if there is data (use with caution)
- For ext4 on SSD: `metadata_csum` improves integrity, `lazy_*=0`
  initializes everything immediately
- For XFS: `crc=1` enables metadata checksums, `finobt=1` improves
  performance with many files

> **Note:** For desktop/laptop, ext4 is the safest and most proven option.

> XFS offers good performance for workstations with large files (cannot be shrunk).

> Btrfs offers advanced features (snapshots, compression, deduplication) but requires

> more knowledge for maintenance and recovery.

**Important consideration about backups with Timeshift:**

- **Btrfs**: Timeshift can create instant system snapshots using Btrfs
  native capabilities. This is very fast and space-efficient.
- **ext4/XFS/others**: Timeshift uses rsync to make full file copies,
  which consumes more time and disk space.

### Mounting the partitions

Mount the partitions to work with them:

**For UEFI systems with GPT:**

```bash
mount /dev/sda3 /mnt      # Mount the main file system
swapon /dev/sda2          # Activate swap partition
mkdir /mnt/boot           # Create mount point for EFI
mount /dev/sda1 /mnt/boot # Mount the EFI partition
```

**For BIOS systems with GPT:**

```bash
mount /dev/sda4 /mnt      # Mount the main file system
swapon /dev/sda3          # Activate swap partition
mkdir /mnt/boot           # Create mount point for EFI
mount /dev/sda2 /mnt/boot # Mount the EFI boot partition
# The BIOS boot partition is not mounted
```

**For BIOS systems with MBR:**

```bash
mount /dev/sda3 /mnt      # Mount the main file system
swapon /dev/sda2          # Activate swap partition
mkdir /mnt/boot           # Create mount point for bootloader
mount /dev/sda1 /mnt/boot # Mount the bootloader partition
```

## 1.4 Optimizing Mirrors (Optional but Recommended)

If package downloads are slow, you can optimize the mirror list before
installing:

```bash
pacman -S --needed reflector
reflector --country "Mexico,United States" --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

*Replace "Mexico,United States" with countries closest to your location. You can see the full list of countries with `reflector --list-countries`.*

**Reflector automation (optional):** If you want mirrors to be
automatically updated weekly, you can enable the reflector timer after
installing the base system:

```bash
systemctl enable reflector.timer
```

This will update the mirror list weekly. You can customize reflector
options by editing `/etc/xdg/reflector/reflector.conf` after installation.

## 1.5 Installing the System Core

Install the Arch Linux base system with essential packages:

**For BIOS systems:**

```bash
pacstrap /mnt base linux linux-firmware networkmanager grub vim sudo nano
```

**For UEFI systems (add efibootmgr):**

```bash
pacstrap /mnt base linux linux-firmware networkmanager grub efibootmgr
vim sudo nano
```

**For dual boot systems (add os-prober):**

If you have BIOS:

```bash
pacstrap /mnt base linux linux-firmware networkmanager grub os-prober
vim sudo nano
```

If you have UEFI:

```bash
pacstrap /mnt base linux linux-firmware networkmanager grub efibootmgr \
os-prober vim sudo nano
```

Installed components:

- **base**: Arch Linux base system
- **linux**: Linux kernel
- **linux-firmware**: Firmware drivers for common hardware
- **networkmanager**: Network management
- **grub**: The boot loader
- **efibootmgr**: Tool to manage UEFI boot entries (UEFI only)
- **os-prober**: Detects other operating systems for dual boot (optional)
- **vim**: Advanced text editor
- **sudo**: Allows executing commands with administrative privileges
- **nano**: Simple text editor

The process may take a few minutes depending on your connection.

## 1.6 Configuration of the Newly Installed System

### Generating the fstab file

The `fstab` file defines which partitions to mount at boot:

```bash
genfstab -pU /mnt >> /mnt/etc/fstab
```

### Entering the new system

Access the newly installed system:

```bash
arch-chroot /mnt
```

From here on, commands are executed within the new Arch Linux system.

### Configuring the time zone

Set your geographical location. Replace "Region" and "City" with your location:

```bash
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
```

Example for Mexico City:

```bash
ln -sf /usr/share/zoneinfo/America/Mexico_City /etc/localtime
```

Synchronize the hardware clock:

```bash
hwclock --systohc
```

### Language and localization configuration

Edit `/etc/locale.gen` (with `nano /etc/locale.gen` or `vim /etc/locale.gen`)
and uncomment the languages you need. Include at least `en_US.UTF-8` and
your local language (for example, `es_ES.UTF-8` or `es_MX.UTF-8`).

Generate the languages:

```bash
locale-gen
```

Create `/etc/locale.conf` with your primary language:

```bash
echo "LANG=en_US.UTF-8" > /etc/locale.conf
```

> **Note:** You can use `LANG=es_ES.UTF-8` or another language as you prefer.

Configure the keyboard permanently in `/etc/vconsole.conf`:

```bash
echo "KEYMAP=la-latin1" > /etc/vconsole.conf
```

### Network configuration

Assign a name to your computer in `/etc/hostname`:

```bash
echo "my-arch-mint" > /etc/hostname
```

Configure `/etc/hosts`:

```bash
cat >> /etc/hosts << EOF
127.0.0.1      localhost
::1            localhost
127.0.1.1      my-arch-mint
EOF
```

> **Note:** Use the same name you put in `/etc/hostname`.

### Configuring the administrator password

Set a password for the root user:

```bash
passwd
```

### Optional pacman configurations

**Enabling colors in pacman:**

Edit `/etc/pacman.conf` and uncomment the `Color` line:

```bash
nano /etc/pacman.conf
```

Find and uncomment (remove the `#`):

```ini
# Misc options
#UseSyslog
Color
#NoProgressBar
```

**Enabling the multilib repository (for 32-bit applications):**

If you plan to use 32-bit applications, Steam, Wine, or some games, you
need to enable multilib.

In the same `/etc/pacman.conf` file, uncomment these lines at the end
of the file:

```ini
[multilib]
Include = /etc/pacman.d/mirrorlist
```

Then update the package database:

```bash
pacman -Syu
```

> **Note:** Multilib is necessary for Steam, Wine, some proprietary 32-bit applications,
> and 32-bit graphics drivers for games.

## 1.7 The GRUB Boot Loader

GRUB allows the system to boot. Installation varies depending on the boot mode:

### For legacy BIOS systems

```bash
grub-install --verbose --target=i386-pc /dev/sda
```

> **Note:** Replace `/dev/sda` with your disk (without partition number).

### For UEFI systems

```bash
grub-install --verbose --target=x86_64-efi --efi-directory=/boot
--bootloader-id=GRUB
```

### Enabling microcode updates

Modern processors benefit from microcode updates to improve stability
and security:

**For Intel processors:**

```bash
pacman -S intel-ucode
```

- **intel-ucode**: Microcode updates for Intel processors

**For AMD processors:**

```bash
pacman -S amd-ucode
```

- **amd-ucode**: Microcode updates for AMD processors

### Generating the final GRUB configuration

```bash
grub-mkconfig -o /boot/grub/grub.cfg
```

**If you installed `os-prober` for dual boot**, enable it first:

```bash
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
```

The command should detect your Arch Linux system and any other installed
operating systems.

## 1.8 The First Boot

Boot the new system:

```bash
exit                    # Exit the chroot environment
umount -R /mnt         # Unmount partitions
sync                   # Synchronize disks
reboot now            # Restart
```

Remove the installation media before it boots. You should see the GRUB
menu and then a text-mode login screen.

Log in as "root" with your password.

### Post-installation adjustments

Enable NetworkManager for connectivity:

```bash
systemctl enable --now NetworkManager
```

To configure the network in text mode, use:

```bash
nmtui
```

You have completed the Arch Linux base installation. The next chapter
covers desktop environment installation.

---

# Chapter 2: The Transformation - Creating the Desktop Environment

This chapter covers the installation and configuration of the Cinnamon
desktop environment, the same one used by Linux Mint.

## 2.1 Preparing the Stage

### Creating a user for the desktop

It's recommended to create a regular user for daily tasks:

```bash
useradd -m -G wheel user
passwd user
```

*Replace "user" with the name you prefer. The `-G wheel` option adds the
user to the wheel group, which is standard practice in Arch for users
with sudo privileges.*

## 2.2 Installing the Visual Components

Install the necessary components for the desktop:

```bash
pacman -S xorg xorg-apps xorg-drivers mesa lightdm lightdm-slick-greeter
cinnamon cinnamon-translations gnome-terminal xdg-user-dirs
xdg-user-dirs-gtk
```

Installed components:

- **xorg**: The X11 graphics server
- **xorg-apps**: Basic applications for X11
- **xorg-drivers**: Input drivers for X11
- **mesa**: Open source graphics drivers
- **lightdm**: Login manager (display manager)
- **lightdm-slick-greeter**: Login screen with Linux Mint style
- **cinnamon**: Linux Mint's desktop environment
- **cinnamon-translations**: Translations for Cinnamon (language support)
- **gnome-terminal**: Terminal emulator
- **xdg-user-dirs**: Creates standard user directories (Downloads,
  Documents, etc.)
- **xdg-user-dirs-gtk**: GTK integration for user directory management

### Configuring LightDM

Edit `/etc/lightdm/lightdm.conf` (with `nano /etc/lightdm/lightdm.conf` or
`vim /etc/lightdm/lightdm.conf`) and in the `[Seat:*]` section, add or
uncomment:

```ini
[Seat:*]
greeter-session=lightdm-slick-greeter
```

### Testing the desktop

Test LightDM before making it permanent:

```bash
systemctl start lightdm
```

If it works correctly, make it permanent:

```bash
systemctl enable lightdm
```

Restart and log in with your user. You'll see the Cinnamon desktop.

---

## 2.3 Essential Configurations

### Adjusting keyboard layout

Configure your keyboard in the graphical environment. Go to:

**Cinnamon Menu → Keyboard → Layouts**

- Add your layout with the (+) button
- Remove ones you don't use with the (-) button

> **Note:** At the time of writing this guide (November 2025), keyboard

> layouts only work in X11 sessions. Wayland support is in development

> and even today in 2025 KDE and GNOME have it by default.

### Configuring sudo for your user

The sudo package is already installed, but you need to configure it so
your user can execute administrative commands.

Switch to the root user:

```bash
su
```

Edit the sudoers configuration file:

```bash
EDITOR=vim visudo
```

**Basic vim instructions:**

1. Use arrow keys to move through the file
2. Find the section that says `## User privilege specification`
3. Position at the end of that section and press `o` to create a new line
4. Type: `user ALL=(ALL) ALL` (replace "user" with your username)
5. Press `Esc` to exit edit mode
6. Type `:wq` and press `Enter` to save and exit

**Example of how it should look:**

```bash
## User privilege specification
##
root ALL=(ALL) ALL
user ALL=(ALL) ALL
```

*If you added your user to the wheel group in step 2.1, alternatively you
can uncomment the line `%wheel ALL=(ALL) ALL` instead of adding your user
individually.*

If you prefer to use nano instead of vim:

```bash
EDITOR=nano visudo
```

With nano it's simpler: edit the file, press `Ctrl+O` to save, `Enter` to confirm, and `Ctrl+X` to exit.

Return to your user:

```bash
su user
```

## 2.4 Enabling the AUR - The Magic of Arch

The AUR (Arch User Repository) contains thousands of additional packages.
Install `yay` for easy access:

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

Installed packages:

- **git**: Version control system (needed to clone AUR repositories)
- **base-devel**: Group of packages with essential build tools
- **yay**: AUR helper that simplifies installing community packages

> [!NOTE]
> There are other AUR helpers available such as `paru`, `pacaur`, `trizen`, etc.
> This guide uses `yay` for its ease of use and popularity, but you can
> use any other AUR helper if you prefer.

With `yay`, you have access to virtually any software available for Linux.

## 2.5 The Visual Metamorphosis - Making it Look Like Linux Mint

Install the visual components that give Linux Mint its characteristic
appearance.

### Installing Linux Mint fonts

First install fonts from official repositories:

```bash
sudo pacman -S --needed noto-fonts noto-fonts-emoji noto-fonts-cjk noto-fonts-extra \
ttf-ubuntu-font-family ttf-dejavu
```

- **noto-fonts**: Noto font family (wide language coverage)
- **noto-fonts-emoji**: Noto fonts with emoji support
- **noto-fonts-cjk**: Noto fonts for CJK languages (Chinese, Japanese, Korean)
- **noto-fonts-extra**: Additional Noto fonts
- **ttf-ubuntu-font-family**: Ubuntu font family (the default in Linux Mint)
- **ttf-dejavu**: DejaVu font family used as monospace font by Linux Mint

Configure them in **Cinnamon Menu → Font Selection**:

- Default font:      Ubuntu Regular,        size 10
- Desktop font:      Ubuntu Regular,        size 10
- Document font:     Sans Regular,          size 10
- Monospace font:    DejaVu Sans Mono Book, size 10
- Window title font: Ubuntu Medium,         size 10

### Installing official themes and icons

Install Linux Mint themes and icons:

```bash
yay -S --needed mint-themes mint-l-theme mint-y-icons mint-x-icons
mint-l-icons bibata-cursor-theme xapp-symbolic-icons
```

- **mint-themes**: Official Linux Mint desktop themes
- **mint-l-theme**: Linux Mint Legacy desktop themes
- **mint-y-icons**: Mint-Y icon set (modern style)
- **mint-x-icons**: Mint-X icon set (classic style)
- **mint-l-icons**: Mint-L icon set
- **bibata-cursor-theme**: Bibata cursor theme
- **xapp-symbolic-icons**: Symbolic icons for XApp applications

Select themes in **Cinnamon Menu → Themes**.

For the login screen:

```bash
yay -S --needed lightdm-settings
```

- **lightdm-settings**: Graphical configurator to customize LightDM

### Linux Mint wallpapers

Install official wallpapers:

**⚠️ Warning:** These packages download large files (70+ MiB each). Skip
this step if you have limited connection.

```bash
yay -S --needed mint-backgrounds mint-artwork
```

- **mint-backgrounds**: Collection of official Linux Mint wallpapers
- **mint-artwork**: Additional art and graphics resources from Linux Mint

Select wallpapers in **Cinnamon Menu → Backgrounds**.

## 2.6 Additional Functionality

### Printer support

To print documents:

```bash
sudo pacman -S --needed cups system-config-printer
sudo systemctl enable --now cups
```

- **cups**: CUPS printing system (Common Unix Printing System)
- **system-config-printer**: Graphical interface to configure printers

### Audio (PipeWire)

Modern Linux Mint and Arch Linux use PipeWire as the audio server,
replacing PulseAudio and JACK. PipeWire offers better latency and support
for professional audio.

Install the necessary PipeWire components:

```bash
sudo pacman -S --needed pipewire-audio wireplumber pipewire-alsa pipewire-pulse \
pipewire-jack
```

Installed components:

- **pipewire-audio**: Meta-package including PipeWire, WirePlumber and
  ALSA/PulseAudio/JACK support
- **wireplumber**: Recommended session manager for PipeWire (replaces pipewire-media-session)
- **pipewire-alsa**: ALSA support for PipeWire
- **pipewire-pulse**: PulseAudio-compatible implementation (replaces PulseAudio)
- **pipewire-jack**: JACK support for professional audio applications

PipeWire user services start automatically when you log in. To verify
it's working:

```bash
pactl info
```

You should see `Server Name: PulseAudio (on PipeWire x.y.z)` in the
output.

> **Note:** Cinnamon has its own built-in volume control. If you need more advanced controls
> (e.g., to change device profiles or configure individual applications), you can optionally
> install:

```bash
sudo pacman -S --needed pavucontrol
```

- **pavucontrol**: Advanced volume control (optional, works with PipeWire via PulseAudio compatibility)

### Bluetooth

For complete Bluetooth support (keyboards, mice, headphones, etc.):

```bash
sudo pacman -S --needed bluez bluez-utils
sudo systemctl enable --now bluetooth
```

Installed components:

- **bluez**: Bluetooth protocol stack for Linux
- **bluez-utils**: Command-line tools (bluetoothctl, etc.)

To pair devices from the terminal, use `bluetoothctl`:

```bash
bluetoothctl
```

Basic commands in bluetoothctl:

- `power on` - Turn on the Bluetooth adapter
- `scan on` - Search for nearby devices
- `pair XX:XX:XX:XX:XX:XX` - Pair with a device (replace XX... with the
  MAC address)
- `trust XX:XX:XX:XX:XX:XX` - Trust the device for automatic reconnection
- `connect XX:XX:XX:XX:XX:XX` - Connect to the device
- `exit` - Exit bluetoothctl

> **Note:** Later in the guide we'll install Blueberry, Linux Mint's graphical Bluetooth manager,
> which makes pairing easier from the GUI.

**For Bluetooth headphones/speakers:**

Bluetooth audio support is already included with `pipewire-audio`.
Bluetooth audio devices should automatically appear as available audio
outputs once paired and connected.

---

# Chapter 3: Completing the Experience - Linux Mint Applications

In this chapter, we'll install Linux Mint's default applications to complete
the user experience. From productivity tools to multimedia and laptop
optimizations, you'll achieve a functional and complete system.

## 3.1 Productivity Applications and Utilities

### System tools and accessories

Basic Linux Mint applications:

First install GNOME applications from official repositories:

```bash
sudo pacman -S --needed file-roller yelp warpinator xed gnome-screenshot \
redshift seahorse onboard gnome-font-viewer gnome-disk-utility gucharmap \
gnome-calculator
```

Then install XApps from AUR:

```bash
yay -S --needed mintstick sticky xviewer bulky xreader
```

Functions of each application:

- **file-roller**: Archive manager
- **yelp**: System help viewer
- **warpinator**: File transfer between network devices
- **mintstick**: Bootable USB creator
- **xed**: Advanced text editor
- **gnome-screenshot**: Screenshot capture
- **redshift**: Blue light filter
- **seahorse**: Password and key manager
- **onboard**: On-screen virtual keyboard
- **sticky**: Sticky notes
- **xviewer**: Image viewer
- **gnome-font-viewer**: Font viewer
- **bulky**: Bulk file renamer
- **xreader**: PDF document viewer
- **gnome-disk-utility**: Disk utility
- **gucharmap**: Character map
- **gnome-calculator**: Calculator

### Graphics applications

For image work and scanning:

Install the GNOME graphics applications:

```bash
sudo pacman -S --needed simple-scan drawing
```

Install XApps viewer from AUR:

```bash
yay -S --needed pix
```

- **simple-scan**: Scanning application
- **pix**: Photo organizer and basic editor
- **drawing**: Drawing application

## 3.2 Internet and Communication Applications

```bash
yay -S --needed firefox webapp-manager thunderbird transmission-gtk
```

- **firefox**: Web browser
- **webapp-manager**: Converts websites into desktop applications
- **thunderbird**: Email client
- **transmission-gtk**: BitTorrent client

> **Note:** About HexChat: This application is available in the AUR but requires GTK2,
> which is also in the AUR. Installing HexChat will involve compiling both GTK2 and
> HexChat with `yay`. Additionally, HexChat no longer receives active maintenance.
> While it's part of Linux Mint, its installation is left to user discretion based on
> whether the compilation effort is worthwhile.

> **Note about Elements:** With the end of HexChat development and the emergence
> of alternatives, Linux Mint now includes a Matrix client, more specifically
> `Elements`, which in the original installation is a web application using
> `Webapp-manager`, however, a native client also exists.
> Arch Linux contains both in its official repositories under the names
> `element-desktop` and `element-web`, so it's up to your discretion
> whether to install one or the other, or none.

## 3.3 Office Suite

Productivity and time management:

```bash
sudo pacman -S --needed gnome-calendar libreoffice-fresh
```

- **gnome-calendar**: Integrated calendar
- **libreoffice-fresh**: Complete office suite

## 3.4 Development Tools

For programming:

```bash
yay -S --needed python
```

- **python**: Python interpreter (fundamental for many system applications)

## 3.5 Multimedia

Audio and video applications:

```bash
yay -S --needed celluloid hypnotix rhythmbox
```

- **celluloid**: MPV-based video player
- **hypnotix**: IPTV and streaming client
- **rhythmbox**: Music player and library manager

## 3.6 Administration Tools

System management and monitoring:

```bash
sudo pacman -S --needed baobab gnome-logs timeshift
yay -S --needed fingwit
```

- **baobab**: Disk usage analyzer (graphically visualizes used space)
- **gnome-logs**: System log viewer (for diagnosis and troubleshooting)
- **timeshift**: System backup tool (allows creating and restoring snapshots)

## 3.7 Configuration and Preferences

System customization:

```bash
sudo pacman -S --needed gufw gnome-online-accounts-gtk
yay -S --needed blueberry mintlocale
```

- **gufw**: Graphical interface for firewall (visual management of
  network rules)
- **blueberry**: Bluetooth device manager (connection of headphones,
  keyboards, etc.)
- **mintlocale**: System language configuration (Linux Mint interface)
- **gnome-online-accounts-gtk**: Online account integration (Google,
  Microsoft, etc.)

Enable the firewall:

```bash
sudo systemctl enable --now ufw
```

- **ufw** (Uncomplicated Firewall): Firewall that protects your system
  from unauthorized connections

## 3.8 System Tools and Command Line

### File system compatibility

For compatibility with different storage types:

```bash
sudo pacman -S --needed ntfs-3g dosfstools mtools exfatprogs btrfs-progs \
xfsprogs e2fsprogs
```

### Compression tools

To work with any compressed file format:

```bash
sudo pacman -S --needed unrar unzip zip cpio pax p7zip lzo lzop unace unarj arj
yay -S --needed lha
```

- **unrar**: RAR file decompressor
- **unace**: ACE file decompressor
- **unarj**: ARJ file decompressor
- **arj**: ARJ compressor/decompressor
- **lha**: LHA compressor/decompressor
- **lzo** and **lzop**: Fast LZO compressor
- **unzip** and **zip**: ZIP compressor/decompressor
- **cpio**: cpio archive utility
- **pax**: POSIX archive utility
- **p7zip**: 7-Zip compressor/decompressor

> **Note:** The `rar` package from the AUR may conflict with `unrar`.
> Choose according to your needs.

### Additional integrations

For full integration with Nemo file manager:

```bash
yay -S --needed xviewer-plugins nemo-fileroller gvfs-goa gvfs-onedrive
gvfs-google
```

- **xviewer-plugins**: Additional plugins for image viewer
- **nemo-fileroller**: Compression/decompression integration in Nemo
- **gvfs-goa**: Support for GNOME Online Accounts in file manager
- **gvfs-onedrive**: OneDrive access from file manager
- **gvfs-google**: Google Drive access from file manager

## 3.9 Thumbnails & x-app integration

Thumbnails (visual file previews) improve file navigation in the file manager by showing small previews of images, video, documents and more. This section covers the recommended thumbnailers for x-apps and commonly used formats, how to enable them, and troubleshooting tips.

Why install them

- Improve file browsing experience in Nemo, Nautilus, Thunar, etc.
- Provide previews for AppImage, EPUB, GIMP, RAW, JXL and more specific formats.
- Some thumbnailers extract embedded metadata or cover art for audio files.

Recommended packages

```bash
# X-Apps thumbnailers (Linux Mint specialized thumbnailers)
yay -S --needed xapp-vorbiscomment-thumbnailer xapp-appimage-thumbnailer \
  xapp-epub-thumbnailer xapp-aiff-thumbnailer xapp-ora-thumbnailer \
  xapp-mp3-thumbnailer xapp-jxl-thumbnailer xapp-gimp-thumbnailer \
  xapp-raw-thumbnailer

# Additional thumbnailers for videos and PDFs
yay -S --needed ffmpegthumbnailer poppler

# Optional: AppImage launcher and integrators
yay -S --needed appimagelauncher
```

Functions of the X-Apps packages

- **xapp-vorbiscomment-thumbnailer**: extracts cover art and Vorbis comments from audio files to generate thumbnails.
- **xapp-appimage-thumbnailer**: generates thumbnails for AppImage files by using the embedded icon or splash.
- **xapp-epub-thumbnailer**: shows EPUB cover art as thumbnails.
- **xapp-aiff-thumbnailer**: thumbnail support for AIFF audio files.
- **xapp-ora-thumbnailer**: thumbnails for OpenRaster (.ora) files.
- **xapp-mp3-thumbnailer**: generates thumbnails for MP3, using ID3 tags for cover art.
- **xapp-jxl-thumbnailer**: thumbnails for JPEG XL images.
- **xapp-gimp-thumbnailer**: previsualize GIMP project files (.xcf) as thumbnails.
- **xapp-raw-thumbnailer**: generates thumbnails for camera RAW formats.

Auxiliary packages

- **ffmpegthumbnailer**: fast and efficient video thumbnail generator.
- **poppler**: PDF rendering library used by file managers for PDF previews.
- **appimagelauncher**: integrates AppImages into the system (associates, creates icons and menu entries).

Enable previews in Nemo (Cinnamon)

- Open `Edit → Preferences → Preview`
- Under "Show thumbnails" choose `Always` or `Only for local files` depending on preference.
- Adjust maximum file size for previews if necessary.

Regenerate or clear thumbnail cache

```bash
# Remove the old cache to force regeneration
rm -rf ~/.cache/thumbnails/*

# Restart the file manager (example: Nemo) or log out and back in
nemo -q
```

Troubleshooting

- No video thumbnails: install `ffmpegthumbnailer` and restart the file manager.
- No PDF thumbnails: ensure `poppler` is installed and previews are enabled in the file manager settings.
- Large or slow thumbnails: reduce the file size limit or rely on `ffmpegthumbnailer` for faster thumbs.

Security

- Thumbnailers process files to generate previews and could contain bugs. Avoid trusting thumbnails as a security measure for untrusted files.

These tools complete the desktop experience by making it easier to quickly identify files without opening them. Adjust packages to your needs (for example omit `xapp-raw-thumbnailer` if you don't work with RAW images).

## 3.10 Laptop Optimizations (Optional)

If you're installing on a laptop, these tools can significantly improve
power management and overall experience:

### Power and battery management

You have two main options (choose only one):

**Option 1: TLP (recommended for maximum power saving)**

```bash
sudo pacman -S --needed tlp tlp-rdw tlp-pd
sudo systemctl enable --now tlp
sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket
```

- **tlp**: Advanced power management for laptops (automatically
  optimizes battery)
- **tlp-rdw**: Extension for managing radio devices (WiFi, Bluetooth) with TLP

*The `mask` commands are necessary because TLP manages rfkill directly.*

**Useful optional dependencies for TLP:**

```bash
sudo pacman -S --needed ethtool smartmontools
```

- **ethtool**: Allows disabling Wake-on-LAN to save power
- **smartmontools**: Displays disk S.M.A.R.T. data in `tlp-stat`

**Option 2: Power Profiles Daemon (simpler, desktop integration)**

```bash
sudo pacman -S --needed power-profiles-daemon
sudo systemctl enable --now power-profiles-daemon
```

- **power-profiles-daemon**: Power profile management (Performance,
  Balanced, Power Saver)

*Simpler than TLP but less configurable. Better integration with desktop
applets.*

> [!WARNING]
> Don't install both at the same time, as they conflict.
> Choose TLP for maximum control or power-profiles-daemon for simplicity.

### Kernel tools for laptops

```bash
sudo pacman -S --needed linux-tools-meta
```

- **linux-tools-meta**: Meta-package including useful kernel tools like
  `cpupower`, `turbostat`, etc.

### System information and sensors

```bash
sudo pacman -S --needed lm_sensors
sudo sensors-detect
```

- **lm_sensors**: Detects and displays hardware sensor information
  (temperature, fans, voltage)

Run `sensors-detect` and accept the default options. Then you can use
`sensors` to view temperatures.

### Screen brightness control

Brightness control should work automatically with Cinnamon, but if you
have issues:

```bash
sudo pacman -S --needed brightnessctl
```

- **brightnessctl**: Utility to control screen brightness from the command line

### Advanced touchpad support

```bash
sudo pacman -S --needed xf86-input-synaptics xf86-input-libinput
```

- **xf86-input-synaptics**: Improved driver for Synaptics touchpads
  (Driver in maintenance mode)
- **xf86-input-libinput**: Modern and default driver for touchpads
  and other similar input devices (libinput, etc.)

> **Note:** Most modern touchpads work fine with the default libinput
> driver. Only install synaptics if you need features not available in
> libinput or for compatibility.

---

## Conclusion

You have completed creating your Linux Mint Arch Edition. The system:

- Looks and works like Linux Mint
- Maintains the base and flexibility of Arch Linux
- Has access to the AUR for additional software

### Recommended next steps

1. Configure Timeshift for automatic backups
2. Customize the desktop to your liking
3. Explore the AUR for additional software
4. If you installed TLP, review its configuration in `/etc/tlp.conf` for
custom tweaks

## System Maintenance

### Updating the system

Arch Linux is a rolling-release distribution, which means you receive
continuous updates. It's important to keep the system updated regularly.

**Update official packages:**

```bash
sudo pacman -Syu
```

**Update AUR and official packages:**

```bash
yay -Syu
```

**Recommendations:**

- Update at least once a week
- Read the news at [https://archlinux.org/](https://archlinux.org/) before
  updating to be aware of important changes
- If you use AUR software, `yay -Syu` will update both official
  repositories and the AUR
- After important kernel updates, consider rebooting the system

**Clean package cache (optional):**

```bash
sudo pacman -Sc
```

This removes old packages from the cache to free up disk space.

## Glossary

- **AUR (Arch User Repository)**: Community-maintained package repository for Arch Linux,
  allowing installation of software not available in official repositories.
- **BIOS**: Basic Input/Output System, traditional firmware for booting.
- **Cinnamon**: Modern and elegant desktop environment developed by Linux Mint.
- **EFI (Extensible Firmware Interface)**: Extensible Firmware Interface.
- **fstab**: File that defines how system partitions are mounted.
- **GRUB**: Boot manager that allows selecting the operating system at startup.
- **pacman**: Arch Linux package manager.
- **PipeWire**: Modern audio and video server that replaces PulseAudio and JACK.
- **UEFI**: Unified Extensible Firmware Interface,
  modern standard for computer firmware.
- **yay**: AUR helper that facilitates installing packages from the AUR.

## Useful Links

- [Official Arch Linux website](https://archlinux.org/)
- [Arch Linux Wiki](https://wiki.archlinux.org/)
- [Official Linux Mint website](https://linuxmint.com/)
- [Cinnamon Documentation](https://linuxmint-user-guide.readthedocs.io/en/latest/)
- [Arch Linux Forum](https://bbs.archlinux.org/)
- [AUR (Arch User Repository)](https://aur.archlinux.org/)
