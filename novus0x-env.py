#!/usr/bin/env python3
import sys, subprocess

from termcolor import colored, cprint

# Show banner
banner = subprocess.run(["toilet", "-f", "smblock", "Dotfiles Installer\n\t\tby Novus0x\n"], capture_output=True, text=True)

# Main function
def main():
    subprocess.run(["clear"])
    cprint(banner.stdout, "green")

    cprint("[+] Updating system", "green")
    subprocess.run(["sudo", "pacman", "-Syu"])
    subprocess.run(["sudo", "pacman", "-S", "xorg", "xorg-server", "xorg-xinit", "xorg-xrandr", "xorg-xsetroot", "mesa", "lightdm", "lightdm-gtk-greeter", "git", "neovim", "alacritty", "i3", "i3-gaps", "i3lock", "polybar", "picom", "rofi", "pulseaudio", "playerctl", "feh", "net-tools", "upower", "bat", "lsd", "lua-lenguage-server", "go", "toilet", "ttf-fira-code", "ttf-jetbrains-mono-nerd", "ttf-dejavu", "ttf-font-awesome"])
    subprocess.run(["git clone https://aur.archlinux.org/yay.git"])
    subprocess.run(["cd", "yay"])
    subprocess.run(["makepkg", "-si"])

    subprocess.run(["sudo", "systemctl", "enable", "upower.service", "lightdm.service"])
    

if __name__ == "__main__":
    main()
