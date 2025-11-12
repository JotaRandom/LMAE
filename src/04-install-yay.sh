#!/bin/bash
# LMAE YAY Installation Script
# This script should be run as the regular user (not root)
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
echo "LMAE YAY Installation Script"
echo "==================================="
echo ""

# Install yay
echo "Installing yay AUR helper..."
cd ~
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..
rm -rf ./yay/

# Update package database
yay -Syy

echo ""
echo "==================================="
echo "YAY installation completed!"
echo "==================================="
echo ""
echo "Next step:"
echo "Run 05-install-packages.sh to install all Linux Mint packages"
echo ""
