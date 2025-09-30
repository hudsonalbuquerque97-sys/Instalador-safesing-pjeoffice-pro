#!/bin/bash
# ================================================================
#  Script único: Instala SafeSign (Token), cria atalhos do PJe
#  e adiciona atalho do TokenAdmin na Área de Trabalho do usuário real
# ================================================================
# Uso:
#   sudo ./instala_safesign_pje_com_tokenadmin.sh
# ================================================================

set -e   # encerra em caso de erro

# Mensagem a ser exibida
MSG="
Este script irá instalar:

  • SafeSign / TokenAdmin
  • Dependências de smartcard
  • PJe Office Pro
  • Atalhos na Área de Trabalho e Menu

Deseja prosseguir?
"

if ! whiptail --title "Instalador SafeSign + PJe" --yesno "$MSG" 20 70 ; then
    echo "Instalação cancelada."
    exit 0
fi

echo "Prosseguindo com a instalação..."

# === Variáveis principais para separar ROOT do usuário real ===
REAL_USER=${SUDO_USER:-$USER}
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

echo "Executando como root, mas instalando atalhos para: $REAL_USER ($REAL_HOME)"
echo

# ----------------------------------------------------------------
#  BLOCO 1 – Instalação do SafeSign
# ----------------------------------------------------------------
GRUPO="scard"

echo "==> Criando grupo $GRUPO (se não existir)..."
if ! getent group "$GRUPO" >/dev/null; then
    addgroup "$GRUPO"
else
    echo "Grupo $GRUPO já existe."
fi

echo "==> Adicionando usuário $REAL_USER ao grupo $GRUPO..."
adduser "$REAL_USER" "$GRUPO"

echo "==> Instalando dependências gerais..."
apt update
apt install -y \
    libengine-pkcs11-openssl libp11-3 libpcsc-perl libccid pcsc-tools \
    libasedrive-usb opensc openssl \
    pcscd libc6 libgcc-s1 libgdbm-compat4 libglib2.0-0 libpcsclite1 libssl3 libstdc++6

echo "==> Baixando pacotes antigos..."
mkdir -p /tmp/token_debs && cd /tmp/token_debs
wget -c http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1-1ubuntu2.1~18.04.23_amd64.deb
wget -c http://archive.ubuntu.com/ubuntu/pool/universe/w/wxwidgets3.0/libwxbase3.0-0v5_3.0.5.1+dfsg-4_amd64.deb
wget -c http://archive.ubuntu.com/ubuntu/pool/main/g/gdk-pixbuf-xlib/libgdk-pixbuf-xlib-2.0-0_2.40.2-2build4_amd64.deb
wget -c http://archive.ubuntu.com/ubuntu/pool/universe/g/gdk-pixbuf-xlib/libgdk-pixbuf2.0-0_2.40.2-2build4_amd64.deb
wget -c http://archive.ubuntu.com/ubuntu/pool/main/t/tiff/libtiff5_4.3.0-6_amd64.deb
wget -c http://archive.ubuntu.com/ubuntu/pool/universe/w/wxwidgets3.0/libwxgtk3.0-gtk3-0v5_3.0.5.1+dfsg-4_amd64.deb

echo "==> Instalando pacotes antigos..."
dpkg -i *.deb || apt -f install -y

echo "==> Baixando e instalando SafeSign..."
cd /tmp
wget -c https://safesign.gdamericadosul.com.br/content/SafeSign_IC_Standard_Linux_ub2204_3.8.0.0_AET.000.zip -O safesign.zip
unzip -o safesign.zip -d safesign_pkg
cd safesign_pkg
SAFE_DEB=$(ls *.deb | head -n1)
[ -n "$SAFE_DEB" ] && dpkg -i "$SAFE_DEB" || echo "!! Nenhum .deb encontrado no zip"
apt -f install -y

echo "==> Habilitando serviço pcscd..."
systemctl enable pcscd
systemctl start pcscd

echo "==== Instalação do SafeSign concluída ===="
read -p "Pressione Enter para instalar o PJe e criar atalhos..."

# ----------------------------------------------------------------
#  BLOCO 2 – PJe Office Pro
# ----------------------------------------------------------------
PJE_URL="https://pje-office.pje.jus.br/pro/pjeoffice-pro-v2.5.16u-linux_x64.zip"
DEST_DIR="$REAL_HOME/.local/share/pjeoffice-pro"

sudo -u "$REAL_USER" mkdir -p "$DEST_DIR"
echo "==> Baixando PJe Office Pro..."
wget -c "$PJE_URL" -O /tmp/pjeoffice-pro.zip
sudo -u "$REAL_USER" unzip -o /tmp/pjeoffice-pro.zip -d "$DEST_DIR"

PJE_SH=$(find "$DEST_DIR" -type f -iname "pjeoffice-pro.sh" | head -n 1)
chmod +x "$PJE_SH"

ICON_URL="https://oabsc.s3.sa-east-1.amazonaws.com/images/201907301559070.jpg"
ICON_FILE="$DEST_DIR/pje-office.png"
sudo -u "$REAL_USER" wget -c "$ICON_URL" -O "$ICON_FILE"

DESKTOP_DIR=$(sudo -u "$REAL_USER" xdg-user-dir DESKTOP 2>/dev/null || echo "$REAL_HOME/Desktop")
sudo -u "$REAL_USER" mkdir -p "$DESKTOP_DIR"
DESKTOP_FILE="$DESKTOP_DIR/pjeoffice-pro.desktop"

cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=PJe Office Pro
Comment=Carregador de Certificados
Exec=$PJE_SH
Icon=$ICON_FILE
Categories=Office;
StartupNotify=false
Terminal=false
EOF
chown "$REAL_USER":"$REAL_USER" "$DESKTOP_FILE"
chmod +x "$DESKTOP_FILE"

# menu do usuário
MENU_DIR="$REAL_HOME/.local/share/applications"
sudo -u "$REAL_USER" mkdir -p "$MENU_DIR"
cp "$DESKTOP_FILE" "$MENU_DIR/"
command -v update-desktop-database >/dev/null && update-desktop-database "$MENU_DIR"

echo "==== PJe instalado para $REAL_USER ===="
read -p "Pressione Enter para criar o atalho do TokenAdmin..."

# ----------------------------------------------------------------
#  BLOCO 3 – Atalho TokenAdmin
# ----------------------------------------------------------------
TOKEN_DESKTOP="$DESKTOP_DIR/TokenAdmin.desktop"
cat > "$TOKEN_DESKTOP" <<EOF
[Desktop Entry]
Version=1.0
Name=TokenAdmin
Comment=Gerenciador SafeSign
Exec=tokenadmin
Icon=/usr/share/icons/hicolor/48x48/apps/tokenadmin.png
Terminal=false
Type=Application
Categories=Utility;
EOF
chown "$REAL_USER":"$REAL_USER" "$TOKEN_DESKTOP"
chmod +x "$TOKEN_DESKTOP"

rm -rf /tmp/token_debs /tmp/safesign_pkg /tmp/safesign.zip /tmp/pjeoffice-pro.zip

echo "==== Instalação concluída ===="
echo "- PJe Office Pro e TokenAdmin disponíveis em $REAL_HOME/Desktop e no menu de aplicativos."
echo "- Faça logout/login para ativar o grupo $GRUPO."
