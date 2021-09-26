#!/bin/bash

packages() {
    clear
    cat <<- EOF
        [*] What's the packages you want to install?

        [*] Choose one -
        [1] Main packages
        [2] Soft Packages
    EOF

  read -p "[?] Select Option, typing 1 or 2: "

  if [[ $REPLY == "1" ]]; then
    pacman -S grub base-devel os-prober networkmanager network-manager-applet dialog wpa_supplicant xdg-user-dirs xdg-utils wireless_tools dosfstools mtools linux-headers avahi openssh openbsd-netcat ipset firewalld nss-mdns dnsutils vde2 nfs-utils bash-completion reflector sof-firmware dnsmasq pulseaudio alsa-utils virt-manager qemu qemu-arch-extra edk2-ovmf acpi acpi_call acpid cups ntfs-3g terminus-font
    sleep 5 ; clear ; lsblk
    echo -e "Enter your partition name for grub installation, use the table above. e.g. /dev/sdx: "
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
  elif [[ $REPLY == "2" ]]; then
    pacman -S grub base-devel os-prober networkmanager network-manager-applet dialog wpa_supplicant wireless_tools dosfstools mtools openssh reflector firewalld cups virt-manager qemu qemu-arch-extra edk2-ovmf pulseaudio alsa-utils
    sleep 5 ; clear ; lsblk
    echo -e "Enter your partition name for grub installation, use the table above. e.g. /dev/sdx: "
    read partition_name
    grub-install --target=i386-pc ${partition_name}
    echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg

    systemctl enable NetworkManager
    systemctl enable sshd
    systemctl enable reflector.timer
    systemctl enable cups.service
    systemctl enable firewalld
    systemctl enable libvirtd
  else
    echo "[!] Invalid option!"
    sleep 2 ; clear ; packages
  fi
}
packages

videoDriverInstall(){
	cat <<- EOF
		[*] Want to install video drivers now?

		[*] Choose one -
		[1] Yes
		[2] No
	EOF

	read -p "[?] Select option: "

	if [[ $REPLY == "1" ]]; then
		cat <<- EOF
			[*] What's your video card?

			[*] Choose one -
			[1] Intel
			[2] Amd
			[3] Nvidia
		EOF

		read -p "[?] Select option: "

		if [[ $REPLY == "1" ]]; then
			pacman -S xf86-video-intel
		elif [[ $REPLY == "2" ]]; then
			pacman -S xf86-video-amdgpu
		elif [[ $REPLY == "3" ]]; then
			pacman -S nvidia nivida-utils nvidia-settings
		else
			echo "[!] Invalid Option: "
			sleep 3 ; clear ; videoDriverInstall
		fi
	elif [[ $REPLY == "2" ]]; then
		return 0
	fi
}
videoDriverInstall

createPassword() {
  echo -e "Create a password for username: \n"
  unset password
  while IFS= read -r -s -n1 pass; do
    if [[ -z $pass ]]; then
      echo
      break
    else
      echo -n '*'
      password+=$pass
    fi
  done
  echo "Please, confirm it typing again: "
  unset confirm
  while IFS= read -r -s -n1 conf; do
    if [[ -z $conf ]]; then
      echo
      break
    else
      echo -n '*'
      confirm+=$conf
    fi
  done
  if [[ $password == $confirm ]]; then
    echo -e "[!] All Right! Continuing...\n"
    sleep 2
  else
    sleep 2 ; clear
    echo -e "[!] Wrong, please do it again\n"
    createPassword
  fi
}

createUser() {
  clear
  echo -e "Create a username: "
  read username
  createPassword
  useradd -m ${username}
  echo ${username}:${password} | chpasswd
  usermod -aG libvirt ${username}

  # Adding user in SUDOERS
  echo "${username} ALL=(ALL) ALL" >> /etc/sudoers.d/${username}
}
createUser
