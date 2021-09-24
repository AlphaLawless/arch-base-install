# Arch Linux Base Install
* [en-US](../README.md)

Antes de iniciar com os scripts, gostaria de agradecer você por ter chegado esse repositório. Primeiramente, você precisa certificar de ter feito todas as etapas padrões de instalação do **Arch Linux**. Siga as instruções do [guia](https://wiki.archlinux.org/title/Installation_guide_(Portugu%C3%AAs)) da archwiki, afinal esse guia foi baseado nele.

Caso queira saber como eu faço a montagem do meu arch linux, siga as instruções! Caso queira saber apenas da instalação dos scripts, [clique aqui](./README.md#Instação-dos-scripts)! 

## Instalando o Arch Linux

Configure o seu teclado. No meu caso:
```
loadkeys br-abnt2
```
#### AVISO

Eu não configuro o `locale-gen`, exportando a variável de idioma para pt-BR. Pois, acredito que o inglês usado na iso de instalação do arch é fácil compreensão para não falantes da lingua inglesa. Recomendo seguir em inglês!

### Conectar à Internet
Para rede sem fio e WWAN, certifique-se que a placa de rede não esteja bloqueada com `rfkill list`. Caso retorne:
```
0: phy0: Wireless LAN
	Soft blocked: yes
	Hard blocked: yes
```
Se a placa estiver com o *hard blocked* ligado, use o botão `Fn` + a tecla correspondente à rede. Se a placa estiver com *Hard Blocked* desligado e *Soft Blocked* ligado, use o seguinte comando:
```
rfkill unblock wifi
```
Desbloqueado sua placa de rede Wi-Fi vamos para os próximos passos:

* Ethernet -- apenas conect o cabo que vai ter internet.
* Wi-Fi -- autentique-se à rede sem fio pelo prompt [`iwctl`](https://wiki.archlinux.org/title/Iwd_(Portugu%C3%AAs)#iwctl).
* Modem de internet móvel -- conecte-se à rede móvel com o utilitário [`mmcli`](https://wiki.archlinux.org/title/Mobile_broadband_modem#ModemManager).

Como eu utilizo rede Wi-Fi aqui vai os passos:
1. Listar todos os dispositivos Wi-Fi:
```
[iwd] device list
```
2. Em seguida, para listar todas as redes disponíveis do *dispositivo*:
```
[iwd] station dispositivo get-networks
```
3. Por fim, para conectar-se a uma rede, lembrando que *SSID* é o nome da rede, e.g. Maria, João, Alpha...:
```
[iwd] station dispositivo connect SSID
```
Digite a senha da sua rede e saia do prompt `iwctl` digitando `exit`.

Mais informações leia na [rfkill](https://wiki.archlinux.org/title/Network_configuration_(Portugu%C3%AAs)/Wireless_(Portugu%C3%AAs)#Problemas_com_rfkill) e [Conectar à Internet](https://wiki.archlinux.org/title/Installation_guide_(Português)#Conectar_à_internet).


Confirme que esteja conectado:
```
ping archlinux.org
```
**A partir daqui eu separei em dois caminhos dependendo do seu sistema. Leia com atenção!**
### Verificar o modo de inicialização
Antes de começar a montar partições e configurar nossa rede. Precisamos ter certeza que estamos no modo [UEFI](./README.md#UEFI). Digite no terminal:
```sh
ls /sys/firmware/efi/efivars
```
Tudo certo podemos começar! Agora, caso o comando mostre erro no diretório, significa que o sistema foi inicializado no modo [BIOS Legacy](./README.md#BIOS-Legacy).
## UEFI

### Partição dos Discos
Eu particularmente particiono o sistema EFI utilizando a pseuda interface gráfica `cfdisk /dev/partição`, com o seguinte layout:

UEFI com [GPT](https://wiki.archlinux.org/title/Partitioning_(Portugu%C3%AAs)#Tabela_de_Parti%C3%A7%C3%A3o_GUID)

**Ponto de montagem** | **Partição**                  | **Tipo de partição**     | **Tamanho**
---                   |---                            |---                       |---
/mnt/boot/efi         |*/dev/partição_de_sistema_efi* |[**Partição de Sistema EFI**](https://wiki.archlinux.org/title/EFI_system_partition_(Portugu%C3%AAs)) | 500M
[SWAP]                |*/dev/partição_swap*           |Linux swap                | 2G ~ 8G
/mnt                  |*/dev/partição_raiz*           |Linux x86-64 root (/)     | 40%~60% Gib do disco
/mnt/home             |*/dev/partição_home*           |Linux x86-64 home         | 40%~60% Gib do disco 

### Formatar as partições

Cada partição criada deve ser formatada com um sistema de [arquivos](https://wiki.archlinux.org/title/File_systems_(Português)#Tipos_de_sistemas_de_arquivos) adequado. Para um melhor guia recomendo você listar todas as suas partições com o comando `lsblk`. E siga as instruções!
* Para */mnt/boot/efi*:
```
mkfs.vfat /dev/partição_de_sistema_efi
```
* Para *[SWAP]*:
```
mkswap /dev/partição_swap
```
* Para */mnt*:
```
mkfs.ext4 /dev/partição_raiz
```
* Para */mnt/home*:
```
mkfs.ext4 /dev/partição_home
```

### Montar os sistemas de arquivos
* Para começar monte o volume raiz em /mnt usando o comando `mount`:
```
mount /dev/partição_raiz /mnt
```
* Crie agora usando o `mkdir` as pastas para a home e para o boot efi:
```
mkdir -p /mnt/{home,boot/efi}
```
* Montando a home:
```
mount /dev/partição_home /mnt/home
```
* Montando o boot efi:
```
mount /dev/partição_de_sistema_efi
```
* Por fim habilitando o swap:
```
swapon /dev/partição_swap
```
Montada as partições você pode ir para a parte final de [instação](./README.md#Instalação).

## BIOS Legacy
Eu particularmente particiono o sistema BIOS Legacy utilizando a pseuda interface gráfica `cfdisk /dev/partição`, com o seguinte layout:

BIOS com [MBR](https://wiki.archlinux.org/title/Partitioning_(Portugu%C3%AAs)#Master_Boot_Record)
**Ponto de montagem** | **Partição**                  | **Tipo de partição**     | **Tamanho**
---                   |---                            |---                       |---
BIOS Legacy           |*/dev/partição_bios*           |BIOS Legacy               | 500M
[SWAP]                |*/dev/partição_swap*           |Linux swap                | 2G ~ 8G
/mnt                  |*/dev/partição_raiz*           |Linux x86-64 root (/)     | 40%~60% Gib do disco
/mnt/home             |*/dev/partição_home*           |Linux x86-64 home         | 40%~60% Gib do disco

### Formatar as partições

Cada partição criada deve ser formatada com um sistema de [arquivos](https://wiki.archlinux.org/title/File_systems_(Português)#Tipos_de_sistemas_de_arquivos) adequado. Para um melhor guia recomendo você listar todas as suas partições com o comando `lsblk`. E siga as instruções!
* Para *BIOS Legacy*:
```
mkfs.vfat /dev/partição_do_BIOS_Legacy
```
* Para *[SWAP]*:
```
mkswap /dev/partição_swap
```
* Para */mnt*:
```
mkfs.ext4 /dev/partição_raiz
```
* Para */mnt/home*:
```
mkfs.ext4 /dev/partição_home
```

### Montar os sistemas de arquivos
* Para começar monte o volume raiz em /mnt usando o comando `mount`:
```
mount /dev/partição_raiz /mnt
```
* Crie agora usando o `mkdir` a pasta onde vai ficar sua home:
```
mkdir -p /mnt/home
```
* Montando a home:
```
mount /dev/partição_home /mnt/home
```
* Por fim habilitando o swap:
```
swapon /dev/partição_swap
```
*OBS: Caso você tenha percebido o sistema BIOS Legacy não precisa ser montado, apenas formatado. De resto, o próprio sistema vai concluir de forma dinâmica.*

Montada as partições você pode ir para a parte final de [instação](./README.md#Instalação).

## Instalação
Caso você tenha uma internet lenta e não tem conhecimento de [espelhos](https://wiki.archlinux.org/title/Installation_guide_(Português)#Selecionar_os_espelhos)(*mirrors*) recomendo ler sobre no archlinux.

### Instalando os pacotes essenciais
Use o script [pacstrap](https://man.archlinux.org/man/pacstrap.8) para instalar os pacotes necessários, como kernel linux, firmware para o hardware entre outros que você queira.
```
pacstrap /mnt base linux linux-firmware intel-ucode git vim
```
*OBS:Você pode substituir intel-ucode por amd-ucode caso seu hardware seja da amd!* 

Espero que você tenha pego um café porque essa parte leva um certo tempo. Finalizado, vamos para a etapa final antes de passar para o `arch-chroot` e executar os scripts.

### Fstab
Gere um arquivo [fstab](https://wiki.archlinux.org/title/Fstab_(Portugu%C3%AAs)) (use -U ou -L para definir por [UUID](https://wiki.archlinux.org/title/Persistent_block_device_naming_(Portugu%C3%AAs)#by-uuid) ou rótulos, respectivivamente):
```
genfstab -U /mnt >> /mnt/etc/fstab
```
Pronto! Agora podemos mudar para a raiz do novo sistema:
```
arch-chroot /mnt
```
## Instalação dos scripts
Todas as instruções podem ser encontradas no [INSTALL.md](./INSTALL.md)

## Créditos 

Grande parte desses conhecimentos de instalação de arch linux, eu consegui vendo os vídeos do Youtuber [Ermano Ferrari](https://www.youtube.com/c/EFLinuxMadeSimple). Os demais créditos estão nas respectivas pastas. E os [wallpapers](https://github.com/AlphaLawless/arch-base-install/tree/main/wallpapers) são gratuitos!

## Licença

[MIT License](../LICENSE)