#!/bin/bash

set -e

echo "╔══════════════════════════════╗"
echo "║     Arch Linux Installer     ║"
echo "║                              ║"
echo "║                  by novus0x  ║"
echo "╚══════════════════════════════╝"
echo

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

# Initial questions
read -p "[?] Hostname: " HOSTNAME
read -p "[?] Username: " USERNAME

# Password --> user
while true; do
	echo "[?] Enter the user password: "
	read -s USERPASS1
	echo "[?] Confirm user password: "
	read -s USERPASS2
	[ "$USERPASS1" = "$USERPASS2" ] && USERPASS="$USERPASS1" && break
	echo "[-] The passwords don't match. Please try again."
done
echo

# Password --> root
while true; do
	echo "[?] Enter the root password: "
	read -s ROOTPASS1
	echo "[?] Confirm root password: "
	read -s ROOTPASS2
	[ "$ROOTPASS1" = "$ROOTPASS2" ] && ROOTPASS="$ROOTPASS1" && break
	echo "[-] The passwords don't match. Please try again."
done
echo

read -p "[?] Keyboard type (e.g. es, us, latam): " KEYMAP
loadkeys "$KEYMAP"

read -p "[?] Are you using a laptop? (y/n): " SET_WIFI

# Instalation type
echo "[?] Installation type:"
echo "  1) Traditional"
echo "  2) Customized by Novus0x"
read -p "Select [1/2]: " INSTALL_TYPE

# Automatically detect disk
DISK=$(lsblk -dno NAME,TYPE | grep disk | awk '{print $1}' | head -n 1)
DISK="/dev/$DISK"

echo
echo "[+] Disk: $DISK"
lsblk "$DISK"
echo

# Show disk space
DISK_SIZE=$(blockdev --getsize64 "$DISK")
DISK_SIZE_GB=$((DISK_SIZE / 1024 / 1024 / 1024))
echo "[+] Total disk space: $DISK_SIZE_GB GB"

# Assign space
read -p "[?] Boot partition size (in MB, default 512): " BOOT_SIZE
BOOT_SIZE=${BOOT_SIZE:-512}

read -p "[?] SWAP partition size (in MB, default 512): " SWAP_SIZE
SWAP_SIZE=${SWAP_SIZE:-512}

read -p "[?] ROOT partition size (in GB): " ROOT_SIZE
ROOT_SIZE=${ROOT_SIZE:-20}

echo "[+] It will be assigned: "
echo "- EFI/BOOT: $BOOT_SIZE MB"
echo "- SWAP: $SWAP_SIZE MB"
echo "- ROOT: $ROOT_SIZE GB"
echo "- HOME: Remaining available disk space"
read -p "[?] Confirm? (y/n): " confirm
[[ "$confirm" != "y" ]] && exit 1

echo "[!] Deleting partitions in $DISK..."

PART_TABLE=$(parted -s "$DISK" print | grep 'Partition Table' | awk '{print $3}')
echo "[+] Partition table: $PART_TABLE"
sgdisk -z "$DISK"
INDEX=1
PREFIX="${DISK}"

# Create new partitions
if [ "$BOOT_MODE" = "BIOS" ] && [ "$PART_TABLE" = "gpt" ]; then
	echo "[+] Creting BIOS Boot partition (ef02)"
	sgdisk -n ${INDEX}:0:+${BOOT_SIZE}M -t ${INDEX}:ef02 "$DISK"
	BOOT_PART=$INDEX
	INDEX=$((INDEX + 1))
elif [ "$BOOT_MODE" = "BIOS" ]; then
	echo "[+] Creating /boot partition (8300)"
	sgdisk -n ${INDEX}:0:+${BOOT_SIZE} -t ${INDEX}:8300 "$DISK"
	BOOT_PART=$INDEX
	INDEX=$((INDEX + 1))
elif [ "$BOOT_MODE" = "UEFI" ]; then
	echo "[+] Creating EFI partition (ef00)"
	sgdisk -n ${INDEX}:0:+${BOOT_SIZE}M -t ${INDEX}:ef00 "$DISK"
	BOOT_PART=$INDEX
	INDEX=$((INDEX + 1))
fi

# Swap
echo "[+] Creating swap partition (8200)"
sgdisk -n ${INDEX}:0:+${SWAP_SIZE}M -t ${INDEX}:8200 "$DISK"
SWAP_PART=$INDEX
INDEX=$((INDEX + 1))

# Root
echo "[+] Creating root partition (8300)"
sgdisk -n ${INDEX}:0:+${ROOT_SIZE}G -t ${INDEX}:8300 "$DISK"
ROOT_PART=$INDEX
INDEX=$((INDEX + 1))

# Home
echo "[+] Creating home partition (8302)"
sgdisk -n ${INDEX}:0:0 -t ${INDEX}:8302 "$DISK"
HOME_PART=$INDEX

BOOT="${PREFIX}${BOOT_PART}"
SWAP="${PREFIX}${SWAP_PART}"
ROOT="${PREFIX}${ROOT_PART}"
HOME="${PREFIX}${HOME_PART}"

# Formatting partitions
echo "[+] Formatting partitions..."

if [ "$BOOT_MODE" = "UEFI" ]; then
	mkfs.vfat -F32 "$BOOT"
else
	mkfs.ext2 "$BOOT"
fi

mkswap "$SWAP"
swapon "$SWAP"
mkfs.ext4 "$ROOT"
mkfs.ext4 "$HOME"

# Mount
mount "$ROOT" /mnt
mkdir -p /mnt/home

if [ "$BOOT_MODE" = "UEFI" ]; then
	mkdir -p /mnt/boot/efi
	mount "$BOOT" /mnt/boot/efi
else
	mkdir -p /mnt/boot
	mount "$BOOT" /mnt/boot
fi

mount "$HOME" /mnt/home

# Install system base
if [ "$BOOT_MODE" = "UEFI" ]; then
	pacstrap /mnt base base-devel efibootmgr os-prober ntfs-3g networkmanager grub gvfs gvfs-afc gvfs-mtp xdg-user-dirs linux linux-firmware nano dhcpcd zsh
else
	pacstrap /mnt base base-devel grub os-prober ntfs-3g networkmanager gvfs gvfs-afc gvfs-mtp xdg-user-dirs linux linux-firmware nano dhcpcd zsh
fi

if [ "$SET_WIFI" ]; then
	pacstrap /mnt netctl wpa_supplicant dialog xf86-input-synaptics
fi

# Fstab
genfstab -pU /mnt >> /mnt/etc/fstab

echo "[!] Please type: 'nano /etc/locale.gen' then select your prefer lenguaje, finally type 'exit'"
echo 
arch-chroot /mnt

arch-chroot /mnt /bin/bash -e <<EOF
hwclock -w
echo "$KEYMAP" > /etc/vconsole.conf
echo "$HOSTNAME" > /etc/hostname

echo "[+] Generating locales..."
locale-gen

systemctl enable NetworkManager

useradd -m -g users -G audio,lp,optical,storage,video,wheel,games,power,scanner -s /bin/zsh "$USERNAME"
echo "$USERNAME:$USERPASS" | chpasswd
echo "root:$ROOTPASS" | chpasswd
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

if [ "$BOOT_MODE" = "UEFI" ]; then
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --removable
else
    grub-install "$DISK"
fi

grub-mkconfig -o /boot/grub/grub.cfg
exit
EOF

if [ "$BOOT_MODE" = "UEFI" ]; then
	umount /mnt/boot/efi
else
	umount /mnt/boot
fi

umount /mnt/home
umount /mnt

echo "[!] Please reboot the system"
