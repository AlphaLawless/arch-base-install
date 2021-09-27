#!/bin/bash

# Options
# Choose whether or not a particular package. Just toggle between TRUE or FALSE.
# [DISCLAIMER] About Ly!
# It seems that Ly Display Manager doesn't work so well with BSPWM, but there are ways to make it run. If you know something more concrete could be adding.
install_ly=false
aur_paru=false
aur_pikaur=true

sudo timedatectl set-ntp true
sudo hwclock --systohc

sudo pacman -Syy

sudo firewall-cmd --add-port=1025-65535/tcp --permanent
sudo firewall-cmd --add-port=1025-65535/udp --permanent
sudo firewall-cmd --reload

if [[ $aur_paru = true ]]; then
  cd /tmp
  git clone https://aur.archlinux.org/paru-bin.git
  cd paru-bin/;makepkg -si --noconfirm
fi

if [[ $aur_pikaur = true ]]; then
  cd /tmp
  git clone https://aur.archlinux.org/pikaur.git
  cd pikaur/;makepkg -si --noconfirm
  sleep 5
  echo "[*] INSTALLING POLYBAR & DEPENDENCIES..."
  pikaur -S --noconfirm polybar
  pikaur -S --noconfirm nerd-fonts-iosevka
  pikaur -S --noconfirm ttf-icomoon-feather
  sleep 3
  sudo pacman -S python-pywal calc
  cd /tmp
  git clone https://aur.archlinux.org/pfetch.git
  cd pfetch;makepkg -si --noconfirm
fi

# pikaur -S --noconfirm system76-power
# sudo systemctl enable --now system76-power
# sudo system76-power graphics integrated
# pikaur -S --noconfirm gnome-shell-extension-system76-power-git
# pikaur -S --noconfirm auto-cpufreq
# sudo systemctl enable --now auto-cpufreq

echo "[!] MAIN PACKAGES..."
sleep 5

sudo pacman -S --noconfirm xorg bspwm sxhkd dunst rofi firefox kitty neofetch picom unclutter feh cronie nautilus arandr pulseaudio-alsa pavucontrol arc-gtk-theme arc-icon-theme vlc xclip peek kdenlive pacman-contrib

if [[ $install_ly = true ]]; then
  cd /tmp
  git clone https://aur.archlinux.org/ly
  cd ly;makepkg -si
  sudo systemctl enable ly.service
else
  sudo pacman -S lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings
  sleep 5
  sudo systemctl enable lightdm
fi

echo "[*] INSTALLING FONTS..."
sleep 5

sudo pacman -S --noconfirm dina-font tamsyn-font bdf-unifont ttf-bitstream-vera ttf-croscore ttf-dejavu ttf-droid gnu-free-fonts ttf-ibm-plex ttf-liberation ttf-linux-libertine noto-fonts font-bh-ttf ttf-roboto tex-gyre-fonts ttf-ubuntu-font-family ttf-anonymous-pro ttf-cascadia-code ttf-fantasque-sans-mono ttf-fira-mono ttf-hack ttf-fira-code ttf-inconsolata ttf-jetbrains-mono ttf-monofur adobe-source-code-pro-fonts cantarell-fonts inter-font ttf-opensans gentium-plus-font ttf-junicode adobe-source-han-sans-otc-fonts adobe-source-han-serif-otc-fonts noto-fonts-cjk noto-fonts-emoji ttf-font-awesome awesome-terminal-fonts

mkdir -p .config/{bspwm,sxhkd,dunst,picom,kitty}

install -Dm755 /usr/share/doc/bspwm/examples/bspwmrc ~/.config/bspwm/bspwmrc
install -Dm644 /usr/share/doc/sxhkd/examples/sxhkdrc ~/.config/sxhkd/sxhkdrc
install -Dm644 /etc/xdg/picom.conf                   ~/.config/picom/picom.conf

echo "[*] COPYING FILES..."
sleep 3
cp -r /arch-base-install/bspwm/bspwmrc ~/.config/bspwm/
cp -r /arch-base-install/bspwm/sxhkdrc ~/.config/sxhkd/
cp -r /arch-base-install/bspwm/kitty/ ~/.config/kitty/

printf "\e[1;32mDONE! CHANGE NECESSARY FILES BEFORE REBOOT\e[0m"
