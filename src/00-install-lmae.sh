#!/bin/bash
# LMAE Master Installation Script
# This script detects the environment and runs the appropriate installation script
#
# ⚠️ WARNING: EXPERIMENTAL SCRIPT
# This script is provided AS-IS without warranties.
# Review the code before running and use at your own risk.
# Make sure you have backups of any important data.

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to detect environment
detect_environment() {
    # Check if running in chroot
    if [ "$(stat -c %d:%i /)" != "$(stat -c %d:%i /proc/1/root/.)" ]; then
        echo "chroot"
        return
    fi
    
    # Check if running from live environment
    if grep -q "archiso" /proc/cmdline 2>/dev/null; then
        echo "livecd"
        return
    fi
    
    # Check if system is installed (has /etc/arch-release and not live)
    if [ -f /etc/arch-release ] && [ ! -f /run/archiso/bootmnt/arch/boot/x86_64/vmlinuz-linux ]; then
        # Check if desktop is installed
        if systemctl list-unit-files | grep -q lightdm.service; then
            echo "installed-desktop"
        else
            echo "installed-base"
        fi
        return
    fi
    
    echo "unknown"
}

# Function to check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        return 1
    fi
    return 0
}

# Main script
clear
echo "==================================="
echo "  LMAE Installation Manager"
echo "==================================="
echo ""
print_warning "This script is EXPERIMENTAL. Use at your own risk!"
echo ""

# Detect environment
ENV=$(detect_environment)
print_info "Detected environment: $ENV"
echo ""

case "$ENV" in
    "livecd")
        print_info "You are running from the Arch Linux installation media."
        echo ""
        echo "Available actions:"
        echo "  1) Install base system (01-base-install.sh)"
        echo "  2) Exit"
        echo ""
        read -p "Choose an option [1-2]: " choice
        
        case "$choice" in
            1)
                if ! check_root; then
                    print_error "This script must be run as root in the live environment."
                    print_info "Run: sudo bash $0"
                    exit 1
                fi
                
                print_info "Starting base installation..."
                echo ""
                
                # Check if script exists
                SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
                if [ ! -f "$SCRIPT_DIR/01-base-install.sh" ]; then
                    print_error "01-base-install.sh not found in $SCRIPT_DIR"
                    exit 1
                fi
                
                bash "$SCRIPT_DIR/01-base-install.sh"
                ;;
            2)
                print_info "Exiting..."
                exit 0
                ;;
            *)
                print_error "Invalid option"
                exit 1
                ;;
        esac
        ;;
        
    "chroot")
        print_info "You are inside a chroot environment."
        echo ""
        echo "Available actions:"
        echo "  1) Configure system (02-configure-system.sh)"
        echo "  2) Exit"
        echo ""
        read -p "Choose an option [1-2]: " choice
        
        case "$choice" in
            1)
                if ! check_root; then
                    print_error "This script must be run as root in chroot."
                    exit 1
                fi
                
                print_info "Starting system configuration..."
                echo ""
                
                # Check if script exists
                SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
                if [ ! -f "$SCRIPT_DIR/02-configure-system.sh" ]; then
                    print_error "02-configure-system.sh not found in $SCRIPT_DIR"
                    exit 1
                fi
                
                bash "$SCRIPT_DIR/02-configure-system.sh"
                ;;
            2)
                print_info "Exiting..."
                exit 0
                ;;
            *)
                print_error "Invalid option"
                exit 1
                ;;
        esac
        ;;
        
    "installed-base")
        print_info "You are on an installed Arch Linux system (base only, no desktop)."
        echo ""
        echo "Available actions:"
        echo "  1) Install desktop environment (03-desktop-install.sh)"
        echo "  2) Exit"
        echo ""
        read -p "Choose an option [1-2]: " choice
        
        case "$choice" in
            1)
                if ! check_root; then
                    print_error "This script must be run as root."
                    print_info "Run: sudo bash $0"
                    exit 1
                fi
                
                print_info "Starting desktop installation..."
                echo ""
                
                # Check if script exists
                SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
                if [ ! -f "$SCRIPT_DIR/03-desktop-install.sh" ]; then
                    print_error "03-desktop-install.sh not found in $SCRIPT_DIR"
                    exit 1
                fi
                
                bash "$SCRIPT_DIR/03-desktop-install.sh"
                ;;
            2)
                print_info "Exiting..."
                exit 0
                ;;
            *)
                print_error "Invalid option"
                exit 1
                ;;
        esac
        ;;
        
    "installed-desktop")
        print_info "You are on an installed Arch Linux system with desktop."
        echo ""
        
        if check_root; then
            print_warning "Running as root. Some actions require regular user."
        fi
        
        echo "Available actions:"
        echo "  1) Install YAY (04-install-yay.sh) - Run as regular user"
        echo "  2) Install all packages (05-install-packages.sh) - Run as regular user"
        echo "  3) Exit"
        echo ""
        read -p "Choose an option [1-3]: " choice
        
        case "$choice" in
            1)
                if check_root; then
                    print_error "YAY installation must be run as a regular user, not root."
                    print_info "Exit root and run: bash $0"
                    exit 1
                fi
                
                print_info "Starting YAY installation..."
                echo ""
                
                # Check if script exists
                SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
                if [ ! -f "$SCRIPT_DIR/04-install-yay.sh" ]; then
                    print_error "04-install-yay.sh not found in $SCRIPT_DIR"
                    exit 1
                fi
                
                bash "$SCRIPT_DIR/04-install-yay.sh"
                ;;
            2)
                if check_root; then
                    print_error "Package installation must be run as a regular user, not root."
                    print_info "Exit root and run: bash $0"
                    exit 1
                fi
                
                print_info "Starting package installation..."
                echo ""
                
                # Check if script exists
                SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
                if [ ! -f "$SCRIPT_DIR/05-install-packages.sh" ]; then
                    print_error "05-install-packages.sh not found in $SCRIPT_DIR"
                    exit 1
                fi
                
                bash "$SCRIPT_DIR/05-install-packages.sh"
                ;;
            3)
                print_info "Exiting..."
                exit 0
                ;;
            *)
                print_error "Invalid option"
                exit 1
                ;;
        esac
        ;;
        
    "unknown")
        print_error "Unable to detect environment."
        echo ""
        print_info "Please run the appropriate script manually:"
        echo "  - From live CD: 01-base-install.sh"
        echo "  - In chroot: 02-configure-system.sh"
        echo "  - After first boot: 03-desktop-install.sh"
        echo "  - With desktop installed (as user): 04-install-yay.sh"
        echo "  - With YAY installed (as user): 05-install-packages.sh"
        exit 1
        ;;
esac

print_success "Script completed successfully!"
