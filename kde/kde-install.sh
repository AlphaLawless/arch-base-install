#!/bin/bash

# Options
# Choose whether or not a particular package. Just toggle between TRUE or FALSE.
aur_pikaur=true
aur_paru=false

sudo timedatectl set-ntp true
sudo hwclock --systohc
sudo reflector -c Brazil -a 12 --sort rate --save /etc/pacman.d/mirrorlist

sudo pacman -Syyu

sudo firewall-cmd --add-port=1025-65535/tcp --permanent
sudo firewall-cmd --add-port=1025-65535/udp --permanent
sudo firewall-cmd --reload

if [[ $aur_pikaur = true ]]; then
  cd /tmp
  git clone https://aur.archlinux.org/pikaur.git
  cd pikaur/;makepkg -si --noconfirm
fi

if [[ $aur_paru = true ]]; then
  cd /tmp
  git clone https://aur.archlinux/paru.git
  cd paru/;makepkg -si --noconfirm
fi

# pikaur -S --noconfirm system76-power
# sudo systemctl enable --now system76-power
# sudo system76-power graphics integrated
# pikaur -S --noconfirm auto-cpufreq
# sudo systemctl enable --now auto-cpufreq

echo -e "\e[0;32m[!] MAIN PACKAGES...\e[0m"
sleep 5

sudo pacman -S --noconfirm xorg sddm plasma kde-applications firefox neofetch simplescreenrecorder papirus-icon-theme
peek kdenlive materia-kde flatpak

sudo systemctl enable sddm

printf "\e[1;32mREBOOTING IN 5..4..3..2..1..\e[0m"
sleep 5
sudo reboot
