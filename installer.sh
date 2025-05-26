#!/bin/bash

set -e

echo "┌──────────────────────┐"
echo "│ Arch Linux Installer │"
echo "│           by Novus0x │"
echo "└──────────────────────┘"

# Check internet connection
if ping -q -c 1 -W 1 archlinux.org >/dev/null; then
	echo "[+] Internet connection detected"
else
	echo "[-] No internet connection detected"
	exit 1
fi

# Check boot mode (UEFI or BIOS)
if [ -d /sys/firmware/efi ]; then
	echo "[+] System booted in UEFI mode"
	BOOT_MODE="UEFI"
else
	echo "[+] System booted in BIOS (Legacy)."
	BOOT_MODE="BIOS"
fi

# User settings
echo
read -p "[?] Hostname: " HOSTNAME
read -p "[?] USERNAME: " USERNAME

while true; do
	echo "[?] Enter the user password: "
	read -s USERPASS1
	echo "[?] Confirm user password: "
	read -s USERPASS2
	[ "$USERPASS1" = "$USERPASS2" ] && USERPASS="$USERPASS1" && break
	echo "[-] The passwords don't match. Please try again."
done
echo

while true; do
	echo "[?] Enter the root password: "
	read -s ROOTPASS1
	echo "[?] Confirm root password: "
	read -s ROOTPASS2
	[ "$ROOTPASS1" = "$ROOTPASS2" ] && ROOTPASS="$ROOTPASS1" && break
	echo "[-] The passwords don't match. Please try again."
done
echo

echo "[+] Hi $USERNAME please define your partitions:"
echo

# Check storage
total_size=$(lsblk -b /dev/sda -o SIZE -n | head -n 1 )
sizeMB=$((total_size / 1000000))
sizeGB=$((total_size / 1000000000))

echo "[!] You have $sizeGB GB | $sizeMB MB | $total_size bytes (Check that it is correct with what appears below)"
echo
lsblk
echo
DISK="/dev/sda"
echo "[!] Type the size in MB"
read -p "[?] BOOT partition: " BOOT_SIZE
read -p "[?] SWAP partition: " SWAP_SIZE
read -p "[?] ROOT partiton: " ROOT_SIZE
HOME_SIZE=$((sizeMB - (BOOT_SIZE + SWAP_SIZE + ROOT_SIZE)))

if (( (BOOT_SIZE + SWAP_SIZE + ROOT_SIZE + HOME_SIZE) > total_size )); then
    echo "[-] An error ocurre!"
	exit 1
fi

echo
echo "[+] Starting partitioning"

if [[ "$BOOT_MODE" == "UEFI" ]]; then
    PROP="gpt"
else
    PROP="msdos"
fi

parted -s $DISK mklabel $PROP
parted -s $DISK mkpart primary ext4 1MB $BOOT_SIZE
parted -s $DISK mkpart primary linux-swap $BOOT_SIZE $((BOOT_SIZE + SWAP_SIZE))
parted -s $DISK mkpart primary ext4 $((BOOT_SIZE + SWAP_SIZE)) $((BOOT_SIZE + SWAP_SIZE + ROOT_SIZE))
parted -s $DISK mkpart primary ext4 $((BOOT_SIZE + SWAP_SIZE + ROOT_SIZE)) 100%

if [[ "$BOOT_MODE" == "UEFI" ]]; then
	mkfs.vfat -F32 "${DISK}1"
else
	mkfs.ext2 "${DISK}1"
fi

mkswap "${DISK}2"
mkfs.ext4 "${DISK}3"
mkfs.ext4 "${DISK}4"


