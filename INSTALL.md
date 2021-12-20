# Installation Guide

- [pt-BR](./docs/INSTALL.md)

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
3. Now run the script - I recommending making or taking a coffee now - and follow the instructions:
```sh
./arch-install.sh -i
```
    a) (Optional) You can see another options using simply `./arch-install.sh`

With everything done you can leave `arch-chroot` typing `exit`, or using Ctrl + D. Then with it, umount the partitions using `umount -a` and finally reboot the system.

## DE or WM

At the moment both the KDE and DWM scripts are being written.

### Window Manager

- [BWPWM](./bspwm)
- [DWM](./dwm)

### Desktop Environment

- [KDE](./kde)
- [GNOME](./gnome)

## Troubleshooting

Problems may happen during the installation, as a matter of fact, the script is not 100% optimized for every machine. If anything occurs I recommend reading the entire error message and keep it, then install it again until the `git clone` command, remembering the error. Finally, change everything you need in the scripts using vim/nano. If the error doesn't go away, send an Issue explaining what happened.
