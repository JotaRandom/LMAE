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
    PARTITION_TABLE=""  # Not applicable for UEFI
    echo "✓ Boot mode detected: UEFI"
else
    BOOT_MODE="BIOS"
    echo "✓ Boot mode detected: BIOS"
fi

# Ask for partition table type if BIOS
if [ "$BOOT_MODE" == "BIOS" ]; then
    echo ""
    echo "Partition table type:"
    echo "  1) MBR (msdos) - Traditional BIOS"
    echo "  2) GPT - Modern (requires BIOS boot partition)"
    read -p "Select [1-2]: " PT_CHOICE
    
    if [ "$PT_CHOICE" == "2" ]; then
        PARTITION_TABLE="GPT"
    else
        PARTITION_TABLE="MBR"
    fi
    echo "✓ Partition table: $PARTITION_TABLE"
fi

# Ask for partitions
echo ""
read -p "Enter the root partition (e.g., /dev/sda3): " ROOT_PARTITION
read -p "Enter the swap partition (e.g., /dev/sda2): " SWAP_PARTITION

if [ "$BOOT_MODE" == "UEFI" ]; then
    read -p "Enter the EFI partition (e.g., /dev/sda1): " EFI_PARTITION
elif [ "$PARTITION_TABLE" == "GPT" ]; then
    read -p "Enter the BIOS boot partition (e.g., /dev/sda1): " BIOS_BOOT_PARTITION
fi

# Ask for separate home partition
read -p "Do you have a separate /home partition? (y/N): " HAS_HOME
if [[ $HAS_HOME =~ ^[Yy]$ ]]; then
    read -p "Enter the /home partition (e.g., /dev/sda4): " HOME_PARTITION
fi

# Validate partitions
if [ -z "$ROOT_PARTITION" ] || [ -z "$SWAP_PARTITION" ]; then
    echo "ERROR: Root and swap partitions are required."
    exit 1
fi

if [ "$BOOT_MODE" == "UEFI" ] && [ -z "$EFI_PARTITION" ]; then
    echo "ERROR: EFI partition is required for UEFI boot."
    exit 1
fi

if [ "$BOOT_MODE" == "BIOS" ] && [ "$PARTITION_TABLE" == "GPT" ] && [ -z "$BIOS_BOOT_PARTITION" ]; then
    echo "ERROR: BIOS boot partition is required for GPT on BIOS systems."
    exit 1
fi

if [[ $HAS_HOME =~ ^[Yy]$ ]] && [ -z "$HOME_PARTITION" ]; then
    echo "ERROR: /home partition path is required."
    exit 1
fi

if [ ! -b "$ROOT_PARTITION" ]; then
    echo "ERROR: $ROOT_PARTITION is not a valid block device."
    exit 1
fi

if [ ! -b "$SWAP_PARTITION" ]; then
    echo "ERROR: $SWAP_PARTITION is not a valid block device."
    exit 1
fi

if [ "$BOOT_MODE" == "UEFI" ] && [ ! -b "$EFI_PARTITION" ]; then
    echo "ERROR: $EFI_PARTITION is not a valid block device."
    exit 1
fi

if [ "$BOOT_MODE" == "BIOS" ] && [ "$PARTITION_TABLE" == "GPT" ] && [ ! -b "$BIOS_BOOT_PARTITION" ]; then
    echo "ERROR: $BIOS_BOOT_PARTITION is not a valid block device."
    exit 1
fi

if [[ $HAS_HOME =~ ^[Yy]$ ]] && [ ! -b "$HOME_PARTITION" ]; then
    echo "ERROR: $HOME_PARTITION is not a valid block device."
    exit 1
fi

# Confirm
echo ""
echo "Configuration:"
echo "  Boot mode: $BOOT_MODE"
if [ "$BOOT_MODE" == "BIOS" ]; then
    echo "  Partition table: $PARTITION_TABLE"
fi
echo "  Root: $ROOT_PARTITION"
echo "  Swap: $SWAP_PARTITION"
if [ "$BOOT_MODE" == "UEFI" ]; then
    echo "  EFI: $EFI_PARTITION"
elif [ "$PARTITION_TABLE" == "GPT" ]; then
    echo "  BIOS boot: $BIOS_BOOT_PARTITION"
fi
if [[ $HAS_HOME =~ ^[Yy]$ ]]; then
    echo "  Home: $HOME_PARTITION"
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

# Mount partitions
echo ""
echo "==================================="
echo "Mounting partitions..."
echo "==================================="

# Unmount if already mounted (for re-runs)
if mountpoint -q /mnt/boot 2>/dev/null; then
    umount /mnt/boot
fi

if mountpoint -q /mnt/home 2>/dev/null; then
    umount /mnt/home
fi

if mountpoint -q /mnt 2>/dev/null; then
    umount /mnt
fi

# Detect filesystem type for root partition
ROOT_FS=$(blkid -o value -s TYPE "$ROOT_PARTITION")
echo "Detected root filesystem: $ROOT_FS"

# Set mount options based on filesystem
case "$ROOT_FS" in
    ext4)
        MOUNT_OPTS="defaults,noatime,commit=60"
        ;;
    btrfs)
        MOUNT_OPTS="defaults,noatime,compress=zstd,space_cache=v2"
        ;;
    xfs)
        MOUNT_OPTS="defaults,noatime,inode64"
        ;;
    *)
        MOUNT_OPTS="defaults,relatime"
        ;;
esac

# Mount root with optimized options
mount -o "$MOUNT_OPTS" "$ROOT_PARTITION" /mnt
echo "Mounted root with options: $MOUNT_OPTS"

# Activate swap (deactivate first if already active)
if swapon --show | grep -q "$SWAP_PARTITION"; then
    swapoff "$SWAP_PARTITION"
fi
swapon "$SWAP_PARTITION"

# Mount EFI if UEFI
if [ "$BOOT_MODE" == "UEFI" ]; then
    mkdir -p /mnt/boot
    mount "$EFI_PARTITION" /mnt/boot
fi

# Mount home if separate (with same optimizations)
if [[ $HAS_HOME =~ ^[Yy]$ ]]; then
    mkdir -p /mnt/home
    HOME_FS=$(blkid -o value -s TYPE "$HOME_PARTITION")
    
    case "$HOME_FS" in
        ext4)
            HOME_OPTS="defaults,noatime,commit=60"
            ;;
        btrfs)
            HOME_OPTS="defaults,noatime,compress=zstd,space_cache=v2"
            ;;
        xfs)
            HOME_OPTS="defaults,noatime,inode64"
            ;;
        *)
            HOME_OPTS="defaults,relatime"
            ;;
    esac
    
    mount -o "$HOME_OPTS" "$HOME_PARTITION" /mnt/home
    echo "Mounted /home with options: $HOME_OPTS"
fi

echo "✓ Partitions mounted successfully"

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

# Save installation info for next script
echo ""
echo "Saving installation configuration..."
cat > /mnt/root/.lmae-install-info << EOF
BOOT_MODE=$BOOT_MODE
PARTITION_TABLE=$PARTITION_TABLE
ROOT_PARTITION=$ROOT_PARTITION
SWAP_PARTITION=$SWAP_PARTITION
EFI_PARTITION=${EFI_PARTITION:-}
BIOS_BOOT_PARTITION=${BIOS_BOOT_PARTITION:-}
HOME_PARTITION=${HOME_PARTITION:-}
EOF

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
