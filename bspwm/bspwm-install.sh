#!/bin/bash

# Options
#
install_ly=true
install_librewolf=true
aur_paru=false
aur_pikaur=false

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
  git clone https://aur.archlinux.org/pikaur.git
  cd pikaur/;makepkg -si --noconfirm
  sleep 5
  pikaur -S --noconfirm polybar
  pikaur -S --noconfirm nerd-fonts-iosevka
  pikaur -S --noconfirm tt-icomoon-feather
fi


# pikaur -S --noconfirm system76-power
# sudo systemctl enable --now system76-power
# sudo system76-power graphics integrated
# pikaur -S --noconfirm gnome-shell-extension-system76-power-git
# pikaur -S --noconfirm auto-cpufreq
# sudo systemctl enable --now auto-cpufreq

echo "[!] MAIN PACKAGES..."
sleep 5

sudo pacman -S --noconfirm xorg bspwm sxhkd dunst rofi dmenu firefox kitty neofetch picom unclutter feh nautilus arandr pulseaudio-alsa pavucontrol arc-gtk-theme arc-icon-theme vlc xclip pacman-contrib

if [[ $install_librewolf = true ]]; then
  cd /tmp
  git clone https://aur.archlinux.org/librewolf-bin.git librewolf
  cd librewolf;makepkg -si --noconfirm
fi

if [[ $install_ly = true ]]; then
  cd /tmp
  git clone https://aur.archlinux.org/ly
  cd ly;makepkg -si
  sudo systemctl enable ly.service
else
  sudo pacman -S lightdm lightdm-gtk-greeter lightdm-gtk-greater-settings
  sleep 5
  sudo systemctl enable lightdm
fi

echo "[*] INSTALLING FONTS..."
sleep 5

sudo pacman -S --noconfirm dina-font tamsyn-font bdf-unifont ttf-bitstream-vera ttf-croscore ttf-dejavu ttf-droid gnu-free-fonts ttf-ibm-plex ttf-liberation ttf-linux-libertine noto-fonts font-bh-ttf ttf-roboto tex-gyre-fonts ttf-ubuntu-font-family ttf-anonymous-pro ttf-cascadia-code ttf-fantasque-sans-mono ttf-fira-mono ttf-hack ttf-fira-code ttf-inconsolata ttf-jetbrains-mono ttf-monofur adobe-source-code-pro-fonts cantarell-fonts inter-font ttf-opensans gentium-plus-font ttf-junicode adobe-source-han-sans-otc-fonts adobe-source-han-serif-otc-fonts noto-fonts-cjk noto-fonts-emoji ttf-font-awesome awesome-terminal-fonts

mkdir -p .config/{bspwm,sxhkd,dunst}

install -Dm755 /usr/share/doc/bspwm/examples/bspwmrc ~/.config/bspwm/bspwmrc
install -Dm644 /usr/share/doc/bspwm/examples/sxhkdrc ~/.config/sxhkd/sxhkdrc

printf "\e[1;32mDONE! CHANGE NECESSARY FILES BEFORE REBOOT\e[0m"
