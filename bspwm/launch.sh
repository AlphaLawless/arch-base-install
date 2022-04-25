#!/usr/bin/env bash

# Prod

install_lightdm=true

# Dir variables
_site="https://github.com/alphalawless"
repo="arch-base-install/tree/main/wallpapers"

sudo timedatectl set-ntp true
sudo hwclock --systohc
# sudo reflector -c Brazil -a 12 --sort rate --save /etc/pacman.d/mirrorlist

echo -e "\e[0;32mUpdating System\e[0m"
sudo pacman -Syu

clear

if [[ `whereis firewall-cmd` ]]; then
    echo -e "\e[0;32mFirewall - Add ports tcp and upd\e[0m"
    sudo firewall-cmd --add-port=1025-65535/tcp --permanent
    sudo firewall-cmd --add-port=1025-65535/udp --permanent
    sudo firewall-cmd --reload
fi

install_paru() {
    echo -e "\e[0;32mDo you want install AUR Helper Paru? [Y/n]\e[0m"
    read res
    if [[ ${res,,[A-Z]} == "y" ]]; then
        cd /tmp
        git clone https://aur.archlinux.org/paru-bin.git
        cd paru-bin/;makepkg -si --noconfirm

        echo -e "\e[0;32m[*] Install Polybar!\e[0m"
        paru -S --noconfirm polybar ttf-iosevka ttf-icomoon-feather
        echo -e "\e[0;32m[*] Install ksuperkey!\e[0m"
        paru -S --noconfirm ksuperkey
    else
        return 0
    fi
}
install_paru

echo -e "\e[1;32m[!] MAIN PACKAGES...\e[0m"

sudo pacman -S --noconfirm xorg bspwm sxhkd dunst alacritty rofi dmenu xfce4-power-manager gpick firefox min neofetch maim picom unclutter feh cronie thunar arandr pulseaudio-alsa pavucontrol arc-gtk-theme arc-icon-theme vlc xclip pacman-contrib xsettingsd

install_synaptic() {
    echo -e "\e[0;32mYou are on a laptop to install input synaptics? [Y/n]\e[0m"
    read response
    if [[ ${response,,[A-Z]} == "y" ]]; then
        sudo pacman -S --noconfirm xf86-input-synaptics
        sudo mv "$DIR"/70-synaptics.conf /etc/X11/xorg.conf.d/
    else
        return 0
    fi
}
install_synaptic

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

if [[ $install_lightdm = true ]]; then
    sudo pacman -S --noconfirm lightdm wget
    sudo systemctl enable lightdm

    lightdm_install() {
    echo -e "\e[0;32mDo you want to install in lightdm:\e[0m\n"
    echo -e "\e[0;32m [1] webkit2 theme\e[0m\n"
    echo -e "\e[0;32m [2] gtk theme\e[0m\n"

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
        sleep 1 ; clear
        echo -e "\e[1;31m Invalid Option: \e[0m \n"
        lightdm_install
    fi
    }
    lightdm_install
fi

echo -e "\e[1;32m[*] INSTALLING FONTS...\e[0m"

sudo pacman -S --noconfirm dina-font tamsyn-font ttf-bitstream-vera ttf-croscore ttf-dejavu ttf-droid gnu-free-fonts ttf-ibm-plex ttf-liberation ttf-linux-libertine noto-fonts ttf-roboto tex-gyre-fonts ttf-ubuntu-font-family ttf-anonymous-pro ttf-cascadia-code ttf-fantasque-sans-mono ttf-fira-mono ttf-hack ttf-fira-code ttf-inconsolata ttf-jetbrains-mono ttf-monofur adobe-source-code-pro-fonts cantarell-fonts inter-font ttf-opensans gentium-plus-font ttf-junicode adobe-source-han-sans-otc-fonts adobe-source-han-serif-otc-fonts noto-fonts-cjk noto-fonts-emoji ttf-font-awesome awesome-terminal-fonts

install_bspwm() {
    local _CONFIGDIR="$HOME"/.config
    local _BSPWMDIR=${_CONFIGDIR}/bspwm
    local _SXHKDDIR=${_CONFIGDIR}/sxhkd

    mkdir -p "$_BSPWMDIR" && mkdir -p "$_SXHKDDIR"

    install -Dm 755 `pwd`/.fehbg       "$HOME"
    install -Dm 644 `pwd`/.Xresources  "$HOME"
    install -Dm 644 `pwd`/.xsettingsd  "$HOME"

    cp -r `pwd`/.Xresources.d          "$HOME"

    cp -r `pwd`/networkmanager-dmenu   "$HOME"

    cp -r `pwd`/alacritty              "$_BSPWMDIR"
    cp -r `pwd`/polybar                "$_BSPWMDIR"
    cp -r `pwd`/rofi                   "$_BSPWMDIR"
    cp -r `pwd`/themes                 "$_BSPWMDIR"
    cp -r `pwd`/bin                    "$_BSPWMDIR"
    cp -r `pwd`/dunstrc                "$_BSPWMDIR"
    cp -r `pwd`/picom.conf             "$_BSPWMDIR"

    chmod +x "$_BSPWMDIR"/bin/*
    chmod +x "$_BSPWMDIR"/rofi/bin/*
    chmod +x "$_BSPWMDIR"/themes/set-theme

    install -Dm 755 `pwd`/bspwmrc      "$_BSPWMDIR"/bspwmrc
    install -Dm 644 `pwd`/dunstrc      "$_BSPWMDIR"/dunstrc
    install -Dm 644 `pwd`/picom.conf   "$_BSPWMDIR"/picom.conf

    install -Dm 644 `pwd`/sxhkdrc      "$_SXHKDDIR"
}
install_bspwm

install_dependences() {
    echo -e "\e[0;32mInstall wallpapers\e[0m"
    git clone https://github.com/AA-Linux/aa-wallpapers /tmp/wallpapers
    cd /tmp/wallpapers ; bash install.sh

    echo -e "\e[0;32mInstall Thunar Config\e[0m"
    git clone https://github.com/AA-Linux/aa-thunar /tmp/thunar
    cd /tmp/thunar ; bash install.sh

    echo -e "\e[0;32mInstall scripts\e[0m"
    git clone https://github.com/AlphaLawless/scripts /tmp/scripts
    cd /tmp/scripts ; chmod +x * ; sudo rsync -av --exclude=".*" /tmp/scripts/* /usr/local/bin

    echo -e "\e[0;32mInstall Archcraft workers\e[0m"
    git clone https://github.com/AA-Linux/aa-archcraft /tmp/archcraft
    cd /tmp/archcraft ; bash install.sh

    echo -e "\e[0;32mInstall HTOP\e[0m"
    git clone https://github.com/AA-Linux/aa-htop /tmp/htop
    cd /tmp/htop ; bash install.sh
}
install_dependences

echo -e "\e[1;32m* DONE! CHANGE NECESSARY FILES BEFORE REBOOT\e[0m\n"
