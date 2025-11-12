#!/bin/bash
# LMAE Base System Installation Script
# This script should be run from the Arch Linux installation media after partitioning
#
# ⚠️ WARNING: EXPERIMENTAL SCRIPT
# This script is provided AS-IS without warranties.
# Review the code before running and use at your own risk.
# Make sure you have backups of any important data.

set -e  # Exit on error

echo "==================================="
echo "LMAE Base Installation Script"
echo "==================================="
echo ""

# Detect boot mode
if [ -d /sys/firmware/efi/efivars ]; then
    BOOT_MODE="UEFI"
    echo "✓ Boot mode detected: UEFI"
else
    BOOT_MODE="BIOS"
    echo "✓ Boot mode detected: BIOS"
fi

# Ask for root partition
echo ""
read -p "Enter the root partition (e.g., /dev/sda3): " ROOT_PARTITION
read -p "Enter the swap partition (e.g., /dev/sda2): " SWAP_PARTITION

if [ "$BOOT_MODE" == "UEFI" ]; then
    read -p "Enter the EFI partition (e.g., /dev/sda1): " EFI_PARTITION
fi

# Confirm
echo ""
echo "Configuration:"
echo "  Boot mode: $BOOT_MODE"
echo "  Root: $ROOT_PARTITION"
echo "  Swap: $SWAP_PARTITION"
if [ "$BOOT_MODE" == "UEFI" ]; then
    echo "  EFI: $EFI_PARTITION"
fi
echo ""
read -p "Continue with installation? (y/N): " CONFIRM

if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 1
fi

# Update system clock
echo ""
echo "==================================="
echo "Synchronizing system clock..."
echo "==================================="
timedatectl set-ntp true

# Install reflector and optimize mirrors
echo ""
echo "==================================="
echo "Optimizing package mirrors..."
echo "==================================="
pacman -S --needed --noconfirm reflector
reflector --country "United States" --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# Install base system
echo ""
echo "==================================="
echo "Installing base system..."
echo "==================================="
if [ "$BOOT_MODE" == "UEFI" ]; then
    pacstrap /mnt base linux linux-firmware networkmanager grub efibootmgr vim sudo nano
else
    pacstrap /mnt base linux linux-firmware networkmanager grub vim sudo nano
fi

# Generate fstab
echo ""
echo "==================================="
echo "Generating fstab..."
echo "==================================="
genfstab -pU /mnt >> /mnt/etc/fstab

echo ""
echo "==================================="
echo "Base installation completed!"
echo "==================================="
echo ""
echo "Next steps:"
echo "1. Run: arch-chroot /mnt"
echo "2. Copy 02-configure-system.sh to /root in the chroot"
echo "3. Run: bash /root/02-configure-system.sh"
echo ""
