# 🧪 Arch Linux Autoinstaller - Novus0x

This project provides an **automated Arch Linux installation script** designed to run using the ***Arch Linux image*** on a USB flash drive. Upon boot, the user can customize their installation using an interactive wizard.

> ⚠️ Ideal for advanced or technical users who want to install Arch Linux quickly, with clean or custom installation options.

[+] Tested on

- BIOS [yes]
- UEFI [yes]

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
- Automatic partitioning with `parted`, formatting with `mkfs.fat` and `mkfs.ext4`

---

## 🧠 Requirements

- **A bootable USB drive** with arch linux iso

---

## 🧩 When to use the `--removable` option in GRUB

The `--removable` option in the `grub-install` command should be used **only in specific scenarios**, mainly to ensure boot compatibility on systems where the UEFI firmware does not register boot entries, or when creating a **portable system**.

**Use `--removable` only if:**

- You are installing Arch Linux on a **bootable USB drive** or external disk.
- Your system’s UEFI **does not retain boot entries** (e.g., minimal firmware or some budget laptops).
- You need the system to **boot on multiple machines** without requiring UEFI configuration.

**Do NOT use `--removable` if:**

- You are installing Arch on a **main internal drive**.
- You want the UEFI firmware to **create a persistent boot entry**.
- Your system supports `efibootmgr` and UEFI boot entries correctly.

## Recommended usage for most systems:

1. Insert your USB drive with the ***Arch linux image***
2. From the live environment:

```bash
curl -O https://raw.githubusercontent.com/novus0x/arch-installer/refs/heads/main/installer.sh
chmod +x installer.sh
./arch-install.sh
```

