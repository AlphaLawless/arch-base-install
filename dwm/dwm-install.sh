#!/bin/bash

# Env Variables
country=Brazil
keyboardmap=br
output=Virtual-1 # eDP-1 | HDMI-1 | LVDS-1
resolution=1920x1080 # Set your resolution

# Options
# Choose whether or not a particular package. Just toggle between TRUE or FALSE.
aur_paru=false
aur_pikaur=true
install_ly=false
install_lightdm=true
gen_xprofile=true

sudo timedatectl set-ntp true
sudo hwclock --systohc
sudo reflector -c $country -a 12 --sort rate --save /etc/pacman.d/mirrorlist

sudo pacman -Syyu

sudo firewall-cmd --add-port=1025-65535/tcp --permanent
sudo firewall-cmd --add-port=1025-65535/udp --permanent
sudo firewall-cmd --reload

# PARU Installation
if [[ $aur_paru = true ]]; then
  cd /tmp
  git clone https://aur.archlinux.org/paru.git
  cd paru/;makepkg -si --noconfirm;cd
fi

# PIKAUR Installation
if [[ $aur_pikaur = true ]]; then
  cd /tmp
  git clone https://aur.archlinux.org/pikaur.git
  cd pikaur/;makepkg -si --noconfirm
fi


echo -e "\e[0;32m[!] MAIN PACKAGES...\e[0m"
sleep 3

sudo pacman -S xorg-server xorg-xinit xorg-xrandr xorg-xsetroot firefox polkit-gnome neofetch nitrogen lxappearance
thunar kdenlive pavucontrol pulseaudio-alsa xclip peek vlc picom

echo -e "\e[0;32m Install Pfetch...[0m"
cd /tmp
git clone https://aur.archlinux.org/pfetch.git
cd pfetch;makepkg -si --noconfirm

echo -e "\e[0;32m[*] INSTALLING FONTS...\e[0m"

sudo pacman -S --noconfirm dina-font tamsyn-font bdf-unifont ttf-bitstream-vera ttf-croscore ttf-dejavu ttf-droid gnu-free-fonts ttf-ibm-plex ttf-liberation ttf-linux-libertine noto-fonts font-bh-ttf ttf-roboto tex-gyre-fonts ttf-ubuntu-font-family ttf-anonymous-pro ttf-cascadia-code ttf-fantasque-sans-mono ttf-fira-mono ttf-hack ttf-fira-code ttf-inconsolata ttf-jetbrains-mono ttf-monofur adobe-source-code-pro-fonts cantarell-fonts inter-font ttf-opensans gentium-plus-font ttf-junicode adobe-source-han-sans-otc-fonts adobe-source-han-serif-otc-fonts noto-fonts-cjk noto-fonts-emoji ttf-font-awesome awesome-terminal-fonts

# Copy xinitrc for $HOME
cp /etc/X11/xinit/xinitrc ~/.xinitrc
sed -e '/tw.*/ s/^#*/#/' -i ~/.xinitrc
sed -e '/xcl.*/ s/^#*/#/' -i ~/.xinitrc
sed -e '/xter.*/ s/^#*/#/' -i ~/.xinitrc
sed -e '/exec.*/ s/^#*/#/' -i ~/.xinitrc

cat >> ~/.xinitrc << "EOF"

# Compositor
picom -f &

# Execute Dwm
exec dwm
EOF

# Pull Git repositories and install
cd /tmp
repos=( "dmenu" "dwm" "dwmstatus" "st" "slock" )
for repo in ${repos[@]}
do
    git clone git://git.suckless.org/$repo
    cd $repo; make; sudo make install;cd ..
done

# Generate Xsession
cat > ./temp << "EOF"
[Desktop Entry]
Encoding=UTF-8
Name=Dwm
Comment=Dynamic window manager
Exec=dwm
Icon=dwm
Type=XSession
EOF
sudo mkdir /usr/share/xsessions/
sudo cp ./temp /usr/share/xsessions/dwm.desktop;sudo rm ./temp

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

# Installation of ly
if [[ $install_ly = true ]]; then
    cd /tmp
    git clone https://aur.archlinux.org/ly
    cd ly;makepkg -si
    sudo systemctl enable ly
fi

# Installation of Lighdm with webkit2 or gtk
if [[ $install_lightdm = true ]]; then
    sudo pacman -S lightdm wget
    sleep 3
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

# Generation .xprofile
if [[ $gen_xprofile = true ]]; then
cat >> ~/.xprofile << EOF
setxkbmap $keyboardmap &
nitrogen --restore
xrandr --output $output --mode $resolution
EOF
fi

printf "\e[1;32mDONE! YOU CAN NOW REBOOT. BUT CHANGE NECESSARY FILES BEFORE REBOOT.\e[0m"
