#!/bin/bash

body() {
	cat <<- EOF
		[*] What language do you want to install on your system?

		[*] Choose one -
		[1] Portuguese
		[2] English
	EOF

  read -p "[?] Select Option, typing 1 or 2: "

  if [[ $REPLY == "1" ]]; then
    ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
    hwclock --systohc
    sed -i '393s/.//' /etc/locale.gen # uncomment in line 393 pt_BR.UTF-8 UTF-8
    locale-gen
    echo "LANG=pt_BR.UTF-8" >> /etc/locale.conf
    echo "KEYMAP=br-abnt2" >> /etc/vconsole.conf
    echo "Digite um nome para o hostname da máquina? "
    read hostname
    echo ${hostname} >> /etc/hostname
    echo "127.0.0.1 localhost.localdomain localhost" >> /etc/hosts
    echo "::1       localhost.localdomain localhost" >> /etc/hosts
    echo "127.0.1.1 ${hostname}.localdomain ${hostname}" >> /etc/hosts
    bash "/arch-base-install/scripts/base-uefi/languages/root-passwordPT.sh"
  elif [[ $REPLY == "2" ]]; then
    echo -e "Enter with your Region: "
    read region
    echo -e "Enter with your City now: "
    read city
    ln -sf /usr/share/zoneinfo/${region}/${city} /etc/localtime
    sed -i '177s/.//' /etc/locale.gen # uncomment in line 177 for en_US.UTF-8 UTF-8
    echo "LANG=en_US.UTF-8" >> /etc/locale.conf
    echo "Enter with your keyboard map: "
    read keyboard
    echo "KEYMAP=${keyboard}" >> /etc/vconsole.conf
    echo "What's the hostname of the machine? "
    read hostname
    echo ${hostname} >> /etc/hostname
    echo "127.0.0.1 localhost" >> /etc/hosts
    echo "::1       localhost" >> /etc/hosts
    echo "127.0.1.1 ${hostname}.localdomain ${hostname}" >> /etc/hosts
    bash "/arch-base-install/scripts/base-uefi/languages/root-passwordEN.sh"
  else
    echo "[!] Invalid option! "
    sleep 2
    clear
    body
  fi
  return $REPLY
}
body

if [[ $REPLY == "1" ]]; then
  bash "/arch-base-install/scripts/base-uefi/languages/portuguese.sh"
elif [[ $REPLY == "2" ]]; then
  bash "/arch-base-install/scripts/base-uefi/languages/english.sh"
fi

sleep 2
clear
printf "\e[1;132mDone! Type exit, umount -a and reboot or umount -R /mnt and shutdown -h now.\e[0m"

