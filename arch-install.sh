#!/usr/bin/env bash

shopt -s extglob

usage() {
    cat <<EOF

usage: ${0##*/} [flags] [options]

    options:

    --install, -i            Start installation
    --version, -v            View installer version
    --help, -h               Show options help

EOF
}

if [[ -z $1 || $1 = @(-h| --help) ]];then
    usage
    exit $(( $# ? 0 : 1 ))
fi

version="${0##*/} version 1.9.2"

set_install() {
    local get=$(ls /sys/firmware/efi/efivars)

    if $get ; then
        echo "[!] Install BIOS LEGACY MODE"
        bash ./scripts/base-mbr/base-mbr.sh
    else
        echo "[!] Install UEFI MODE"
        bash ./scripts/base-uefi/base-uefi.sh
    fi
}

case "$1" in

    "--install"|"-i") set_install ;;
    "--version"|"-v") echo $version ;;
    "--help"|"-h") usage ;;
    *) echo "Invalid option" && usage ;;

esac

exit 0
