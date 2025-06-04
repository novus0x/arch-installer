#!/usr/bin/env python3
import sys, subprocess

from termcolor import colored, cprint

# Show banner
banner = subprocess.run(["toilet", "-f", "smblock", "Dotfiles Installer\n\t\tby Novus0x\n"], capture_output=True, text=True)

# Config
packages = ["xorg", "xorg-server", "xorg-xinit", "xorg-xrandr", "xorg-xsetroot", "mesa", "lightdm", "lightdm-gtk-greeter", "neovim", "i3", "i3-gaps", "i3lock", "polybar", "picom", "rofi", "pulseaudio", "playerctl", "feh", "net-tools", "upower", "bat", "lsd", "lua-language-server", "go", "ttf-fira-code", "ttf-jetbrains-mono-nerd", "ttf-dejavu", "ttf-font-awesome"]

# Main function
def main():
    subprocess.run(["clear"])
    cprint(banner.stdout, "green")

    cprint("[+] Updating system", "green")
    subprocess.run(["sudo", "pacman", "-Syu", "--noconfirm"])
    cprint("[+] Installing dependencies", "green")
    subprocess.run(["sudo", "pacman", "-S", "--needed", "--noconfirm"] + packages)
    cprint("[+] Installing yay", "green")
    subprocess.run(["git", "clone", "https://aur.archlinux.org/yay.git"])
    subprocess.run("cd yay && makepkg -si --noconfirm", shell=True)
    cprint("[+] Enabling upower and lightdm", "green")
    subprocess.run(["sudo", "systemctl", "enable", "upower.service", "lightdm.service"])
    cprint("[+] Adding lightdm configurations", "green")
    subprocess.run(["sudo", "cp", "-r", "./config/lightdm/lightdm.conf", "/etc/lightdm/lightdm.conf"])
    subprocess.run(["sudo", "cp", "-r", "./config/lightdm/lightdm-gtk-greeter.conf", "/etc/lightdm/lightdm-gtk-greeter.conf"])

if __name__ == "__main__":
    main()
