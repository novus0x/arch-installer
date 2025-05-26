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
read -p "[?] Are you in a laptop? [y/n]: " LAPTOP
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
sizeMB=$((total_size / 1048576))
sizeGB=$((total_size / 1073741824))

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

BOOT_SIZE=$((BOOT_SIZE + 1))

parted -s $DISK mklabel $PROP
parted -s $DISK mkpart primary ext4 1MiB ${BOOT_SIZE}MiB
parted -s $DISK mkpart primary linux-swap ${BOOT_SIZE}MiB $((BOOT_SIZE + SWAP_SIZE))MiB
parted -s $DISK mkpart primary ext4 $((BOOT_SIZE + SWAP_SIZE))MiB $((BOOT_SIZE + SWAP_SIZE + ROOT_SIZE))MiB
parted -s $DISK mkpart primary ext4 $((BOOT_SIZE + SWAP_SIZE + ROOT_SIZE))MiB 100%

if [[ "$BOOT_MODE" == "UEFI" ]]; then
	mkfs.vfat -F32 "${DISK}1"
else
	mkfs.ext2 "${DISK}1"
fi

mkswap "${DISK}2"
swapon "${DISK}2"
mkfs.ext4 "${DISK}3"
mkfs.ext4 "${DISK}4"

# Mounting partitions
echo "[+] Mounting partitions"
mount "${DISK}3" /mnt
mkdir /mnt/home
if [[ "$BOOT_MODE" == "UEFI" ]]; then
	mkdir -p /mnt/boot/efi
	mount "${DISK}1" /mnt/boot/efi
else
	mkdir /mnt/boot
	mount "${DISK}1" /mnt/boot
fi
mount "${DISK}4" /mnt/home

# Installing base system
echo "[+] Installing base system"
if [ "$BOOT_MODE" = "UEFI" ]; then
	pacstrap /mnt base base-devel efibootmgr os-prober ntfs-3g networkmanager grub gvfs gvfs-afc gvfs-mtp xdg-user-dirs linux linux-firmware nano dhcpcd zsh kitty
else
	pacstrap /mnt base base-devel grub os-prober ntfs-3g networkmanager gvfs gvfs-afc gvfs-mtp xdg-user-dirs linux linux-firmware nano dhcpcd zsh kitty
fi

if [ "$LAPTOP" == "y" ]; then
	pacstrap /mnt netctl wpa_supplicant dialog xf86-input-synaptics
fi

genfstab -pU /mnt >> /mnt/etc/fstab

# Selecting lang
echo "[!] Please type: 'nano /etc/locale.gen' then select your preferred language, finally type 'exit'"
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
	grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
else
	grub-install "$DISK"
fi
grub-mkconfig -o /boot/grub/grub.cfg
EOF

if [ "$BOOT_MODE" == "UEFI" ]; then
	umount /mnt/boot/efi
else
	umount /mnt/boot
fi

umount /mnt/home
umount /mnt

if [ "$BOOT_MODE" == "UEFI" ]; then
	efibootmrg
fi

echo "[!] Please reboot the system"

