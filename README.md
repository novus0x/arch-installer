# 🧪 Arch Linux Autoinstaller - Novus0x

This project provides an **automated Arch Linux installation script**, designed to run from a minimalist network or USB drive using **iPXE**. Upon boot, the user can customize their installation via an interactive wizard.

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
- Wi-Fi network (optional with NetworkManager)
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

## 🧠 Requirements (method 1) - not ready

- **A bootable USB drive** with an environment capable of running iPXE (minimum 5 MB)
- An active internet connection to download Arch Linux and run the script
- iPXE loading Arch Linux via network or minimal ISO

## 🧠 Requirements (method 2)

- **A bootable USB drive** with arch linux iso

---

## 🧩 Installation and Use

1. Insert your USB drive with iPXE configured or boot over the network.
2. From the live environment, download the script:

1. Insert your USB drive with arch linux iso
2. From the live environment, download the script:

```bash
curl -O https://raw.githubusercontent.com/novus0x/arch-installer/refs/heads/main/arch-install.sh
chmod +x arch-install.sh
./arch-install.sh
```
