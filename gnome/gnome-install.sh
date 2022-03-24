#!/bin/bash

# Options
# Choose whether or not a particular package. Just toggle between TRUE or FALSE.
install_librewolf=false

sudo timedatectl set-ntp true
sudo hwclock --systohc

sudo pacman -Syyu

sudo firewall-cmd --add-port=1025-65535/tcp --permanent
sudo firewall-cmd --add-port=1025-65535/udp --permanent
sudo firewall-cmd --reload

echo -e "\e[0;32m[!] MAIN PACKAGES...\e[0m"
sleep 5

sudo pacman -S --noconfirm xorg gdm gnome gnome-extra firefox gnome-tweaks neofetch peek vlc arc-gtk-theme
arc-icon-theme kdenlive flatpak

echo -e "\e[0;32m[*] INSTALLING FONTS...\e[0m"
sleep 5

sudo pacman -S --noconfirm dina-font tamsyn-font bdf-unifont ttf-bitstream-vera ttf-croscore ttf-dejavu ttf-droid gnu-free-fonts ttf-ibm-plex ttf-liberation ttf-linux-libertine noto-fonts font-bh-ttf ttf-roboto tex-gyre-fonts ttf-ubuntu-font-family ttf-anonymous-pro ttf-cascadia-code ttf-fantasque-sans-mono ttf-fira-mono ttf-hack ttf-fira-code ttf-inconsolata ttf-jetbrains-mono ttf-monofur adobe-source-code-pro-fonts cantarell-fonts inter-font ttf-opensans gentium-plus-font ttf-junicode adobe-source-han-sans-otc-fonts adobe-source-han-serif-otc-fonts noto-fonts-cjk noto-fonts-emoji ttf-font-awesome awesome-terminal-fonts

if [[ $install_librewolf = true ]]; then
  cd /tmp
  git clone https://aur.archlinux.org/librewolf-bin.git librewolf
  cd librewolf;makepkg -si --noconfirm
fi

sudo systemctl enable gdm

printf "\e[1;32mREBOTING IN 5...4...3...2...1\e[0m"
sleep 5
reboot
