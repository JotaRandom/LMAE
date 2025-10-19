# LMAE
Create your own Linux Mint Arch Edition.

# How to Create Your Own "LMAE" - Linux Mint Arch Edition

## Step 1 - Installing Arch Linux

### 1.1 - Download an Arch ISO
You can download the ISO from the official Arch Linux website:  
[https://archlinux.org/download/](https://archlinux.org/download/)

### 1.2 - Flash the ISO with the Flash Tool of Your Choice
- balenaEtcher
- Win32 Disk Imager
- Rufus

### 1.3 - Boot Your Computer with Your Flashed USB/CD

### 1.4 - Set Up Your Keyboard Layout
You can list available keymaps with:  
`ls /usr/share/kbd/keymaps/**/*.map.gz`  
Apply the keymap of your choice with:  
`loadkeys la-latin1`  
*Example for the Latin American Spanish keymap*

### 1.5 - Check If Your Internet Connection Is Working
Ensure your network interface is listed and enabled. You can check this with:  
`ip link`

In case of a Wi-Fi connection, you can use:  
`iwctl`  
Follow the help within the command.

Check if you can establish a connection:  
`ping 8.8.8.8`

### 1.6 - Update the System Clock
Ensure the system clock is accurate:  
`timedatectl set-ntp true`

### 1.7 - Verify the Boot Mode
`ls /sys/firmware/efi/efivars`  
If the result is "No such file or directory", you need to install Arch in BIOS mode. If you get a list of the efivars, you should install Arch in UEFI mode.

### 1.8 - Set Up Your Disks
#### 1.8.1 - Locate Your Disk
List your disks and find the disk on which you want to install LMAE:  
`fdisk -l`  
What we need is the path of the disk you want to use. The path should look like `/dev/sda`, `/dev/nvme0n1`, or `/dev/mmcblk0`.

#### 1.8.2 - Partition Your Disk
When partitioning, I use the GPT partition table. If you want to use another one, you have to know the partitioning yourself.

Example layouts:

**UEFI / GPT**

| Mount Point | Partition Type   | Suggested Size             |
|-------------|------------------|----------------------------|
| `/mnt/boot` | EFI System       | 500MB or more              |
| -           | Linux swap       | More than 512 MiB          |
| `/mnt`      | Linux filesystem | The rest of the disk space |

**BIOS / GPT**

| Mount Point | Partition Type   | Suggested Size             |
|-------------|------------------|----------------------------|
| -           | BIOS boot        | 500MB or more              |
| -           | Linux swap       | More than 512 MiB          |
| `/mnt`      | Linux filesystem | The rest of the disk space |

Now open the disk you want to use in `cfdisk`. This should look like:  
`cfdisk /dev/sda`  
Choose "gpt" and press "Enter". Then create the partitions depending on whether you have UEFI or BIOS. After that, choose the partition type, write the changes, and quit `cfdisk`.

#### 1.8.3 - Format Your Disk
The created partitions must be formatted. Here, we differentiate between UEFI and BIOS.

**Example for UEFI:**
- `mkswap /dev/sda2` | Format as "Linux swap (swap)"
- `mkfs.ext4 /dev/sda3` | Format as "Linux filesystem (ext4)"
- `mkfs.fat -F 32 /dev/sda1` | Format as "FAT32"

**Example for BIOS:**
- `mkswap /dev/sda2` | Format as "Linux swap (swap)"
- `mkfs.ext4 /dev/sda3` | Format as "Linux filesystem (ext4)"

#### 1.8.4 - Mount Your Disk
First, mount the "Linux filesystem" to `/mnt`:  
`mount /dev/sda3 /mnt`

Second, mount the "Linux swap":  
`swapon /dev/sda2`

If using UEFI, create the mount point `/mnt/boot` and mount the "EFI System" partition:  
- `mkdir /mnt/boot`
- `mount /dev/sda1 /mnt/boot`

### 1.9 - Installation of the Base System
Install the necessary packages to get the system up and running:  
`pacstrap /mnt base linux linux-firmware networkmanager grub vim`

### 1.10 - Configure the System
#### 1.10.1 - Generate an fstab
Generate an fstab file to mount disks automatically when booting:  
`genfstab -pU /mnt >> /mnt/etc/fstab`

#### 1.10.2 - Change the Root to the New System
Change the root to `/mnt`:  
`arch-chroot /mnt`

#### 1.10.3 - Set Up the System Time
To change the timezone, replace "Region" and "City" with your timezone:  
`ln -sf /usr/share/zoneinfo/Region/City /etc/localtime`

Sync the system time with the hardware clock:  
`hwclock --systohc`

#### 1.10.4 - Create the Localization
- Edit `/etc/locale.gen` with your favorite editor and uncomment the locales you want to use. Also, uncomment `en_US.UTF-8`.
- Generate the locales: `locale-gen`
- Create the file `/etc/locale.conf` and define your preferred locale, e.g., `LANG=en_US.UTF-8`.
- Create the file `/etc/vconsole.conf` and set your keyboard layout, e.g., `KEYMAP=de-latin1` (replace with your preferred layout).

#### 1.10.5 - Network Configuration
- Create and edit `/etc/hostname`. Choose a computer name and insert it.
- Create `/etc/hosts` and insert the following, replacing "computername" with the name set in `/etc/hostname`:

```
127.0.0.1      localhost
::1            localhost
127.0.1.1      computername
```

#### 1.10.6 - Set the Root Password
Change the root password:  
`passwd`  
Set a new password.

### 1.11 - Configuring the GRUB Boot Loader
If you want to install a different bootloader, you must do this yourself, as only GRUB is explained here.

#### 1.11.1 - Set Up GRUB with BIOS
`grub-install --target=i386-pc /dev/sda`

#### 1.11.2 - Set Up GRUB with UEFI
`grub-install --target=x86_64-efi --efi-directory=esp --bootloader-id=GRUB`

#### 1.11.3 - Enable Microcode Updates
For Intel CPU: `pacman -S intel-ucode`  
For AMD CPU: `pacman -S amd-ucode`

#### 1.11.4 - Generate the GRUB Configuration
`grub-mkconfig -o /boot/grub/grub.cfg`

### 1.12 - Loading the New System
- Exit the chroot environment: `exit`
- Unmount the partitions: `umount -R /mnt`
- Sinchronize your system just in case: `sync`
- Boot into the new system: `reboot now`
Ensure the installation medium is disconnected before booting.
- Log in using the username "root" and your password.

### 1.13 - Important Changes to the New System
Enable NetworkManager:  
`systemctl enable --now NetworkManager`

## Step 2 - Setting Up the Desktop Environment

### 2.1 - Adding a System User
Create a system user for Cinnamon and set their password:  
`useradd -m username` | Replace "username" with the desired name.  
`passwd username` | Replace "username" with the name used above.

### 2.2 - Installing the Desktop Environment
- Install the necessary packages:  
`pacman -S xorg xorg-apps xorg-drivers mesa lightdm lightdm-slick-greeter cinnamon gnome-terminal`
- Linux Mint use lightdm-slick-greeter which need some configurations.
```
# Edit your /etc/lightdm/lightdm.conf and add this at the bottom
[Seat:*]
greeter-session=lightdm-slick-greeter
# Or if you find the seccion within the file edir and uncoment if needed
```
- Now lets test if lightdm is adeuatelly created running
`systemctl start lightdm` if you get into the login greeter you can enable
permanently lightdm using `systemctl enable lightdm` from within any terminal
either a TTY r gnome-terminal inside the session.
- Log in to the desktop using the password of the created user.

### 2.3 - Changing the Keyboard Layout
- Navigate to `Cinnamon Menu -> Keyboard -> Layouts`.
- Set the keyboard layout of your choice by adding it at the bottom left (+) and deleting the default (-).
#### Notes
At time of writing this [19 october 2025] keyboard layouting is only available
in X11 session, where Cinnamon over wayland still don't suppor this yet. 

### 2.4 - Set Up Sudo
- Install sudo: `pacman -S sudo`
- Log in as root: `su`
- Open the sudoers file: `EDITOR=vim visudo`
- Under "User privilege specification", add your user:

```
## User privilege specification
root ALL=(ALL) ALL
username ALL=(ALL) ALL
```

- Save and close the file.
- Switch back to the user account: `su username`
- Sudo is now set up and ready to use.

### 2.5 - Activating the AUR
To use the AUR, install `yay`:  
- Install necessary packages: `sudo pacman -S --needed git base-devel`
- Change to the user’s home directory: `cd ~`
- Download yay: `git clone https://aur.archlinux.org/yay.git`
- Change to the yay directory: `cd yay`
- Build and install yay: `makepkg -si`
- Return to the home directory: `cd ..`
- Delete the yay folder: `rm -rf ./yay/`
- Sync the package database: `yay -Syy`

### 2.6 - Making Cinnamon Look Like Linux Mint
#### 2.6.1 - Installing the Fonts
- Install noto fonts for international support:
`yay -S --needed noto-fonts noto-fonts-emoji noto-cjk noto-extras`
- Install now the font we going to use for Cinnamon:
`yay -S --needed ttf-ubuntu-font-family`
- Navigate to `Cinnamon Menu -> Font Selection` and set the following:

|                   | Font              | Size |
|-------------------|-------------------|------|
| Default font      | Ubuntu Regular    | 10   |
| Desktop font      | Ubuntu Regular    | 10   |
| Document font     | Sans Regular      | 10   |
| Monospace font    | Monospace Regular | 10   |
| Window title font | Ubuntu Medium     | 10   |

#### 2.6.2 - Installing the Mint Themes and Icons
- Install themes and icons:
`yay -S --needed mint-themes mint-l-themes mint-y-icons mint-x-icons mint-l-icons`
- Navigate to `Cinnamon Menu -> Themes` and choose the desired Mint themes.
- For the full Linux Mint experience, install:
`yay -S --needed mint-backgrounds mint-artwork`  
Then choose your favorite at `Cinnamon Menu -> Backgrounds`.

### 2.7 - Adding Printer Support
- Install printer support: `yay -S --needed cups system-config-printer`
- Enable CUPS: `sudo systemctl enable --now cups`

### 2.8 - Installing the Default Linux Mint Programs
#### 2.8.1 - Installing Programs from Category "Accessories"
`yay -S --needed file-roller yelp warpinator mintstick xed gnome-screenshot redshift seahorse onboard sticky xviewer gnome-font-viewer bulky xreader gnome-disk-utility gucharmap gnome-calculator`

#### 2.8.2 - Installing Programs from Category "Graphics"
`yay -S --needed simple-scan pix drawing`

#### 2.8.3 - Installing Programs from Category "Internet"
`yay -S --needed firefox webapp-manager hexchat thunderbird transmission-gtk`

#### 2.8.4 - Installing Programs from Category "Office"
`yay -S --needed gnome-calendar libreoffice-fresh`

#### 2.8.5 - Installing Programs from Category "Programming"
`yay -S --needed python`

#### 2.8.6 - Installing Programs from Category "Sound & Video"
`yay -S --needed celluloid hypnotix rhythmbox`

#### 2.8.7 - Installing Programs from Category "Administration"
`yay -S --needed baobab gnome-logs timeshift fingwit`

#### 2.8.8 - Installing Programs from Category "Preferences"
`yay -S --needed gufw blueberry mintlocale`

