# LMAE Installation Scripts

Automated installation scripts for Linux Mint Arch Edition.

## ⚠️ WARNING - EXPERIMENTAL STATUS

**These scripts are experimental and provided AS-IS without warranties.**

- **NOT** a replacement for the official Arch Linux installer
- **NOT** exhaustively tested in all possible scenarios
- **May contain errors** resulting in an unbootable system or data loss
- **Strongly recommended** to follow the main README manual guide to understand each step
- Use at your own risk, especially on production systems or important data
- **Make backups** before using these scripts

**For new users:** Following the manual step-by-step guide is recommended to understand the installation process.

**For experienced users:** These scripts can save time on reinstallations, but review the code before running.

## Quick Usage (Recommended)

The master script automatically detects the environment and runs the appropriate script:

```bash
bash 00-install-lmae.sh
```

Detects if you are in:

- **Live CD**: Base installation
- **Chroot**: System configuration
- **Installed system without desktop**: Desktop installation
- **System with desktop**: YAY and packages installation

## Available Scripts

| # | Script | Run as | When |
|---|--------|--------|------|
| 0 | `00-install-lmae.sh` | root/user | Anytime (auto-detects environment) |
| 1 | `01-base-install.sh` | root | From installation media, after partitioning |
| 2 | `02-configure-system.sh` | root | Inside arch-chroot |
| 3 | `03-desktop-install.sh` | root | After first reboot |
| 4 | `04-install-yay.sh` | user | After reboot with desktop |
| 5 | `05-install-packages.sh` | user | After installing yay |

## Complete Process

### With Master Script (Recommended)

```bash
# At each stage, simply run:
bash 00-install-lmae.sh
```

### Manual (Individual Scripts)

```bash
# 1. From installation media
bash 01-base-install.sh

# 2. In chroot
cp 02-configure-system.sh /mnt/root/
arch-chroot /mnt
bash /root/02-configure-system.sh
exit

# 3. Unmount and reboot
umount -R /mnt
sync
reboot

# 4. After reboot (as root)
bash 03-desktop-install.sh
reboot

# 5. After reboot (as user)
bash 04-install-yay.sh
bash 05-install-packages.sh
reboot
```

## Customization

Edit scripts before running to:

- Change reflector country
- Modify package list
- Adjust specific configurations

## Important Notes

- **Always review scripts before running**
- Scripts stop on errors (`set -e`)
- Some require user input
- Designed to be idempotent when possible

## Troubleshooting

If a script fails:

1. Read the error message
2. Fix the problem manually
3. Continue with next step or re-run the script

## Contributions

If you find errors or improvements, open an issue or pull request on the repository.
