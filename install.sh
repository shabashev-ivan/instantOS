#!/usr/bin/env bash

#############################################
## installs all paperbenni suckless forks  ##
## made for personal use, so be warned ;)  ##
#############################################

echo "installing paperbenni's suckless suite"

source <(curl -s https://raw.githubusercontent.com/paperbenni/bash/master/import.sh)
pb install

# pinstall dash slop ffmpeg wmctrl

gclone() {
    git clone --depth=1 https://github.com/paperbenni/"$1".git
}

gprogram() {
    wget "https://raw.githubusercontent.com/paperbenni/suckless/master/programs/$1"
    usrbin "$1"
}

mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
if ! [ -e monaco.ttf ]; then
    wget https://github.com/todylu/monaco.ttf/raw/master/monaco.ttf
fi

cd

rm -rf suckless
mkdir suckless
cd suckless

gclone dwm
gclone dmenu
gclone st

# needed for slock
if grep -q 'nobody' </etc/groups; then
    sudo groupadd nobody
fi
gclone slock

# session for lightdm
wget https://raw.githubusercontent.com/paperbenni/suckless/master/dwm.desktop
sudo mv dwm.desktop /usr/share/xsessions/

# x session wrapper
gprogram startdwm
# shutdown popup that breaks restart loop
gprogram sucklessshutdown

gprogram autoclicker
# deadcenter toggle script
gprogram deadcenter
# dmenu run but in terminal emulator st
# only supported terminal apps (less to search through)
gprogram dmenu_run_st
curl $LINK/termprograms.txt >~/.cache/termprograms.txt

for FOLDER in ./*; do
    if ! [ -d "$FOLDER" ]; then
        echo "skipping $FOLDER"
        continue
    fi
    pushd "$FOLDER"
    rm config.h
    make
    sudo make install
    popd
done

# install dotfiles like bash,git and tmux config
if ! [ -z "$1" ]; then
    curl https://raw.githubusercontent.com/paperbenni/dotfiles/master/install.sh | bash
fi

LINK="https://raw.githubusercontent.com/paperbenni/suckless/master"

if cat /etc/os-release | grep -i 'arch'; then
    echo "setting up arch specific stuff"

    if ! command -v compton; then
        sudo pacman --noconfirm -S compton
    fi

    if ! command -v panther_launcher; then
        wget "https://www.rastersoft.com/descargas/panther_launcher/panther_launcher-1.12.0-1-x86_64.pkg.tar.xz"
        sudo pacman -U --noconfirm panther_launcher*.pkg.tar.xz
        rm panther_launcher*.pkg.tar.xz
    fi

fi

# ubuntu specific stuff
if grep -iq 'ubuntu' </etc/os-release; then
    if ! command -v panther_launcher; then
        wget "https://www.rastersoft.com/descargas/panther_launcher/panther-launcher-xenial_1.12.0-ubuntu1_amd64.deb"
        sudo dpkg -i panther-launcher*.deb
        sudo apt-get install -fy
        rm panther-launcher*.deb
    fi
fi

# auto start script with dwm
ls ~/.dwm || mkdir ~/.dwm
curl $LINK/autostart.sh >~/.dwm/autostart.sh

# notification program for deadd-center
git clone --depth=2 https://github.com/phuhl/notify-send.py
cd notify-send.py
sudo pip2 install notify2
sudo python3 setup.py install
cd ..
sudo rm -rf notify-send.py

mkdir -p ~/.config/deadd
curl $LINK/deadd.conf >~/.config/deadd/deadd.conf

# install window switcher
curl "$LINK/dswitch" | sudo tee /usr/local/bin/dswitch
sudo chmod +x /usr/local/bin/dswitch

# install win + a menus for shortcuts like screenshots and shutdown
curl https://raw.githubusercontent.com/paperbenni/menus/master/install.sh | bash

## notification center ##
# remove faulty installation
sudo rm /usr/bin/deadd &>/dev/null
sudo rm /usr/bin/deadcenter &>/dev/null

# main binary
echo "installing deadd"
wget -q $LINK/bin/deadd.xz
xz -d deadd.xz
sleep 0.1
sudo mv deadd /usr/bin/deadd
sudo chmod +x /usr/bin/deadd

mkdir ~/paperbenni &>/dev/null

# automatic wallpaper changer
gclone rwallpaper
cd rwallpaper
mv rwallpaper.py ~/paperbenni/
chmod +x wallpaper.sh
mv wallpaper.sh ~/paperbenni/
sudo pip3 install -r requirements.txt
cd ..
rm -rf rwallpaper

# add startup sound
if command -v youtube-dl; then
    youtube-dl -x --audio-format wav -o ~/paperbenni/boot.wav https://www.youtube.com/watch?v=i9qOJqNjalE
fi

# fix java on dwm
if ! grep 'dwm' </etc/profile; then
    echo "fixing java windows for dwm in /etc/profile"
    echo '# fix dwm java windows' | sudo tee -a /etc/profile
    echo 'export _JAVA_AWT_WM_NONREPARENTING=1' | sudo tee -a /etc/profile
else
    echo "java workaround already applied"
fi
