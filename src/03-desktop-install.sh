#!/bin/bash
# LMAE Desktop Environment Installation Script
# This script should be run after the first reboot, as root
#
# ⚠️ WARNING: EXPERIMENTAL SCRIPT
# This script is provided AS-IS without warranties.
# Review the code before running and use at your own risk.

set -e  # Exit on error

echo "==================================="
echo "LMAE Desktop Installation Script"
echo "==================================="
echo ""

# Get user information
read -p "Enter username for desktop user: " USERNAME

# Create user
echo ""
echo "==================================="
echo "Creating user..."
echo "==================================="
if id "$USERNAME" &>/dev/null; then
    echo "User $USERNAME already exists. Skipping user creation."
else
    useradd -m -G wheel $USERNAME
    echo "Set password for $USERNAME:"
    passwd $USERNAME
fi

# Configure sudo
echo ""
echo "==================================="
echo "Configuring sudo..."
echo "==================================="
# Uncomment wheel group line if not already done
if ! grep -q "^%wheel ALL=(ALL) ALL" /etc/sudoers; then
    sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
fi

# Install desktop environment
echo ""
echo "==================================="
echo "Installing desktop environment..."
echo "==================================="
pacman -S --noconfirm xorg xorg-apps xorg-drivers mesa lightdm lightdm-slick-greeter cinnamon cinnamon-translations gnome-terminal xdg-user-dirs xdg-user-dirs-gtk

# Configure LightDM
echo ""
echo "==================================="
echo "Configuring LightDM..."
echo "==================================="
sed -i 's/^#greeter-session=.*/greeter-session=lightdm-slick-greeter/' /etc/lightdm/lightdm.conf

# Enable LightDM
systemctl enable lightdm

# Install base-devel and git for AUR
echo ""
echo "==================================="
echo "Installing base-devel and git..."
echo "==================================="
pacman -S --noconfirm --needed git base-devel

echo ""
echo "==================================="
echo "Desktop installation completed!"
echo "==================================="
echo ""
echo "Next steps:"
echo "1. Reboot the system"
echo "2. Login as $USERNAME"
echo "3. Run 04-install-yay.sh as the user"
echo "4. Run 05-install-packages.sh to install all Mint packages"
echo ""
