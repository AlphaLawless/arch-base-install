#!/bin/bash

packages() {
    clear
    cat <<EOF
[*] Quais os pacotes você quer instalar?

[*] Escolha um -
[1] Pacotes principais
[2] Pacotes essenciais

EOF

    read -p "[?] Selecione a opção, digitando 1 ou 2: "

    if [[ $REPLY == "1" ]]; then
        pacman -S grub base-devel os-prober networkmanager network-manager-applet dialog wpa_supplicant xdg-user-dirs xdg-utils wireless_tools dosfstools mtools linux-headers avahi openssh openbsd-netcat ipset firewalld nss-mdns dnsutils vde2 nfs-utils bash-completion reflector sof-firmware dnsmasq pulseaudio alsa-utils virt-manager qemu qemu-arch-extra edk2-ovmf acpi acpi_call acpid cups ntfs-3g terminus-font
        sleep 5 ; clear ; lsblk
        echo -e "Digite o nome da sua partição para instalar o grub, use a tabela acima. e.g. /dev/sdx: "
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
        tlp_install() {
            read -p "Você está em um laptop? [y/N] "

            if [[ ${REPLY,,[A-Z} = "y" ]]; then
                echo "INSTALANDO TLP"
                pacman -S tlp tlp-rdw
                systemctl enable tlp.service
            else
                return 0
            fi
        }
        tlp_install

    elif [[ $REPLY == "2" ]]; then
        pacman -S grub base-devel os-prober networkmanager network-manager-applet dialog wpa_supplicant wireless_tools dosfstools mtools openssh reflector firewalld cups virt-manager qemu qemu-arch-extra edk2-ovmf pulseaudio alsa-utils
        sleep 5 ; clear ; lsblk
        echo -e "Digite o nome da sua partição para instalar o grub, use a tabela acima. e.g. /dev/sdx: "
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
        echo "[!] Opção inválida!"
        sleep 2 ; clear ; packages
    fi
}

videoDriverInstall(){
	cat <<- EOF

		[*] Você quer instalar os drivers de video agora?

		[*] Escolha um -
		[1] Sim
		[2] Não

	EOF

	read -p "[?] Selecione a opção, digitando 1 ou 2: "

	if [[ $REPLY == "1" ]]; then
		cat <<- EOF
			[*] Qual é a sua placa de vídeo?

			[*] Escolha um -
			[1] Intel
			[2] Amd
			[3] Nvidia
		EOF

		read -p "[?] Selecione a opção: "

		if [[ $REPLY == "1" ]]; then
            echo -e "\n[!] Instalando drivers da Intel "
			pacman -S xf86-video-intel
		elif [[ $REPLY == "2" ]]; then
            echo -e "\n[!] Instalando drivers da Amd "
			pacman -S xf86-video-amdgpu
		elif [[ $REPLY == "3" ]]; then
            echo -e "\n[!] Instalando drivers da Nvidia "
			pacman -S nvidia nivida-utils nvidia-settings
		else
			echo "[!] Opção inválida: "
			sleep 3 ; clear ; videoDriverInstall
		fi
	elif [[ $REPLY == "2" ]]; then
		return 0
	fi
}

createPassword() {
    echo -e "Digite a senha para o usuário: "
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
    echo "Por favor, confirme novamente: "
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
        echo -e "[!] Tudo certo! Continuando...\n"
        sleep 2
    else
        sleep 2 ; clear
        echo -e "[!] Errado, por favor faça novamente\n"
        createPassword
    fi
}

createUser() {
    clear
    echo -e "Crie um usuário: "
    read username
    createPassword
    useradd -m ${username}
    echo ${username}:${password} | chpasswd
    usermod -aG libvirt ${username}

    # Adding user in SUDOERS
    echo "${username} ALL=(ALL) ALL" >> /etc/sudoers.d/${username}
}
packages
videoDriverInstall
createUser

