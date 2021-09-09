#!/bin/bash

ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc

locale-gen
echo "LANG=pt_BR.UTF-8" >> /etc/locale.conf
echo "KEYMAP=br-abnt2" >> /etc/vconsole.conf
echo "alphaarch" >> /etc/hostname # You may be replacing "alphaarch" for a name of your choice.
echo "127.0.0.1 localhost.localdomain localhost" >> /etc/hosts
echo "::1       localhost.localdomain localhost" >> /etc/hosts
echo "127.0.1.1 alphaarch.localdomain alphaarch" >> /etc/hosts
echo root:password | chpasswd

# In this part you can remove packages that you are not going to use.
# You can remove the tlp package if you are installing on a desktop or vm.

pacman -S --noconfirm grub os-prober networkmanager network-manager-applet dialog wpa_supplicant wireless_tools dosftools mtools linux-headers openssh reflector sof-firmware dnsmasq cups ntfs-3g bluez bluez-utils tlp

# Soft package

#pacman -S --noconfirm grub os-prober networkmanager network-manager-applet dialog wpa_supplicant wireless_tools openssh reflector tlp

# pacman -S --noconfirm nvidia nivida-utils nvidia-settings
# pacman -S --noconfirm xf86-video-intel
# pacman -S --noconfirm xf86-video-amdgpu

grub-install --target=i386-pc /dev/sdX # replace sd"x" with your disk name, not the partition!
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager
systemctl enable sshd
systemctl enable reflector.timer
systemctl enable cups.service
systemctl enable libvirtd
systemctl enable tlp # you can comment this command out if you didn't install tlp, sse above

# As said above, you can be replacing "alphaarch" for a name of your choose.

useradd -m -g users -G wheel alphaarch

# If you prefer, you can choose this option to generate a new user. Uncomment this ootion and comment the line above.

# useradd -m alphaarch
# echo alphaarch:password | chpasswd
# usermod -aG libvirt alphaarch


echo "alphaarch ALL=(ALL) ALL" >> /etc/sudoers.d/alphaarch

printf "\e[1;132mDone! Type exit, umount -a and reboot.\e[0m"
