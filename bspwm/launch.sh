#!/bin/bash

# Options
# Choose whether or not a particular package. Just toggle between TRUE or FALSE.
# ----------------------+
# [DISCLAIMER] About Ly!|
# ----------------------+
# It seems that Ly Display Manager doesn't work so well with BSPWM, but there are ways to make it run. If you know something more concrete could be adding.
install_ly=false
install_lightdm=true
aur_paru=true

# Dir variables
DIR=`pwd`
_site="https://github.com/alphalawless"
repo="arch-base-install/tree/main/wallpapers"

sudo timedatectl set-ntp true
sudo hwclock --systohc
# sudo reflector -c Brazil -a 12 --sort rate --save /etc/pacman.d/mirrorlist

sudo pacman -Syyu

sudo firewall-cmd --add-port=1025-65535/tcp --permanent
sudo firewall-cmd --add-port=1025-65535/udp --permanent
sudo firewall-cmd --reload

if [[ $aur_paru = true ]]; then
  cd /tmp
  git clone https://aur.archlinux.org/paru-bin.git
  cd paru-bin/;makepkg -si --noconfirm
  echo -e "\e[1;32m[*] INSTALLING POLYBAR & DEPENDENCIES...\e[0m"
  pikaur -S --noconfirm polybar
  pikaur -S --noconfirm ttf-iosevka
  pikaur -S --noconfirm ttf-icomoon-feather
  sudo pacman -S --noconfirm python-pywal calc
fi

echo -e "\e[1;32m[!] MAIN PACKAGES...\e[0m"

sudo pacman -S --noconfirm xorg bspwm sxhkd dunst rofi dmenu firefox neofetch maim picom unclutter feh cronie thunar arandr pulseaudio-alsa pavucontrol arc-gtk-theme arc-icon-theme vlc xclip pacman-contrib xsettingsd

# Install any terminal
terminals() {
    echo -e "\e[1;32mWhich terminal emulator do you want install? \e[0m\n"
    echo -e "\e[1;32m  [1] Kitty \e[0m"
    echo -e "\e[1;32m  [2] Alacritty - Recommended \e[0m\n\n"
    echo -e "\e[1;32mchoice one: \e[0m"
    read reply
    if [[ $reply == "1" ]]; then
        echo -e "\e[0;32m* Install Kitty... \e[0m"
        sudo pacman -S --noconfirm kitty
        sed -i "s/term/kitty/" "$DIR"/sxhkdrc
        cp -r "$DIR"/kitty/ ~/.config/
    elif [[ $reply == "2" ]]; then
        echo -e "\e[0;32m Install Alacritty... \e[0m"
        sudo pacman -S --noconfirm alacritty
        sed -i "s/term/alacritty/" "$DIR"/sxhkdrc
        cp -r "$DIR"/alacritty/ ~/.config/
    else
        echo -e "\e[0;31m* Invalid Option! \e[0m\n"
        terminals
    fi
}
terminals

# Install synaptic for touchpad
echo -e "\e[0;32mYou are on a laptop to install input synaptics? [Y/n]\e[0m"
read response

if [[ ${response,,[A-Z]} == "y" ]]; then
    sudo pacman -S --noconfirm xf86-input-synaptics
    sudo mv "$DIR"/70-synaptics.conf /etc/X11/xorg.conf.d/
else
    return 0
fi

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
  cd ly;makepkg -si --noconfirm
  sudo systemctl enable ly.service
fi

if [[ $install_lightdm = true ]]; then
    sudo pacman -S --noconfirm lightdm wget
    sudo systemctl enable lightdm
    lightdm_install() {
    echo -e "\e[0;32mDo you want to install in lightdm:\e[0m\n"
    echo -e "\e[0;32m [1] webkit2 theme\e[0m\n"
    echo -e "\e[0;32m [2] gtk theme\e[0m\n"

    echo -e "\e[0;32m[*] Choose one option: \e[0m"
    read reply
    if [[ $reply == "1" ]]; then
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
    elif [[ $reply == "2" ]]; then
        sudo pacman -S --noconfirm lightdm-gtk-greeter
        sudo sed -i 's/^#greeter-session.*/greeter-session=lightdm-gtk-greeter/' /etc/lightdm/lightdm.conf
        sudo sed -i '/^#greeter-hide-users=/s/#//' /etc/lightdm/lightdm.conf
        sudo wget $_site/$repo/archlinux.jpg -o /usr/share/pixmaps/
        sudo sed -i "s/^#background=/background=\/usr\/share\/pixmaps\/archlinux.jpg" >> /etc/lightdm/lightdm-gtk-greeter.conf
    else
        sleep 1 ; clear
        echo -e "\e[1;31m Invalid Option: \e[0m \n"
        lightdm_install
    fi
    }
    lightdm_install
fi

echo -e "\e[1;32m[*] INSTALLING FONTS...\e[0m"

sudo pacman -S --noconfirm dina-font tamsyn-font ttf-bitstream-vera ttf-croscore ttf-dejavu ttf-droid gnu-free-fonts ttf-ibm-plex ttf-liberation ttf-linux-libertine noto-fonts ttf-roboto tex-gyre-fonts ttf-ubuntu-font-family ttf-anonymous-pro ttf-cascadia-code ttf-fantasque-sans-mono ttf-fira-mono ttf-hack ttf-fira-code ttf-inconsolata ttf-jetbrains-mono ttf-monofur adobe-source-code-pro-fonts cantarell-fonts inter-font ttf-opensans gentium-plus-font ttf-junicode adobe-source-han-sans-otc-fonts adobe-source-han-serif-otc-fonts noto-fonts-cjk noto-fonts-emoji ttf-font-awesome awesome-terminal-fonts

mkdir -p ~/.config/{bspwm,sxhkd,dunst,picom}

echo -e "\e[1;32m[*] INSTALL AND MOVING FILES...\e[0m"
install -Dm 755 "$DIR"/bspwmrc ~/.config/bspwm/bspwmrc
install -Dm 644 "$DIR"/sxhkdrc ~/.config/sxhkd/sxhkdrc
cp -r "$DIR"/dunst/*           ~/.config/dunst

sudo cp -r /arch-base-install/wallpapers/ "$HOME"/wallpapers

echo -e "\e[1;32m* DONE! CHANGE NECESSARY FILES BEFORE REBOOT\e[0m\n"
