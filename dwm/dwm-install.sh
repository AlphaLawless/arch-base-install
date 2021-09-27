#!/bin/bash

# Env Variables
country=Brazil
keyboardmap=br
output=Virtual-1 # eDP-1 | HDMI-1 | LVDS-1
resolution=1920x1080 # Set your resolution

# Options
# Choose whether or not a particular package. Just toggle between TRUE or FALSE.
aur_paru=true
install_ly=true
gen_xprofile=true

sudo timedatectl set-ntp true
sudo hwclock --systohc
sudo reflector -c $country -a 12 --sort rate --save /etc/pacman.d/mirrorlist

sudo pacman -Syy

sudo firewall-cmd --add-port=1025-65535/tcp --permanent
sudo firewall-cmd --add-port=1025-65535/udp --permanent
sudo firewall-cmd --reload

if [[ $aur_paru = true ]]; then
  cd /tmp
  git clone https://aur.archlinux.org/paru.git
  cd paru/;makepkg -si --noconfirm;cd
fi

echo "[!] MAIN PACKAGES..."
sleep 5

sudo pacman -S xorg firefox polkit-gnome neofetch nitrogen lxappearance thunar kdenlive

echo "[*] INSTALLING FONTS..."
sleep 5

sudo pacman -S --noconfirm dina-font tamsyn-font bdf-unifont ttf-bitstream-vera ttf-croscore ttf-dejavu ttf-droid gnu-free-fonts ttf-ibm-plex ttf-liberation ttf-linux-libertine noto-fonts font-bh-ttf ttf-roboto tex-gyre-fonts ttf-ubuntu-font-family ttf-anonymous-pro ttf-cascadia-code ttf-fantasque-sans-mono ttf-fira-mono ttf-hack ttf-fira-code ttf-inconsolata ttf-jetbrains-mono ttf-monofur adobe-source-code-pro-fonts cantarell-fonts inter-font ttf-opensans gentium-plus-font ttf-junicode adobe-source-han-sans-otc-fonts adobe-source-han-serif-otc-fonts noto-fonts-cjk noto-fonts-emoji ttf-font-awesome awesome-terminal-fonts

# Pull Git repositories and install
repos=( "dmenu" "dwm" "dwmstatus" "st" "slock" )
for repo in $(repos[@])
do
    git clone git://git.suckless.org/$repos
    cd $repo;make;sudo make install; cd ..
done

# XSessions and dwm.desktop
if [[ ! -d /usr/share/xsessions ]]; then
    sudo mkdir /usr/share/xsessions
fi

cat > ./temp << "EOF"
[Desktop Entry]
Encoding=UTF-8
Name=Dwm
Comment=Dynamic window manager
Exec=dwm
Icon=dwm
Type=XSession
EOF
sudo cp ./temp /usr/share/xsessions/dwm.desktop;rm ./temp

# Install ly
if [[ $install_ly = true ]]; then
  cd /tmp
  git clone https://aur.archlinux.org/ly
  cd ly;makepkg -si
  sudo systemctl enable ly.service
fi

# .xprofile
if [[ $gen_xprofile = true ]]; then
cat > ~/.xprofile << EOF
setxkbmap $keyboardmap
nitrogen --restore
xrandr --output $output --mode $resolution
EOF
fi

printf "\e[1;32mDONE! YOU CAN NOW REBOOT. BUT CHANGE NECESSARY FILES BEFORE REBOOT.\e[0m\n]"
