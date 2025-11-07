<DOCUMENT filename="README.md">
# LMAE
Create your own Linux Mint Arch Edition.

# How to Create Your Own "LMAE" - Linux Mint Arch Edition

## Step 1 - Installing Arch Linux

### 1.1 - Download an Arch ISO
Download the ISO from the official Arch Linux website:  
[https://archlinux.org/download/](https://archlinux.org/download/)

### 1.2 - Flash the ISO with the Tool of Your Choice
- balenaEtcher
- Win32 Disk Imager
- Rufus

### 1.3 - Boot Your Computer from the Flashed USB/CD

### 1.4 - Set Up Your Keyboard Layout
List available keymaps with:  
`ls /usr/share/kbd/keymaps/**/*.map.gz`  
Apply the keymap of your choice with:  
`loadkeys la-latin1`  
*Example for the Latin American Spanish keymap.*

### 1.5 - Verify Your Internet Connection
Ensure your network interface is listed and enabled:  
`ip link`

For Wi-Fi connections, use:  
`iwctl`  
Follow the on-screen instructions.

Confirm connectivity:  
`ping 8.8.8.8`

### 1.6 - Update the System Clock
Ensure the system clock is accurate:  
`timedatectl set-ntp true`

### 1.7 - Verify the Boot Mode
Check for UEFI mode:  
`ls /sys/firmware/efi/efivars`  
If the directory does not exist ("No such file or directory"), install in BIOS mode. Otherwise, proceed with UEFI mode.

### 1.8 - Set Up Your Disks
#### 1.8.1 - Identify Your Disk
List disks to locate the target:  
`fdisk -l`  
Identify the disk path (e.g., `/dev/sda`, `/dev/nvme0n1`, or `/dev/mmcblk0`).

#### 1.8.2 - Partition Your Disk
Use the GPT partition table (recommended). Alternative schemes require independent configuration.

**Example Layouts:**

**UEFI / GPT**

| Mount Point | Partition Type    | Suggested Size             |
|-------------|-------------------|----------------------------|
| `/mnt/boot` | EFI System        | 1024 MiB or more           |
| -           | Linux swap        | More than 512 MiB          |
| `/mnt`      | Linux filesystem  | Remaining disk space       |

**BIOS / GPT**

| Mount Point | Partition Type    | Suggested Size             |
|-------------|-------------------|----------------------------|
| -           | BIOS boot         | 1024 MiB or more           |
| -           | Linux swap        | More than 512 MiB          |
| `/mnt`      | Linux filesystem  | Remaining disk space       |

Open the disk in `cfdisk`:  
`cfdisk /dev/sda`  
Select "gpt" and create partitions according to your boot mode. Set partition types, write changes, and exit.

#### 1.8.3 - Format the Partitions
Format based on boot mode.

**UEFI Example:**
- `mkswap /dev/sda2`          (Linux swap)
- `mkfs.ext4 /dev/sda3`        (Linux filesystem, ext4)
- `mkfs.fat -F 32 /dev/sda1`   (FAT32 for EFI System)

**BIOS Example:**
- `mkswap /dev/sda2`          (Linux swap)
- `mkfs.ext4 /dev/sda3`        (Linux filesystem, ext4)

#### 1.8.4 - Mount the Partitions
Mount the root filesystem:  
`mount /dev/sda3 /mnt`

Enable swap:  
`swapon /dev/sda2`

For UEFI:  
`mkdir /mnt/boot`  
`mount /dev/sda1 /mnt/boot`

### 1.9 - Install the Base System
Install essential packages:  
`pacstrap /mnt base linux linux-firmware networkmanager grub vim sudo nano`

### 1.10 - Configure the System
#### 1.10.1 - Generate fstab
Create the fstab file:  
`genfstab -pU /mnt >> /mnt/etc/fstab`

#### 1.10.2 - Enter the New Root
Change root:  
`arch-chroot /mnt`

#### 1.10.3 - Set the Timezone
Replace "Region" and "City" with your timezone:  
`ln -sf /usr/share/zoneinfo/Region/City /etc/localtime`

Synchronize hardware clock:  
`hwclock --systohc`

#### 1.10.4 - Configure Localization
- Edit `/etc/locale.gen` and uncomment desired locales (include `en_US.UTF-8`).
- Generate locales: `locale-gen`
- Create `/etc/locale.conf` with: `LANG=en_US.UTF-8`
- Create `/etc/vconsole.conf` with: `KEYMAP=la-latin1` (or your preferred layout).

#### 1.10.5 - Network Configuration
- Create `/etc/hostname` with your chosen hostname.
- Create `/etc/hosts` with:

```
127.0.0.1      localhost
::1            localhost
127.0.1.1      computername
```
Replace "computername" with your hostname.

#### 1.10.6 - Set Root Password
`passwd`  
Enter a new password.

### 1.11 - Configure the GRUB Bootloader
GRUB is used here; alternative bootloaders require separate configuration.

#### 1.11.1 - Install GRUB (BIOS)
`grub-install --verbose --target=i386-pc /dev/sda`

#### 1.11.2 - Install GRUB (UEFI)
`grub-install --verbose --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB`

#### 1.11.3 - Enable Microcode Updates
Intel CPU: `pacman -S intel-ucode`  
AMD CPU: `pacman -S amd-ucode`

#### 1.11.4 - Generate GRUB Configuration
`grub-mkconfig -o /boot/grub/grub.cfg`

### 1.12 - Boot the New System
- Exit chroot: `exit`
- Unmount partitions: `umount -R /mnt`
- Synchronize disks: `sync`
- Reboot: `reboot now`  
Remove the installation medium before booting.  
Log in as "root" with your password.

### 1.13 - Post-Installation Adjustments
Enable NetworkManager:  
`systemctl enable --now NetworkManager`  
Use `nmtui` for network configuration outside graphical sessions.

## Step 2 - Setting Up the Desktop Environment

### 2.1 - Create a System User
Add a user for Cinnamon:  
`useradd -m username`  
`passwd username`

### 2.2 - Install the Desktop Environment
Install packages:  
`pacman -S xorg xorg-apps xorg-drivers mesa lightdm lightdm-slick-greeter cinnamon gnome-terminal`

Configure LightDM: Edit `/etc/lightdm/lightdm.conf` and add/uncomment:  
```
[Seat:*]
greeter-session=lightdm-slick-greeter
```

Test LightDM: `systemctl start lightdm`  
If successful, enable it: `systemctl enable lightdm`  
Log in with the new user.

### 2.3 - Configure Keyboard Layout
Navigate to `Cinnamon Menu -> Keyboard -> Layouts`.  
Add your layout (+) and remove defaults (-).  

**Note:** As of October 19, 2025, keyboard layouts are supported only in X11 sessions; Wayland support is pending.

### 2.4 - Configure Sudo
Install sudo: `pacman -S sudo`  
As root (`su`), edit sudoers: `EDITOR=vim visudo`  
Add under "User privilege specification":  
```
username ALL=(ALL) ALL
```  
Switch to user: `su username`

### 2.5 - Enable the AUR
Install `yay`:  
`sudo pacman -S --needed git base-devel`  
`cd ~`  
`git clone https://aur.archlinux.org/yay.git`  
`cd yay`  
`makepkg -si`  
`cd ..`  
`rm -rf ./yay/`  
`yay -Syy`

### 2.6 - Customize Cinnamon to Resemble Linux Mint
#### 2.6.1 - Install Fonts
`yay -S --needed noto-fonts noto-fonts-emoji noto-fonts-cjk noto-fonts-extra`  
`yay -S --needed ttf-ubuntu-font-family`

In `Cinnamon Menu -> Font Selection`:

| Category          | Font               | Size |
|-------------------|--------------------|------|
| Default font      | Ubuntu Regular     | 10   |
| Desktop font      | Ubuntu Regular     | 10   |
| Document font     | Sans Regular       | 10   |
| Monospace font    | Monospace Regular  | 10   |
| Window title font | Ubuntu Medium      | 10   |

#### 2.6.2 - Install Themes and Icons
`yay -S --needed mint-themes mint-l-themes mint-y-icons mint-x-icons mint-l-icons bibata-cursor-theme xapp-symbolic-icons`  
Select Mint themes in `Cinnamon Menu -> Themes`.  

`yay -S --needed lightdm-settings`  

**Warning:** `mint-backgrounds` downloads large files (70 MiB+ per package); avoid on metered connections.  
`yay -S --needed mint-backgrounds mint-artwork`  
Select backgrounds in `Cinnamon Menu -> Backgrounds`.

### 2.7 - Add Printer Support
`yay -S --needed cups system-config-printer`  
`sudo systemctl enable --now cups`

### 2.8 - Install Default Linux Mint Applications
#### 2.8.1 - Accessories
`yay -S --needed file-roller yelp warpinator mintstick xed gnome-screenshot redshift seahorse onboard sticky xviewer gnome-font-viewer bulky xreader gnome-disk-utility gucharmap gnome-calculator`

#### 2.8.2 - Graphics
`yay -S --needed simple-scan pix drawing`

#### 2.8.3 - Internet
`yay -S --needed firefox webapp-manager thunderbird transmission-gtk`  
*Note: `hexchat` is GTK2-based and unmaintained yet part of Linux Mint; install at your own risk.*

#### 2.8.4 - Office
`yay -S --needed gnome-calendar libreoffice-fresh`

#### 2.8.5 - Programming
`yay -S --needed python`

#### 2.8.6 - Sound & Video
`yay -S --needed celluloid hypnotix rhythmbox`

#### 2.8.7 - Administration
`yay -S --needed baobab gnome-logs timeshift fingwit`

#### 2.8.8 - Preferences
`yay -S --needed gufw blueberry mintlocale gnome-online-accounts-gtk`  
Enable firewall: `systemctl enable --now ufw`

#### 2.8.9 - Utilities and Command-Line Tools
- Filesystem interoperability:  
`yay -S --needed ntfs-3g dosfstools mtools exfatprogs`  
*(Optional: `btrfs-progs`, `xfsprogs`, `e2fsprogs`, etc.)*

- Archive compression:  
`yay -S --needed unrar unace unarj arj lha lzo lzop unzip zip cpio pax p7zip`  
*Note: The `rar` AUR package conflicts with `unrar`; choose accordingly.*

- Other utilities
`yay -S --needd xviewer-plugins nemo-fileroller gvfs-goa gvfs-onedrive gvfs-google`

</DOCUMENT>
