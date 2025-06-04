#!/usr/bin/env python3
import os, sys, subprocess

from termcolor import colored, cprint

# Show banner
banner = subprocess.run(["toilet", "-f", "smblock", "Dotfiles Installer\n\t\tby Novus0x\n"], capture_output=True, text=True)

# Config
packages = ["xorg", "xorg-server", "xorg-xinit", "xorg-xrandr", "xorg-xsetroot", "mesa", "lightdm", "lightdm-gtk-greeter", "neovim", "i3", "i3-gaps", "i3lock", "polybar", "picom", "rofi", "pulseaudio", "playerctl", "feh", "net-tools", "upower", "bat", "lsd", "lua-language-server", "go", "ttf-fira-code", "ttf-jetbrains-mono-nerd", "ttf-dejavu", "ttf-font-awesome"]
home_dir = os.path.expanduser("~/")
config_dir = os.path.expanduser("~/.config/")

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
    cprint("[+] Adding Novus0x theme in /usr/share/themes", "green")
    subprocess.run(["sudo", "cp", "-r", "./config/Novus0x" ,"/usr/share/themes/"])
    cprint("[+] Adding files to ~/.config", "green")
    subprocess.run(["cp", "-r", "./config/i3", config_dir])
    subprocess.run(["cp", "-r", "./config/nvim", config_dir])
    subprocess.run(["cp", "-r", "./config/picom", config_dir])
    subprocess.run(["cp", "-r", "./config/polybar", config_dir])
    subprocess.run(["cp", "-r", "./config/alacritty", config_dir])
    cprint("[+] Adding background", "green")
    subprocess.run(["sudo", "mkdir", "-p", "/usr/share/backgrounds"])
    subprocess.run(["sudo", "cp", "-r", "./config/login-background.jpg", "/usr/share/backgrounds/login-background.jpg"])
    cprint("[+] Installing OhMyZSH", "green")
    subprocess.run(["curl", "-LO", "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"])
    subprocess.run(["chmod", "+x", "./install.sh"])
    subprocess.run(["./install.sh --unattended"])
    subprocess.run(["rm", "-r", "./install.sh"])
    cprint("[+] Adding sudo, zsh-autosuggestions and zsh-syntax-highlighting plugins", "green")
    subprocess.run(["sudo", "mkdir", "-p", "/usr/share/zsh/plugins/sudo-plugin"])
    subprocess.run(["curl", "-O", "https://raw.githubusercontent.com/triplepointfive/oh-my-zsh/refs/heads/master/plugins/sudo/sudo.plugin.zsh"])
    subprocess.run(["sudo", "mv", "./sudo.plugin.zsh"  "/usr/share/zsh/plugins/sudo-plugin/"])
    subprocess.run(["sudo", "pacman", "-S", "--noconfirm","zsh-syntax-highlighting", "zsh-autosuggestions"])
    cprint("[+] Installing PowerLevel10K", "green")
    subprocess.run(["git", "clone", "--depth=1", "https://github.com/romkatv/powerlevel10k.git", "~/powerlevel10k"])
    cprint("[+] Adding .zshrc file", "green")
    subprocess.run(["cp", "-r", "./config/.zshrc", home_dir])

if __name__ == "__main__":
    main()
