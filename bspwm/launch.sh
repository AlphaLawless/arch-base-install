#!/bin/bash

# Options
# Choose whether or not a particular package. Just toggle between TRUE or FALSE.
# ----------------------+
# [DISCLAIMER] About Ly!|
# ----------------------+
# It seems that Ly Display Manager doesn't work so well with BSPWM, but there are ways to make it run. If you know something more concrete could be adding.
install_ly=false
install_lightdm=true
aur_paru=false
aur_pikaur=true

DIR=`pwd`
_site="https://github.com/alphalawless"
repo="arch-base-install/tree/main/wallpapers"

sudo timedatectl set-ntp true
sudo hwclock --systohc
sudo reflector -c Brazil -a 12 --sort rate --save /etc/pacman.d/mirrorlist

sudo pacman -Syyu

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
  echo -e "\e[1;31m[*] INSTALLING POLYBAR & DEPENDENCIES...\e[0m"
  pikaur -S --noconfirm polybar
  pikaur -S --noconfirm ttf-iosevka
  pikaur -S --noconfirm ttf-icomoon-feather
  sudo pacman -S --noconfirm python-pywal calc
fi

# pikaur -S --noconfirm system76-power
# sudo systemctl enable --now system76-power
# sudo system76-power graphics integrated
# pikaur -S --noconfirm gnome-shell-extension-system76-power-git
# pikaur -S --noconfirm auto-cpufreq
# sudo systemctl enable --now auto-cpufreq

echo -e "\e[1;31m[!] MAIN PACKAGES...\e[0m"

sudo pacman -S --noconfirm xorg bspwm sxhkd dunst rofi firefox kitty neofetch maim picom unclutter feh cronie nautilus arandr pulseaudio-alsa pavucontrol arc-gtk-theme arc-icon-theme vlc xclip peek kdenlive pacman-contrib

# Install synaptic for touchpad
echo -e "\e[0;32mYou are on a laptop to install input synaptics? [Y/n]\e[0m"
read response

if [[ ${response,,[A-Z]} == "y" ]]; then
    sudo pacman -S --noconfirm xf86-input-synaptics
    sudo mv $DIR/70-synaptics.conf /etc/X11/xorg.conf.d/
else
    return 0
fi

# Install pfetch
cd /tmp
git clone https://aur.archlinux.org/pfetch.git
cd pfetch;makepkg -si --noconfirm

# Generate Keyboard.conf
echo -e "\e[0;32mEnter with the layout of keyboard, e.g. us | br | ch ... \e[0m"
read layout

cat > ./temp << EOF
Section "InputClass"
        Identifier "system-keyboard"
        MatchIsKeyboard "on"
        Option "XkbLayout" "$layout"
        Option "XkbModel" "pc105"
        Option "XkbOptions" "grp:win_space_toggle"
EndSection
EOF
sudo cp ./temp /etc/X11/xorg.conf.d/00-keyboard.conf; sudo rm ./temp

if [[ $install_ly = true ]]; then
  cd /tmp
  git clone https://aur.archlinux.org/ly
  cd ly;makepkg -si
  sudo systemctl enable ly.service
fi

if [[ $install_lightdm = true ]]; then
    sudo pacman -S --noconfirm lightdm wget
    sudo systemctl enable lightdm
    lightdm_install() {
        cat <<EOF

        Do you want to install in lightdm:

        [1] webkit2
        [2] gtk

EOF

    read -p "[*] Choose one option: "
    if [[ $REPLY == "1" ]]; then
        sudo pacman -S --noconfirm lightdm-webkit2-greeter
        sudo sed -i 's/^#greeter-session.*/greeter-session=lightdm-webkit2-greeter/' /etc/lightdm/lightdm.conf
        cd /tmp ; mkdir glorious
        sudo wget git.io/webkit2 -O tema.tar.gz
        sudo mv tema.tar.gz glorious/ ; cd glorious/
        tar zxvf tema.tar.gz
        sudo rm tema.tar.gz ; cd ..
        sudo mv glorious/ /usr/share/lightdm-webkit/themes/
        sudo sed -i 's/debug_mode.*/debug_mode          = true/g' /etc/lightdm/lightdm-webkit2-greeter.conf
        sudo sed -i 's/webkit_theme.*/webkit_theme        = glorious/g' /etc/lightdm/lightdm-webkit2-greeter.conf
    elif [[ $REPLY == "2" ]]; then
        sudo pacman -S --noconfirm lightdm-gtk-greeter
        sudo sed -i 's/^#greeter-session.*/greeter-session=lightdm-gtk-greeter/' /etc/lightdm/lightdm.conf
        sudo sed -i '/^#greeter-hide-users=/s/#//' /etc/lightdm/lightdm.conf
        sudo wget $_site/$repo/archlinux.jpg -o /usr/share/pixmaps/
        sudo sed -i "s/^#background=/background=\/usr\/share\/pixmaps\/archlinux.jpg" >> /etc/lightdm/lightdm-gtk-greeter.conf
    else
        sleep 3 ; clear
        echo -e "\e[1;31m Invalid Option: \e[0m \n"
        lightdm_install
    fi
    }
    lightdm_install
fi

echo -e "\e[1;32m[*] INSTALLING FONTS...\e[0m"

sudo pacman -S --noconfirm dina-font tamsyn-font bdf-unifont ttf-bitstream-vera ttf-croscore ttf-dejavu ttf-droid gnu-free-fonts ttf-ibm-plex ttf-liberation ttf-linux-libertine noto-fonts font-bh-ttf ttf-roboto tex-gyre-fonts ttf-ubuntu-font-family ttf-anonymous-pro ttf-cascadia-code ttf-fantasque-sans-mono ttf-fira-mono ttf-hack ttf-fira-code ttf-inconsolata ttf-jetbrains-mono ttf-monofur adobe-source-code-pro-fonts cantarell-fonts inter-font ttf-opensans gentium-plus-font ttf-junicode adobe-source-han-sans-otc-fonts adobe-source-han-serif-otc-fonts noto-fonts-cjk noto-fonts-emoji ttf-font-awesome awesome-terminal-fonts

mkdir -p ~/.config/{bspwm,sxhkd,dunst,picom}

install -Dm755 /usr/share/doc/bspwm/examples/bspwmrc ~/.config/bspwm/bspwmrc
install -Dm644 /usr/share/doc/bspwm/examples/sxhkdrc ~/.config/sxhkd/sxhkdrc

echo -e "\e[1;31m[*] COPYING AND MOVING FILES...\e[0m"
cp -r $DIR/bspwmrc ~/.config/bspwm/
cp -r $DIR/sxhkdrc ~/.config/sxhkd/
cp -r $DIR/dunst/ ~/.config/dunst/
cp -r $DIR/kitty/ ~/.config/
sudo mv /arch-base-install/wallpapers/ ~/wallpapers
sleep 3
printf "\e[1;32m* DONE! CHANGE NECESSARY FILES BEFORE REBOOT\e[0m"
