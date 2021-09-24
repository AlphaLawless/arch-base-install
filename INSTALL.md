# Installation Guide

* [pt-BR](./doc/INSTALLpt.md)

## Base scripts

With everything installed and mounted let's get to the scripts!

1. Clone the arch-base-install repository:
```
git clone https://github.com/alphalawless/arch-base-install
```
2. Enter the arch-base-install folder:
```
cd arch-base-install
```
3. Change what you need in `base-mbr.sh` or `base-uefi.sh` with vim (or any other editor):
```sh
vim base-mbr.sh
#vim base-uefi.sh
```
4. Now grant the permission for executing in the shell with `chmod`:
```sh
chmod +x base-mbr.sh
#chmod +x base-uefi.sh
```
5. Now run the script - I recommending making or taking a coffee now -!:
```sh
./base-mbr.sh
#./base-uefi.sh
```

With everything done you can leave `arch-chroot` typing `exit`, or using Ctrl + D. Then with it, umount the partitions using `umount -a` and finally reboot the system.

## DE or WM

...
Still in progress... Come back later!