#!/bin/bash

# Options
#
install_librewolf=true
aur_pikaur=false
aur_paru=true

sudo timedatectl set-ntp true
sudo hwclock --systohc

sudo pacman -Sy

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

echo "\n[!] MAIN PACKAGES"

sudo pacman -S --noconfirm xorg sddm plasma kde-applications brave simplescreenrecorder vlc papirus-icon-theme peek kdenlive materia-kde

if [[ $install_librewolf = true ]]; then
  cd /tmp
  git clone https://aur.archlinux.org/librewolf-bin.git librewolf
  cd librewolf;makepkg -si
fi

sudo systemctl enable sddm

echo -e "\e[1;32mREBOOTING IN 5..4..3..2..1..\e[0m"
sleep 5
reboot
