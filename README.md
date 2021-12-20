# Arch Linux Base Install
* [pt-BR](https://github.com/AlphaLawless/arch-base-install/blob/main/docs/README.md)

Before you get start with the scripts, I would like to thank you for coming to this repository. First, you need to certificate that you have done all installation standard process from the [ArchWiki Guide](https://wiki.archlinux.org/title/Installation_guide)

If you want to know how I build my Arch linux, follow the instructions! If you just want to know about the scripts installation, [click here](./README.md#Scripts-installation)!

## Installing Arch Linux

Configure your keyboard:
```
loadkeys br-abnt2   #for brazilian portuguese
loadkeys us   #for us keyboard
```

### Connecting to the internet
For wireless and WWAN, make sure your Wi-Fi card is not blocked with `rfkill list`. If it returns:
```
0: phy0: Wireless LAN
	Soft blocked: yes
	Hard blocked: yes
```
If the Wi-Fi card has the *Hard blocked* status turned on, then press the function key and the network corresponding key (`Fn + network key`). If it has the *Soft blocked* status turned on, then use the following command:
```
rfkill unblock wifi
```
After unlocking your Wi-Fi card, then let's go to the next steps:

* Ethernet -- Just plug in the Ethernet cable.
* Wi-Fi -- Log in to the wireless network through prompt [`iwctl`](https://wiki.archlinux.org/title/Iwd#iwctl).
* Mobile internet modem -- Connect to the mobile network with the utility [`mmcli`](https://wiki.archlinux.org/title/Mobile_broadband_modem#ModemManager).

How do I use Wi-Fi network here are the steps:
1. List all Wi-Fi devices:
```
[iwd] device list
```
2. Then to list all available networks from the *device*:
```
[iwd] station device get-networks
```
3. Fially, to connect to any network using the SSID (or the name, if you prefer):
```
[iwd] station device connect SSID
```
Type your network password and exit the `iwctl` typing `exit`.

For more information read [rfkill](https://wiki.archlinux.org/title/Network_configuration/Wireless#Rfkill_caveat) and [Connect to the internet](https://wiki.archlinux.org/title/Installation_guide#Connect_to_the_internet).


Confirming you are connected:
```
ping archlinux.org
```
**From now on I separated two paths depending on your system. Read carefully!**
### Check boot mode
Before getting started partitioning the drive and setting our network up, we must make sure we are using the [UEFI](./README.md#UEFI). Type in the terminal:
```sh
ls /sys/firmware/efi/efivars
```
All right! Now, if there's any error in the directory, it means that the system has been booted up in [BIOS Legacy mode](./README.md#BIOS-Legacy).

## UEFI

### Disk partitioning
Personally, I like to partition my EFI system using a pseudo graphical interface `cfdisk /dev/partition`, with the following layout:

UEFI with [GPT](https://wiki.archlinux.org/title/Partitioning#GUID_Partition_Table)

**Mount point** | **Partitios**                  | **Partition type**     | **Size**
---                   |---                            |---                       |---
/mnt/boot/efi         |*/dev/efi_partition_system* |[**EFI Partition System**](https://wiki.archlinux.org/title/EFI_system_partition) | 500M
[SWAP]                |*/dev/swap_partition*           |Linux swap                | 2G ~ 8G
/mnt                  |*/dev/root_partition*         |Linux x86-64 root (/)     | 40%~60% of disk size
/mnt/home             |*/dev/home_partition*           |Linux x86-64 home         | 40%~60% of disk size

### Format partitions

Each created partition must be formatted with a proper [file system](https://wiki.archlinux.org/title/File_systems#Types_of_file_systems). For a batter guide I recommend listing all partition with `lsblk`. Then go for the instructions!
* For */mnt/boot/efi*:
```
mkfs.vfat /dev/EFI_system_partition
```
* For *[SWAP]*:
```
mkswap /dev/swap_partition
```
* For */mnt*:
```
mkfs.ext4 /dev/root_partition
```
* For */mnt/home*:
```
mkfs.ext4 /dev/home_partition
```

### Mount the file system
* To start mount the root volume in /mnt with the `mount` command:
```
mount /dev/root_partition /mnt
```
* Now create the home and efi boot folders with `mkdir`:
```
mkdir -p /mnt/{home,boot/efi}
```
* Mounting home:
```
mount /dev/home_partition /mnt/home
```
* Mounting efi boot:
```
mount /dev/efi_boot_system /mnt/boot/efi
```
* Finally, enabling swapt:
```
swapon /dev/swap_partition
```
With the partitions all mounted you can proceed to the final part of the [installation](./README.md#Installation).

## BIOS Legacy
Personally, I like to partition my BIOS Legacy system using a pseudo graphical interface `cfdisk /dev/partition`, with the following layout:

BIOS with [MBR](https://wiki.archlinux.org/title/Partitioning#Master_Boot_Record)
**Mount point** | **Partition**                  | **Partition type**     | **Size**
---                   |---                            |---                       |---
BIOS Legacy           |*/dev/bios_partition*           |BIOS Legacy               | 500M
[SWAP]                |*/dev/swap_partition*           |Linux swap                | 2G ~ 8G
/mnt                  |*/dev/root_partition*           |Linux x86-64 root (/)     | 40%~60% of the disk size
/mnt/home             |*/dev/partição_home*           |Linux x86-64 home         | 40%~60% of the disk size

### Format the partitions

Each created partition must be formatted with a proper [file system](https://wiki.archlinux.org/title/File_systems#Types_of_file_systems). For a batter guide I recommend listing all partition with `lsblk`. Then go for the instructions!
* For *[SWAP]*:
```
mkswap /dev/swap_partition
```
* For */mnt*:
```
mkfs.ext4 /dev/root_partition
```
* For */mnt/home*:
```
mkfs.ext4 /dev/home_partition
```
### Mount the file system
* To start mount the root volume in /mnt with the `mount` command:
```
mount /dev/root_partition /mnt
```
* Now create the home folder with `mkdir`:
```
mkdir -p /mnt/home
```
* Mounting home:
```
mount /dev/home_partition /mnt/home
```
* Finally, enabling swapt:
```
swapon /dev/swap_partition
```
*OBS: If you paid attention you noticed that the BIOS Legacy doesn't need to be mounted, just formatted. For the rest, the system finishes it all dinamically*

With the partitions all mounted you can proceed to the final part of the [installation](./README.md#Installation).

## Installation
If you have a slow connection and don't know much about [mirrors](https://wiki.archlinux.org/title/Installation_guide#Select_the_mirrors) I recommend reading about them on Arch wiki.

### Installing the essential packages
Use the [pacstrap](https://man.archlinux.org/man/pacstrap.8) to install the needed packages, such as the linux kernel, hardware firmware, and others.
```
pacstrap /mnt base linux linux-firmware intel-ucode git vim
```
*OBS: You can exchange intel-ucode for amd-ucode if your hardware is from amd!*

I hope you got a coffee because this can take some time (or not so much).
Ending it, let's get to the final step before `arch-chroot` and run the scripts!

### Fstab
Generate a [fstab](https://wiki.archlinux.org/title/Fstab) (use -U or -L to choose between [UUID](https://wiki.archlinux.org/title/Persistent_block_device_naming#by-uuid) and labels, respectively):
```
genfstab -U /mnt >> /mnt/etc/fstab
```
All done! Now we can change to the new system root:
```
arch-chroot /mnt
```
## Scripts installation
All instruction might be found in [INSTALL.md](./INSTALL.md).

## Credits

Great amount of arch linux installation I got from several youtube videos from [Erman Ferrari](https://www.youtube.com/c/EFLinuxMadeSimple). The other credits are on their corresponding folders. And, of course, all [wallpapers](https://github.com/AlphaLawless/arch-base-install/tree/main/wallpapers) are free for downloading!

## Licence

[MIT License](./LICENSE)
