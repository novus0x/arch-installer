# 🧪 Arch Linux Autoinstaller - Novus0x

This project provides an **automated Arch Linux installation script** designed to run using the ***Arch Linux image*** on a USB flash drive. Upon boot, the user can customize their installation using an interactive wizard.

> ⚠️ Ideal for advanced or technical users who want to install Arch Linux quickly, with clean or custom installation options.

[!] is currently under testing 

---

## 🚀 What does this script do?

✅ Automates the installation of Arch Linux from scratch.
✅ Detects whether the system is in **UEFI** or **BIOS (Legacy)** mode.
✅ Allows the user to configure:

- Hostname
- Username and passwords
- Keyboard layout
- Installation type: clean or custom (“Novus0x”)

---

## 📦 Components installed by default

These packages are installed during the minimal installation:

- `base`, `linux`, `linux-firmware`
- `sudo`, `grub`, `efibootmgr` (if UEFI)
- `NetworkManager` (activated automatically)
- Regional, timezone, and user settings
- Automatic partitioning with `sgdisk`, formatting with `mkfs.fat` and `mkfs.ext4`

---

## 🧠 Requirements (method 2)

- **A bootable USB drive** with arch linux iso

---

## 🧩 Installation and Use

1. Insert your USB drive with the ***Arch linux image***
2. From the live environment:

```bash
curl -O https://raw.githubusercontent.com/novus0x/arch-installer/refs/heads/main/arch-install.sh
chmod +x arch-install.sh
./arch-install.sh
```
