#!/bin/bash

# installs dependencies for instantOS

export LINK="https://raw.githubusercontent.com/instantos/instantos/master"

# install on arch based system
pacinstall() {
    for i in "$@"; do
        { pacman -iQ "$i" || command -v "$i"; } &>/dev/null && continue
        echo "Installing $i"
        sudo pacman -S --noconfirm "$i" &>/dev/null
    done
}

if ! command -v pacman &>/dev/null; then
    echo "distro not supported"
    exit
fi

# cross distro install command
ipkg() {
    pacinstall "$@"
}

ipkg wget
ipkg hwinfo

# add the custom repo
curl -s https://raw.githubusercontent.com/instantOS/instantOS/master/rootinstall.sh | bash

sudo pacman -Syu --noconfirm

pacinstall picom
pacinstall arc-gtk-theme
pacinstall acpi
pacinstall xrandr

pacinstall slop
pacinstall xorg-xsetroot
pacinstall xorg-fonts-misc

pacinstall tar

pacinstall autoconf
pacinstall automake
pacinstall binutils
pacinstall bison
pacinstall fakeroot
pacinstall file
pacinstall findutils
pacinstall flex
pacinstall gawk
pacinstall gcc
pacinstall gettext
pacinstall grep
pacinstall groff
pacinstall gzip
pacinstall libtool
pacinstall m4
pacinstall make
pacinstall pacman
pacinstall patch
pacinstall pkgconf
pacinstall sed
pacinstall sudo
pacinstall texinfo
pacinstall which

pacinstall p7zip

pacinstall panther_launcher
pacinstall instantutils
pacinstall instantwallpaper
pacinstall instantdotfiles
pacinstall instantassist
pacinstall instantwidgets

pacinstall instantmenu
pacinstall instantwm
pacinstall instantlock

pacinstall xdragon
pacinstall autojump
pacinstall wmutils
pacinstall grub-theme-instantos

ipkg bash
ipkg dash
ipkg tmux

ipkg git
ipkg subversion

ipkg dialog
ipkg neovim
ipkg fzf
ipkg ranger
ipkg sl

ipkg ffmpeg
ipkg feh
ipkg mpv

ipkg arandr
ipkg qt5ct
ipkg lxappearance

ipkg rofi
ipkg conky
ipkg dunst
ipkg rxvt-unicode

ipkg xdotool
ipkg wmctrl
ipkg xclip

ipkg youtube-dl

ipkg nautilus
ipkg cpio

if hwinfo --gfxcard --short | grep -iE 'nvidia.*(gtx|rtx|titan)'; then
    echo "installing nvidia graphics drivers"
    sudo mhwd -a pci nonfree 0300
    if grep -Eiq 'instantos|manjaro' /etc/os-release; then
        if pacman -iQ linux54; then
            pacinstall linux54-nvidia-440x
        fi

        if pacman -iQ linux419; then
            pacinstall linux419-nvidia-440xx
        fi
    else
        if pacman -iQ linux-lts; then
            pacinstall nvidia-lts
        fi
        pacinstall nvidia
    fi
fi
