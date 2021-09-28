# Installation Guide

- [pt-BR](./doc/INSTALL.md)

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

At the moment both the KDE and DWM scripts are being written.

### Window Manager

- [BWPWM](./bspwm)
- [DWM](./dwm)

### Desktop Environment

- [KDE](./kde)

## Troubleshooting

Problems may happen during the installation, as a matter of fact, the script is not 100% optimized for every machine. If anything occurs I recommend reading the entire error message and keep it, then install it again until the `git clone` command, remembering the error. Finally, change everything you need in the scripts using vim/nano. If the error doesn't go away, send an Issue explaining what happened.

