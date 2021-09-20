#!/usr/bin/env bash

# DIRS
DIR=`pwd`
FONTSDIR="$HOME/.local/share/fonts"
POLYBARDIR="$HOME/.config/polybar"

# INSTALL FONTS
install_fonts() {
    echo -e "\n[*] Installing fonts..."
    if [[ -d "$FONTSDIR" ]]; then
        cp -rf $DIR/fonts/* "$FONTSDIR"
    else
        mkdir -p "$FONTSDIR"
        cp -rf $DIR/fonts/* "$FONTSDIR"
    fi
}

# INSTALL THEMES
install_themes() {
    if [[ -d "$POLYBARDIR" ]]; then
        echo -e "[*] Creating a backup of your polybar config..."
        mv "$POLYBARDIR" "${POLYBARDIR}.old"
        { mkdir -p "$POLYBARDIR"; cp -rf $DIR/$STYLE/* "$POLYBARDIR"; }
    else
        { mkdir -p "$POLYBARDIR"; cp -rf $DIR/$STYLE/* "$POLYBARDIR"; }
    fi

    if [[ -f "$POLYBARDIR/launch.sh" ]]; then
        echo -e "[*] Sucessfully installed.\n"
        exit 0
    else
        echo -e "[!] Failed to install.\n"
        exit 1
    fi
}

# MAIN
main() {
    clear
    cat <<- EOF
        [*] Installing Polybar Themes...

        [*] Choose Style -
        [1] Simple
        [2] Bitmap

    EOF

    read -p "[?] Select Option : "

    if [[ $REPLY == "1" ]]; then
        STYLE='simple'
        install_fonts
        install_themes
    elif [[  $REPLY == '2']]; then
        STYLE='bitmap'
        install_fonts
        install_themes
    else
        echo -e "\n[!] Invalid Option, Exiting...\n"
        exit 1
    fi
}

main
