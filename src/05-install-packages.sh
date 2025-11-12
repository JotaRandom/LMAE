#!/bin/bash
# LMAE Packages Installation Script
# This script installs all Linux Mint packages and applications
# Run as regular user (not root)
#
# ⚠️ WARNING: EXPERIMENTAL SCRIPT
# This script is provided AS-IS without warranties.
# Review the code before running and use at your own risk.

set -e  # Exit on error

if [ "$EUID" -eq 0 ]; then
    echo "ERROR: Do not run this script as root!"
    echo "Run as your regular user."
    exit 1
fi

echo "==================================="
echo "LMAE Packages Installation Script"
echo "==================================="
echo ""

# Fonts
echo ""
echo "==================================="
echo "Installing fonts..."
echo "==================================="
yay -S --needed --noconfirm noto-fonts noto-fonts-emoji noto-fonts-cjk noto-fonts-extra ttf-ubuntu-font-family

# Themes and icons
echo ""
echo "==================================="
echo "Installing themes and icons..."
echo "==================================="
yay -S --needed --noconfirm mint-themes mint-l-themes mint-y-icons mint-x-icons mint-l-icons bibata-cursor-theme xapp-symbolic-icons

# LightDM settings
echo ""
echo "==================================="
echo "Installing LightDM settings..."
echo "==================================="
yay -S --needed --noconfirm lightdm-settings

# Wallpapers (optional - large download)
read -p "Install Linux Mint wallpapers? (70+ MiB each) (y/N): " INSTALL_WALLS
if [[ $INSTALL_WALLS =~ ^[Yy]$ ]]; then
    echo "Installing wallpapers..."
    yay -S --needed --noconfirm mint-backgrounds mint-artwork
fi

# Printer support
echo ""
echo "==================================="
echo "Installing printer support..."
echo "==================================="
yay -S --needed --noconfirm cups system-config-printer
sudo systemctl enable --now cups

# Audio (PipeWire)
echo ""
echo "==================================="
echo "Installing PipeWire audio..."
echo "==================================="
yay -S --needed --noconfirm pipewire-audio wireplumber pipewire-alsa pipewire-pulse pipewire-jack pavucontrol

# Bluetooth
echo ""
echo "==================================="
echo "Installing Bluetooth support..."
echo "==================================="
yay -S --needed --noconfirm bluez bluez-utils
sudo systemctl enable --now bluetooth

# System tools and accessories
echo ""
echo "==================================="
echo "Installing system tools..."
echo "==================================="
yay -S --needed --noconfirm file-roller yelp warpinator mintstick xed gnome-screenshot redshift seahorse onboard sticky xviewer gnome-font-viewer bulky xreader gnome-disk-utility gucharmap gnome-calculator

# Graphics applications
echo ""
echo "==================================="
echo "Installing graphics applications..."
echo "==================================="
yay -S --needed --noconfirm simple-scan pix drawing

# Internet applications
echo ""
echo "==================================="
echo "Installing internet applications..."
echo "==================================="
yay -S --needed --noconfirm firefox webapp-manager thunderbird transmission-gtk

# Office suite
echo ""
echo "==================================="
echo "Installing office suite..."
echo "==================================="
yay -S --needed --noconfirm gnome-calendar libreoffice-fresh

# Development tools
echo ""
echo "==================================="
echo "Installing development tools..."
echo "==================================="
yay -S --needed --noconfirm python

# Multimedia
echo ""
echo "==================================="
echo "Installing multimedia applications..."
echo "==================================="
yay -S --needed --noconfirm rhythmbox celluloid

# Administration tools
echo ""
echo "==================================="
echo "Installing administration tools..."
echo "==================================="
yay -S --needed --noconfirm timeshift gnome-logs baobab

# Configuration tools
echo ""
echo "==================================="
echo "Installing configuration tools..."
echo "==================================="
yay -S --needed --noconfirm nemo nemo-fileroller nemo-image-converter nemo-preview nemo-share blueberry system-config-printer

# Filesystem support
echo ""
echo "==================================="
echo "Installing filesystem support..."
echo "==================================="
yay -S --needed --noconfirm ntfs-3g exfat-utils dosfstools btrfs-progs xfsprogs f2fs-tools

# Compression tools
echo ""
echo "==================================="
echo "Installing compression tools..."
echo "==================================="
yay -S --needed --noconfirm unrar unace lrzip

# Additional integrations
echo ""
echo "==================================="
echo "Installing additional integrations..."
echo "==================================="
yay -S --needed --noconfirm xdg-desktop-portal-gtk xdg-utils

# Laptop optimizations (optional)
read -p "Is this a laptop? Install laptop optimizations? (y/N): " IS_LAPTOP
if [[ $IS_LAPTOP =~ ^[Yy]$ ]]; then
    echo ""
    echo "==================================="
    echo "Installing laptop optimizations..."
    echo "==================================="
    
    read -p "Install TLP for power management? (recommended) (Y/n): " INSTALL_TLP
    if [[ ! $INSTALL_TLP =~ ^[Nn]$ ]]; then
        yay -S --needed --noconfirm tlp tlp-rdw
        sudo systemctl enable --now tlp
    fi
    
    yay -S --needed --noconfirm linux-tools-meta lm_sensors brightnessctl libinput-gestures xf86-input-libinput
fi

echo ""
echo "==================================="
echo "Package installation completed!"
echo "==================================="
echo ""
echo "Recommendations:"
echo "1. Reboot the system to ensure everything is loaded"
echo "2. Configure Timeshift for system backups"
echo "3. Customize desktop themes and appearance"
echo "4. Run 'sudo sensors-detect' if you installed lm_sensors"
echo ""
