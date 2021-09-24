#!/bin/bash

body() {
	cat <<- EOF
		[*] What's the language you want to start?

		[*] Choose one -
		[1] pt-BR.
		[2] en-US
    .
	EOF

  read -p "[?] Select Option, typing 1 or 2: "

  if [[ $REPLY == "1" ]]; then
    ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
    hwclock --systohc
    sed -i '393s/.//' /etc/locale.gen # uncomment in line 393 pt_BR.UTF-8 UTF-8
    locale-gen
    echo "LANG=pt_BR.UTF-8" >> /etc/locale.conf
    echo "KEYMAP=br-abnt2" >> /etc/vconsole.conf
    echo "\nQual o hostname da máquina? "
    read hostname
    echo ${hostname} >> /etc/hostname
    echo "127.0.0.1 localhost.localdomain localhost" >> /etc/hosts
    echo "::1       localhost.localdomain localhost" >> /etc/hosts
    echo "127.0.1.1 ${hostname}.localdomain ${hostname}" >> /etc/hosts
    echo "\nDigite uma senha para a root: "
    read password
    echo root:${password} | chpasswd
    grub_install="\nColoque aqui o nome da partição do disco: "
    user_add="\nEscolha o nome de usuário: "
    password_to_user="\nDigite uma senha para o seu novo usuário: "
  elif [[ $REPLY == "2" ]]; then
    ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime # Set your Region and City here
    sed -i '177s/.//' /etc/locale.gen # uncomment in line 177 for en_US.UTF-8 UTF-8
    echo "LANG=en_US.UTF-8" >> /etc/locale.conf
    echo "KEYMAP=de-latin1" >> /etc/vconsole.conf
    echo "\nWhat's  the hostname of the machine? "
    read hostname
    echo ${hostname} >> /etc/hostname
    echo "127.0.0.1 localhost" >> /etc/hosts
    echo "::1       localhost" >> /etc/hosts
    echo "127.0.1.1 ${hostname}.localdomain ${hostname}" >> /etc/hosts
    echo "\nEnter with the password of the root: "
    read password
    echo root:${password} | chpasswd
    grub_install="\nEnter the name of the disk partition here: "
    user_add="\nChoose username: "
    password_to_user="\nEnter the password for your new user: "
  else
    echo "\n[!] Invalid option! "
    exit 1
  fi
}

body

# In this part you can remove packages that you are not going to use.
# You can remove the tlp package if you are installing on a desktop or vm.
# Remove the --noconfirm to have the right to choose which package will pass.

pacman -S --noconfirm grub base-devel os-prober networkmanager network-manager-applet dialog wpa_supplicant xdg-user-dirs xdg-utils wireless_tools dosfstools mtools linux-headers avahi openssh openbsd-netcat ipset firewalld nss-mdns dnsutils vde2 nfs-utils bash-completion reflector sof-firmware dnsmasq pulseaudio alsa-utils virt-manager qemu qemu-arch-extra edk2-ovmf acpi acpi_call acpid cups ntfs-3g terminus-font tlp

# Soft package

# pacman -S --noconfirm grub base-devel os-prober networkmanager network-manager-applet dialog wpa_supplicant wireless_tools openssh reflector tlp

# pacman -S --noconfirm nvidia nivida-utils nvidia-settings
# pacman -S --noconfirm xf86-video-intel
# pacman -S --noconfirm xf86-video-amdgpu

echo $grub_install
read partition_name
grub-install --target=i386-pc ${partition_name}
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager
systemctl enable sshd
systemctl enable reflector.timer
systemctl enable cups.service
systemctl enable avahi-daemon
systemctl enable firewalld
systemctl enable libvirtd
systemctl enable acpid
systemctl enable fstrim.timer
systemctl enable tlp # you can comment this command out if you didn't install tlp, sse above

echo $user_add
read username
echo $password_to_user
read passworduser
useradd -m ${username}
echo ${username}:${passworduser} | chpasswd
usermod -aG libvirt ${username}

echo "${username} ALL=(ALL) ALL" >> /etc/sudoers.d/${username}

printf "\e[1;132mDone! Type exit, umount -a and reboot or umount -R /mnt and shutdown -h now.\e[0m"
