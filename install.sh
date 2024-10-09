#!/bin/bash

set -e  # Exit immediately if a command fails

# ----------------------------------------
# FUNCTIONS
# ----------------------------------------

# Function to update and install packages
update_and_install() {
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get install --fix-broken -y
    sudo apt-get autoremove -y
    sudo apt-get clean
}

# ----------------------------------------
# INITIAL CONFIGURATION
# ----------------------------------------

# Disable command history in Bash
echo "set +o history" >> ~/.bashrc

# Download and install the deb-multimedia-keyring package
wget -O /tmp/deb-multimedia-keyring.deb https://www.deb-multimedia.org/pool/main/d/deb-multimedia-keyring/deb-multimedia-keyring_2016.8.1_all.deb
sudo dpkg -i /tmp/deb-multimedia-keyring.deb || sudo apt-get install -f -y
sudo rm -f /tmp/deb-multimedia-keyring.deb

# Configure Debian repositories
sudo bash -c 'cat > /etc/apt/sources.list' << EOF
# DEBIAN
deb http://deb.debian.org/debian/ bookworm main non-free-firmware contrib non-free
deb-src http://deb.debian.org/debian/ bookworm main non-free-firmware contrib non-free

deb http://security.debian.org/debian-security bookworm-security main non-free-firmware contrib non-free
deb-src http://security.debian.org/debian-security bookworm-security main non-free-firmware contrib non-free

deb http://deb.debian.org/debian/ bookworm-updates main non-free-firmware contrib non-free
deb-src http://deb.debian.org/debian/ bookworm-updates main non-free-firmware contrib non-free

# MULTIMEDIA
deb https://www.deb-multimedia.org bookworm main non-free
deb https://www.deb-multimedia.org bookworm-backports main

# BACKPORTS
deb http://deb.debian.org/debian bookworm-backports main contrib non-free-firmware
deb-src http://deb.debian.org/debian bookworm-backports main contrib non-free-firmware
EOF

# Update package list and install updates and missing packages
update_and_install

# ----------------------------------------
# INSTALL BUDGIE DESKTOP AND RELATED PACKAGES
# ----------------------------------------

# Install Budgie Desktop and related packages
sudo apt-get install -y tilix thunar budgie-desktop budgie-* slick-greeter xorg sudo || { echo "Error al instalar Budgie Desktop y paquetes relacionados"; exit 1; }


# ----------------------------------------
# INSTALLATION OF ADDITIONAL PACKAGES
# ----------------------------------------

# System utilities
sudo apt-get install -y synaptic apt-xapian-index linux-headers-$(uname -r) build-essential make automake nala cmake autoconf git npm wget libgcr-3-dev appstream-util
sudo apt-get install -y acpi acpitool acpi-support rename fancontrol firmware-linux-free hardinfo hwdata hwinfo irqbalance iucode-tool laptop-detect lm-sensors lshw lsscsi smartmontools amd64-microcode
sudo apt-get install -y software-properties-gtk gnome-disk-utility gparted gufw menu-l10n ooo-thumbnailer


# Additional system utilities
sudo apt-get install -y htop neofetch cmatrix cava duf pipes-sh tty-clock

# Fonts
sudo apt-get install -y fonts-recommended fonts-ubuntu fonts-font-awesome fonts-terminus fonts-inter

# Define the URL of the Nerd Fonts repository
NERD_FONTS_REPO="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/"

# Specify the font you want to install (changing to "Hack")
FONT_NAME="Hack"
FONT_ZIP="${FONT_NAME}.zip"

# Create a temporary directory
TEMP_DIR=$(mktemp -d)

# Download the font
echo "Downloading the Nerd Font: $FONT_NAME..."
wget -q -O "$TEMP_DIR/$FONT_ZIP" "${NERD_FONTS_REPO}${FONT_ZIP}"

# Unzip the file
echo "Unzipping the font..."
unzip -q "$TEMP_DIR/$FONT_ZIP" -d "$TEMP_DIR"

# Check if .ttf files exist
if ls "$TEMP_DIR"/*.ttf 1> /dev/null 2>&1; then
    # Create the fonts directory if it doesn't exist
    FONT_DIR="/usr/share/fonts/truetype/nerd-fonts"
    sudo mkdir -p "$FONT_DIR"

    # Copy the fonts to the fonts folder
    echo "Installing the fonts..."
    sudo cp "$TEMP_DIR"/*.ttf "$FONT_DIR"

    # Update the font cache
    echo "Updating the font cache..."
    sudo fc-cache -f -v

    echo "The Nerd Font $FONT_NAME has been installed successfully."
else
    echo "No .ttf files found in the downloaded font package."
fi

# Clean up the temporary directory
rm -rf "$TEMP_DIR"



# Themes and Icons
sudo apt install -y papirus-icon-theme arc-theme dmz-cursor-theme adwaita-qt 

# Compression tools
sudo apt-get install -y arj bzip2 gzip lhasa liblhasa0 lzip lzma p7zip p7zip-full p7zip-rar sharutils rar unace unrar unrar-free tar unzip xz-utils zip

# ----------------------------------------
# INSTALLATION OF FIRMWARE AND CODECS
# ----------------------------------------

sudo apt-get install -y firmware-linux firmware-misc-nonfree ffmpeg gstreamer1.0-libav gstreamer1.0-plugins-ugly gstreamer1.0-plugins-bad gstreamer1.0-pulseaudio vorbis-tools flac default-jdk default-jre dconf-editor clang curl valac meson sudo aria2

# ----------------------------------------
# INSTALL PRINTER SCAN AND BLUETOOTH
# ----------------------------------------
sudo apt install -y cups system-config-printer simple-scan 
sudo apt install -y bluez bluetooth bluez-cups bluez-firmware bluez-tools btscanner pulseaudio-module-bluetooth

# ----------------------------------------
# VIDEO AND AUDIO COMPONENTS
# ----------------------------------------

sudo apt-get install -y xorg xserver-xorg bluez-alsa-utils libasound2-plugin-bluez radeontool radeontop ffmpegthumbnailer gstreamer1.0-gl gstreamer1.0-nice gstreamer1.0-plugins-bad gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly gstreamer1.0-pulseaudio gstreamer1.0-x libdvdnav4 libdvdread8 libfaac0 libmad0 libmp3lame0 libxvidcore4 vorbis-tools ueberzug

# ----------------------------------------
# FILE MANAGERS
# ----------------------------------------

sudo apt-get install -y thunar thunar-archive-plugin thunar-volman xarchiver

# ----------------------------------------
# PDF VIEWERS AND METADATA CLEANERS
# ----------------------------------------

sudo apt-get install -y evince pdfarranger
sudo apt-get install -y metadata-cleaner keepassxc onionshare clamtk

# ----------------------------------------
# IMAGE EDITING SOFTWARE
# ----------------------------------------

sudo apt-get install -y gimp gimp-data-extras gimp-gutenprint gimp-help-es eog converseen

# ----------------------------------------
# MULTIMEDIA PLAYERS
# ----------------------------------------

sudo apt-get install -y mpv vlc vlc-plugin-notify mediainfo-gui exfalso media-downloader converseen handbrake-gtk metadata-cleaner shotcut lollypop brasero libdvdread8 libdvdnav4 libxm4 lsb-release lsdvd cdrskin

# ----------------------------------------
# INTERNET APPLICATIONS
# ----------------------------------------

# Function for browser installation
install_browsers() {
    while true; do
        echo "Seleccione una opción:"
        echo "1) Instalar navegadores"
        echo "2) Desinstalar navegadores"
        echo "3) Salir"
        read -p "Opción [1-3]: " opcion_principal

        if [ "$opcion_principal" -eq 1 ]; then
            echo "Seleccione los navegadores que desea instalar (ingrese los números correspondientes, separados por espacios):"
            echo "1) Firefox"
            echo "2) LibreWolf"
            echo "3) Chromium"
            echo "4) Tor Browser"
            echo "5) Brave"
            echo "6) Ninguno"
            read -p "Opción [1-6]: " -a opciones

            # Instalar los navegadores seleccionados
            for opcion in "${opciones[@]}"; do
                case $opcion in
                    1) # Firefox
                        echo "Importando la clave de firma del repositorio de Mozilla..."
                        wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null

                        echo "Agregando el repositorio de Mozilla..."
                        echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | tee /etc/apt/sources.list.d/mozilla.list > /dev/null
                        apt update
                        apt install -y firefox || { echo "Error al instalar Firefox"; }

                        # Seleccionar el paquete de idioma
                        echo "Seleccione el paquete de idioma para Firefox:"
                        echo "1) Español (España) - firefox-l10n-es-es"
                        echo "2) Español (Latinoamérica) - firefox-l10n-es-MX"
                        echo "3) Ninguno"
                        read -p "Opción [1-3]: " opcion_idioma

                        case $opcion_idioma in
                            1) # Español (España)
                                echo "Instalando el paquete de idioma en español (España)..."
                                apt install -y firefox-l10n-es-es || { echo "Error al instalar el paquete de idioma en español (España)"; }
                                ;;
                            2) # Español (Latinoamérica)
                                echo "Instalando el paquete de idioma en español (Latinoamérica)..."
                                apt install -y firefox-l10n-es-MX || { echo "Error al instalar el paquete de idioma en español (Latinoamérica)"; }
                                ;;
                            3) # Ninguno
                                echo "No se instalará ningún paquete de idioma."
                                ;;
                            *) # Opción no válida
                                echo "Opción no válida: $opcion_idioma"
                                ;;
                        esac
                        ;;
                    2) # LibreWolf
                        echo "Agregando el repositorio de LibreWolf..."
                        apt update && apt install extrepo -y || { echo "Error al instalar extrepo"; exit 1; }
                        extrepo enable librewolf
                        apt update && apt install librewolf -y || { echo "Error al instalar LibreWolf"; exit 1; }
                        ;;
                    3) # Chromium
                        echo "Instalando Chromium..."
                        apt update
                        apt install -y chromium || { echo "Error al instalar Chromium"; exit 1; }
                        ;;
                    4) # Tor Browser
                        echo "Instalando Tor Browser..."
                        apt update
                        apt install -y apt-transport-https || { echo "Error al instalar apt-transport-https"; exit 1; }

                        echo "Creando el archivo tor.list..."
                        echo "deb [signed-by=/usr/share/keyrings/deb.torproject.org-keyring.gpg] https://deb.torproject.org/torproject.org bookworm main" | tee /etc/apt/sources.list.d/tor.list
                        echo "deb-src [signed-by=/usr/share/keyrings/deb.torproject.org-keyring.gpg] https://deb.torproject.org/torproject.org bookworm main" | tee -a /etc/apt/sources.list.d/tor.list

                        echo "Añadiendo la clave GPG..."
                        wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | tee /usr/share/keyrings/deb.torproject.org-keyring.gpg >/dev/null

                        echo "Actualizando la lista de paquetes..."
                        apt update

                        echo "Instalando tor y deb.torproject.org-keyring..."
                        apt install -y tor deb.torproject.org-keyring || { echo "Error al instalar Tor"; exit 1; }

                        echo "Instalando tor-browser..."
                        apt install -y torbrowser-launcher || { echo "Error al instalar tor-launcher"; exit 1; }
                        ;;
                    5) # Brave
                        echo "Agregando el repositorio de Brave..."
                        curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
                        echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list
                        apt update
                        apt install -y brave-browser || { echo "Error al instalar Brave"; exit 1; }
                        ;;
                    6) # Ninguno
                        echo "No se instalará ningún navegador."
                        ;;
                    *) # Opción no válida
                        echo "Opción no válida: $opcion"
                        ;;
                esac
            done

            echo "Instalación completada. ¡Disfruta de tus navegadores!"

        elif [ "$opcion_principal" -eq 2 ]; then
            echo "Seleccione los navegadores que desea desinstalar (ingrese los números correspondientes, separados por espacios):"
            echo "1) Firefox"
            echo "2) LibreWolf"
            echo "3) Chromium"
            echo "4) Tor Browser"
            echo "5) Brave"
            echo "6) Ninguno"
            read -p "Opción [1-6]: " -a opciones_desinstalacion

            # Desinstalar los navegadores seleccionados
            for opcion in "${opciones_desinstalacion[@]}"; do
                case $opcion in
                    1) # Firefox
                        apt remove --purge -y firefox || { echo "Error al desinstalar Firefox"; }
                        rm -f /etc/apt/sources.list.d/mozilla.list
                        rm -f /etc/apt/keyrings/packages.mozilla.org.asc
                        ;;
                    2) # LibreWolf
                        apt remove --purge -y librewolf || { echo "Error al desinstalar LibreWolf"; }
                        extrepo disable librewolf
                        ;;
                    3) # Chromium
                        apt remove --purge -y chromium || { echo "Error al desinstalar Chromium"; }
                        ;;
                    4) # Tor Browser
                        apt remove --purge -y tor torbrowser-launcher || { echo "Error al desinstalar Tor Browser"; }
                        rm -f /etc/apt/sources.list.d/tor.list
                        rm -f /usr/share/keyrings/deb.torproject.org-keyring.gpg
                        ;;
                    5) # Brave
                        apt remove --purge -y brave-browser || { echo "Error al desinstalar Brave"; }
                        rm -f /etc/apt/sources.list.d/brave-browser-release.list
                        rm -f /usr/share/keyrings/brave-browser-archive-keyring.gpg
                        ;;
                    6) # Ninguno
                        echo "No se desinstalará ningún navegador."
                        ;;
                    *) # Opción no válida
                        echo "Opción no válida: $opcion"
                        ;;
                esac
            done

            # Limpiar paquetes huérfanos
            echo "Limpiando paquetes huérfanos..."
            apt autoremove -y

            echo "Desinstalación completada."

        elif [ "$opcion_principal" -eq 3 ]; then
            echo "Saliendo del menú de navegadores."
            return  # Esto saldrá de la función, pero no del script completo
        else
            echo "Opción no válida: $opcion_principal"
        fi  # Cierre del bloque if
    done
}

# ----------------------------------------
# INSTALLATION OF LIBREOFFICE
# ----------------------------------------

sudo apt-get install -t bookworm-backports -y libreoffice libreoffice-help-es libreoffice-l10n-es libreoffice-style-elementary libreoffice-gnome

# ----------------------------------------
# DRIVER INSTALLATION
# ----------------------------------------

# Check if the system is a laptop
if lspci | grep -i "laptop"; then
    echo "This is a laptop. Installing battery driver..."
    
    # BATTERY DRIVER
    cd /tmp
    git clone https://github.com/AdnanHodzic/auto-cpufreq.git
    cd auto-cpufreq && sudo ./auto-cpufreq-installer
    cd ..
    rm -rf auto-cpufreq
    auto-cpufreq --install
else
    echo "This is not a laptop. Skipping battery driver installation."
fi

# ASUS NUMPAD DRIVER
sudo apt-get install -y libevdev2 python3-libevdev i2c-tools git
sudo modprobe i2c-dev
sudo i2cdetect -l
cd /tmp
git clone https://github.com/mohamed-badaoui/asus-touchpad-numpad-driver.git
cd asus-touchpad-numpad-driver
chmod +x install.sh
sudo ./install.sh

sudo sed -i 's|^#ExecStartPre=/bin/sleep 2|ExecStartPre=/bin/sleep 2|' /etc/systemd/system/asus_touchpad_numpad.service

cd ..
rm -rf asus-touchpad-numpad-driver

# ----------------------------------------
# ENABLE HARDWARE ACCELERATION
# ----------------------------------------

# Enable hardware acceleration for VLC
mkdir -p ~/.config/vlc
echo "hwdec=auto" > ~/.config/vlc/advanced-settings.conf

# Enable hardware acceleration for MPV
mkdir -p ~/.config/mpv
echo "hwdec=auto" > ~/.config/mpv/mpv.conf

# ----------------------------------------
# CALL THE BROWSER INSTALLATION FUNCTION
# ----------------------------------------
install_browsers

# ----------------------------------------
# END OF SCRIPT
# ----------------------------------------
echo "Script completado con éxito."

# ----------------------------------------
# INSTALLATION OF OTHER UTILITIES
# ----------------------------------------

# Install MKVToolNix
sudo wget -O /usr/share/keyrings/gpg-pub-moritzbunkus.gpg https://mkvtoolnix.download/gpg-pub-moritzbunkus.gpg
echo "deb [signed-by=/usr/share/keyrings/gpg-pub-moritzbunkus.gpg] https://mkvtoolnix.download/debian/ bookworm main" | sudo tee -a /etc/apt/sources.list.d/mkvtoolnix.download.list
sudo apt-get update
sudo apt-get install -y mkvtoolnix mkvtoolnix-gui

# Install Stremio
sudo mkdir -p /usr/share/desktop-directories/
wget http://ftp.es.debian.org/debian/pool/main/m/mpv/libmpv1_0.32.0-3_amd64.deb
sudo dpkg -i libmpv1_0.32.0-3_amd64.deb || sudo apt-get install -f -y
wget https://dl.strem.io/shell-linux/v4.4.165/Stremio_v4.4.165.deb
sudo dpkg -i Stremio_v4.4.165.deb || sudo apt-get install -f -y
rm -f libmpv1_0.32.0-3_amd64.deb Stremio_v4.4.165.deb

# Install SCRCPY
sudo apt-get install -y ffmpeg libsdl2-2.0-0 adb wget gcc git pkg-config meson ninja-build libsdl2-dev libavcodec-dev libavdevice-dev libavformat-dev libavutil-dev libswresample-dev libusb-1.0-0 libusb-1.0-0-dev
cd /tmp
git clone https://github.com/Genymobile/scrcpy
cd scrcpy
sudo rm -rf .git
./install_release.sh
cd ..
rm -rf scrcpy

# Install Bottom
cd /tmp
curl -LO https://github.com/ClementTsang/bottom/releases/download/0.9.6/bottom_0.9.6_amd64.deb
sudo dpkg -i bottom_0.9.6_amd64.deb
rm -f bottom_0.9.6_amd64.deb

# ----------------------------------------
# LIGHTDM CONFIGURATION
# ----------------------------------------

# Path to the lightdm.conf file
FILE="/etc/lightdm/lightdm.conf"

# Check if the file exists
if [ -f "$FILE" ]; then
    # Use sed to uncomment the line and change the value
    sudo sed -i 's/^#user-session=default/user-session=budgie-desktop/' "$FILE"
    echo "La línea ha sido actualizada a: user-session=budgie-desktop"
else
    echo "El archivo $FILE no existe."
fi

# ----------------------------------------
# ADD CURRENT USER TO SUDO GROUP
# ----------------------------------------

# Get the current username
USERNAME="$USER"

# Check if the user exists
if id "$USERNAME" &>/dev/null; then
    # Add the user to the sudo group
    sudo usermod -aG sudo "$USERNAME" || { echo "Error adding $USERNAME to sudo group"; exit 1; }
    echo "$USERNAME has been added to the sudo group."
else
    echo "User $USERNAME does not exist. Please create the user first."
    exit 1
fi

# ----------------------------------------
# OPTIONAL: SET PASSWORD FOR ROOT USER
# ----------------------------------------

# Uncomment the following lines if you want to set a password for the root user
# echo "Setting password for the root user..."
# sudo passwd root

echo "Script completed successfully."

# ----------------------------------------
# GRUB CONFIGURATION
# ----------------------------------------

# Modify GRUB_CMDLINE_LINUX_DEFAULT in /etc/default/grub
sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=".*"/GRUB_CMDLINE_LINUX_DEFAULT="quiet nowatchdog loglevel=3"/' /etc/default/grub

# Update GRUB to apply changes
sudo update-grub

echo "GRUB configuration updated."

# ----------------------------------------
# RECONFIGURE BLUETOOTH
# ----------------------------------------
sudo apt purge pulseaudio-module-bluetooth bluetooth "bluez-*" bluez -y
sudo rm -fr /var/lib/blueman
sudo rm -fr /var/lib/bluetooth/
sudo apt install bluez pulseaudio-module-bluetooth --install-suggests -y

# ----------------------------------------
# NETWORK MANAGER CONFIGURATION
# ----------------------------------------

sudo bash -c 'cat > /etc/NetworkManager/NetworkManager.conf' << EOF
[main]
plugins=ifupdown,keyfile

[ifupdown]
managed=true
EOF

sudo service NetworkManager restart

# ----------------------------------------
# REBOOT PROMPT
# ----------------------------------------

# Ask if the user wants to reboot
read -p "Do you want to reboot the system now? (y/n): " response
if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "Rebooting the system..."
    sudo reboot
else
    echo "Installation complete. Please reboot the system later to apply changes."
fi
