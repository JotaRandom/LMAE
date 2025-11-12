#!/bin/bash
# LMAE System Configuration Script
# This script should be run inside arch-chroot
#
# ⚠️ WARNING: EXPERIMENTAL SCRIPT
# This script is provided AS-IS without warranties.
# Review the code before running and use at your own risk.

set -e  # Exit on error

echo "==================================="
echo "LMAE System Configuration Script"
echo "==================================="
echo ""

# Get user input
read -p "Enter hostname (e.g., my-arch-mint): " HOSTNAME
read -p "Enter timezone (e.g., America/Mexico_City): " TIMEZONE
read -p "Enter locale (e.g., en_US.UTF-8): " LOCALE
read -p "Enter keyboard layout (e.g., la-latin1): " KEYMAP
read -p "CPU vendor (intel/amd): " CPU_VENDOR

# Validate inputs
if [ -z "$HOSTNAME" ]; then
    echo "ERROR: Hostname cannot be empty."
    exit 1
fi

if ! [[ "$HOSTNAME" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$ ]]; then
    echo "ERROR: Invalid hostname. Use only letters, numbers, and hyphens."
    exit 1
fi

if [ -z "$TIMEZONE" ] || [ ! -f "/usr/share/zoneinfo/$TIMEZONE" ]; then
    echo "ERROR: Invalid timezone '$TIMEZONE'."
    echo "Check available timezones in /usr/share/zoneinfo/"
    exit 1
fi

if [ -z "$LOCALE" ]; then
    echo "ERROR: Locale cannot be empty."
    exit 1
fi

if [ -z "$KEYMAP" ]; then
    echo "ERROR: Keyboard layout cannot be empty."
    exit 1
fi

if [ "$CPU_VENDOR" != "intel" ] && [ "$CPU_VENDOR" != "amd" ]; then
    echo "ERROR: CPU vendor must be 'intel' or 'amd'."
    exit 1
fi

# Detect boot mode
if [ -d /sys/firmware/efi/efivars ]; then
    BOOT_MODE="UEFI"
    echo "✓ Boot mode detected: UEFI"
else
    BOOT_MODE="BIOS"
    echo "✓ Boot mode detected: BIOS"
fi

if [ "$BOOT_MODE" == "BIOS" ]; then
    read -p "Enter disk for GRUB (e.g., /dev/sda): " GRUB_DISK
    
    if [ -z "$GRUB_DISK" ]; then
        echo "ERROR: GRUB disk cannot be empty for BIOS mode."
        exit 1
    fi
    
    if [ ! -b "$GRUB_DISK" ]; then
        echo "ERROR: $GRUB_DISK is not a valid block device."
        exit 1
    fi
fi

# Configure timezone
echo ""
echo "==================================="
echo "Configuring timezone..."
echo "==================================="
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc

# Configure locale
echo ""
echo "==================================="
echo "Configuring locale..."
echo "==================================="
# Remove duplicates first (escape special characters in locale)
ESCAPED_LOCALE=$(printf '%s\n' "$LOCALE" | sed 's/[.[\*^$/]/\\&/g')
sed -i "/^${ESCAPED_LOCALE} UTF-8/d" /etc/locale.gen 2>/dev/null || true
sed -i '/^en_US.UTF-8 UTF-8/d' /etc/locale.gen 2>/dev/null || true
# Add locales
echo "$LOCALE UTF-8" >> /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=$LOCALE" > /etc/locale.conf

# Configure keyboard
echo "KEYMAP=$KEYMAP" > /etc/vconsole.conf

# Configure hostname
echo ""
echo "==================================="
echo "Configuring network..."
echo "==================================="
echo "$HOSTNAME" > /etc/hostname
# Create hosts file
cat > /etc/hosts << EOF
127.0.0.1      localhost
::1            localhost
127.0.1.1      $HOSTNAME
EOF

# Set root password
echo ""
echo "==================================="
echo "Set root password:"
echo "==================================="
passwd

# Enable multilib and Color in pacman
echo ""
echo "==================================="
echo "Configuring pacman..."
echo "==================================="
sed -i 's/#Color/Color/' /etc/pacman.conf
sed -i '/\[multilib\]/,/Include/ s/^#//' /etc/pacman.conf
pacman -Syu --noconfirm

# Install microcode
echo ""
echo "==================================="
echo "Installing microcode..."
echo "==================================="
if [ "$CPU_VENDOR" == "intel" ]; then
    pacman -S --noconfirm intel-ucode
elif [ "$CPU_VENDOR" == "amd" ]; then
    pacman -S --noconfirm amd-ucode
fi

# Install and configure GRUB
echo ""
echo "==================================="
echo "Installing GRUB..."
echo "==================================="
if [ "$BOOT_MODE" == "UEFI" ]; then
    grub-install --verbose --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
else
    grub-install --verbose --target=i386-pc $GRUB_DISK
fi

grub-mkconfig -o /boot/grub/grub.cfg

# Enable NetworkManager
systemctl enable NetworkManager

# Install and enable reflector timer
pacman -S --needed --noconfirm reflector
systemctl enable reflector.timer

echo ""
echo "==================================="
echo "System configuration completed!"
echo "==================================="
echo ""
echo "Next steps:"
echo "1. Exit chroot: exit"
echo "2. Unmount: umount -R /mnt"
echo "3. Sync: sync"
echo "4. Reboot: reboot now"
echo "5. After reboot, run 03-desktop-install.sh as root"
echo ""
