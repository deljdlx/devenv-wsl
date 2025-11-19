#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

echoRed()    { printf "\033[0;31m%s\033[0m\n" "$*"; }
echoGreen()  { printf "\033[0;32m%s\033[0m\n" "$*"; }
echoYellow() { printf "\033[0;33m%s\033[0m\n" "$*"; }
echoCyan()   { printf "\033[0;36m%s\033[0m\n" "$*"; }
trap 'echoRed "❌ Erreur à la ligne $LINENO"; exit 1' ERR

echoCyan "====================================================="
echoCyan " Provisioning du shell WSL (Debian 13 / Trixie)"
echoCyan "====================================================="

export DEBIAN_FRONTEND=noninteractive

echoGreen "====================================================="
echoGreen "Mise à jour des paquets APT"
echoGreen "====================================================="
sudo apt-get update -y



echoGreen "====================================================="
echoGreen "Install outils système de base"
echoGreen "====================================================="
sudo apt-get install -y --no-install-recommends \
  ca-certificates apt-transport-https lsb-release gnupg curl wget \
  vim nano less jq yq unzip zip tree file man-db bash-completion \
  lsof procps psmisc htop rsync ripgrep fd-find locate inotify-tools \
  ncdu openssh-client telnet \
  make gpg



echoGreen "====================================================="
echoGreen "Install Gum"
echoGreen "====================================================="

# gum : tente via apt, sinon fallback GitHub
if ! command -v gum >/dev/null 2>&1; then
  if ! sudo apt-get install -y --no-install-recommends gum 2>/dev/null; then
    tmpd="$(mktemp -d)"
    curl -fsSL -o "$tmpd/gum.tar.gz" "https://github.com/charmbracelet/gum/releases/latest/download/gum_$(uname -s)_$(uname -m).tar.gz" || true
    if [ -s "$tmpd/gum.tar.gz" ]; then
      tar -xzf "$tmpd/gum.tar.gz" -f "$tmpd/gum.tar.gz" -C "$tmpd" 2>/dev/null || true
      # certains tarball contiennent le binaire à la racine
      [ -f "$tmpd/gum" ] && sudo install -m 0755 "$tmpd/gum" /usr/local/bin/gum || true
    fi
    rm -rf "$tmpd"
  fi
fi


PHP_VERSIONS=(8.4 8.3 7.4 7.3 7.1)
echoGreen "====================================================="
echoGreen "Install install PHP versions: ${PHP_VERSIONS[*]}"
echoGreen "====================================================="

# 1) Récupérer la clé GPG et la stocker comme keyring dédié
sudo curl -fsSL https://packages.sury.org/php/apt.gpg \
  | sudo gpg --dearmor -o /usr/share/keyrings/deb.sury.org-php.gpg

# 2) Déclarer le dépôt avec signed-by
echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" \
  | sudo tee /etc/apt/sources.list.d/deb.sury.org-php.list

# 3) Mettre à jour
sudo apt update -y

# =======================================================

PHP_MODULES=(
  cli
  common
  fpm
  mysql
  xml
  curl
  mbstring
  zip
  bcmath
  intl
  gd
  imagick
  dev
  soap
  opcache
  sqlite3
)

for v in "${PHP_VERSIONS[@]}"; do
  echo ">>> Installation PHP ${v}"

  pkgs=("php${v}")  # paquet principal (meta)

  # Construire la liste des paquets à partir des modules
  for m in "${PHP_MODULES[@]}"; do
    pkgs+=("php${v}-${m}")
  done

  # Installation
  sudo apt-get install -y --no-install-recommends "${pkgs[@]}"

  # Alias propre
  # (alias php8.4=/usr/bin/php8.4, alias php7.4=/usr/bin/php7.4, etc.)
  echo "alias php${v}=/usr/bin/php${v}" >> "$HOME/.bashrc"
done



if command -v update-alternatives >/dev/null 2>&1; then
  sudo update-alternatives --set php /usr/bin/php8.4 || true
fi


if ! command -v composer >/dev/null 2>&1; then
  curl -fsSL https://getcomposer.org/installer | php
  sudo mv composer.phar /usr/local/bin/composer
  sudo chmod +x /usr/local/bin/composer
fi

# install psysh globaly
if ! command -v psysh >/dev/null 2>&1; then
  wget https://psysh.org/psysh
  chmod +x psysh
  sudo mv psysh /usr/local/bin/psysh
fi

echoGreen "====================================================="
echoGreen "Install outils système & réseau (diagnostic)"
echoGreen "====================================================="

sudo apt-get install -y --no-install-recommends \
  iproute2 iputils-ping net-tools bind9-dnsutils traceroute mtr-tiny fping \
  socat netcat-openbsd openssl \
  git vim nano less jq yq unzip zip tree file man-db bash-completion \
  telnet \
  tcpdump


echoGreen "====================================================="
echoGreen "Install dev tools"
echoGreen "====================================================="
sudo apt-get install -y --no-install-recommends \
  git \
  ncdu mariadb-client


# install eza
echoGreen "====================================================="
echoGreen "Install eza (exa)"
echoGreen "====================================================="

if ! command -v eza >/dev/null 2>&1; then
  sudo mkdir -p /etc/apt/keyrings
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
  sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
  sudo apt update
  sudo apt install -y eza

  # add alias ls=eza
  echo 'alias ls=eza' >> "$HOME/.bashrc"
  echo 'alias ll="eza -al"' >> "$HOME/.bashrc"
fi

# alias fd -> fdfind (Debian)
if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
  echo 'alias fd=fdfind' >> "$HOME/.bashrc"
fi




echoGreen "====================================================="
echoGreen "fzf + bat(batcat)"
echoGreen "====================================================="
sudo apt-get install -y --no-install-recommends fzf bat || true
if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
  echo 'alias bat=batcat' >> "$HOME/.bashrc"
fi

echoGreen "====================================================="
echoGreen "Qualité shell: shellcheck + shfmt"
echoGreen "====================================================="
sudo apt-get install -y --no-install-recommends shellcheck shfmt

echoGreen "====================================================="
echoGreen "Outils build pour Node (node-gyp)"
echoGreen "====================================================="
sudo apt-get install -y --no-install-recommends build-essential python3

echoGreen "====================================================="
echoGreen "Install Node.js via n (stable)"
echoGreen "====================================================="

if ! command -v node >/dev/null 2>&1; then
  sudo apt-get install -y --no-install-recommends nodejs npm
fi
sudo npm -g install n
sudo -E n stable
if ! grep -q '/usr/local/bin' <<<"$PATH"; then
  echo 'export PATH="/usr/local/bin:$PATH"' >> "$HOME/.bashrc"
fi
hash -r

echoGreen "====================================================="
echoGreen "Groupe docker (si présent côté WSL)"
echoGreen "====================================================="
if getent group docker >/dev/null 2>&1; then
  sudo usermod -aG docker "$USER" || true
fi

echoGreen "====================================================="
echoGreen "Création dossier de travail __dev"
mkdir -p "$HOME/.ssh" "$HOME/__dev"
echoGreen "====================================================="



echoCyan "====================================================="
echoCyan " Configuration git"
echoCyan "====================================================="

if ! git config --global user.name >/dev/null 2>&1; then
  git_username=$(gum input --placeholder "Nom Git (ex: Foo Bar)" --prompt "👤  Votre nom Git : ")
  git config --global user.name "$git_username"
fi

if ! git config --global user.email >/dev/null 2>&1; then
  git_email=$(gum input --placeholder "email@exemple.com" --prompt "📧  Votre email Git : ")
  git config --global user.email "$git_email"
fi

git config --global init.defaultBranch main

echoCyan "====================================================="
echoCyan " SSH keys (~/.ssh)"
echoCyan "====================================================="

if [ ! -f "$HOME/.ssh/id_rsa" ] && [ ! -f "$HOME/.ssh/id_ed25519" ]; then
  echoYellow "Aucune clé SSH trouvée."
  if gum confirm "🔑  Générer une nouvelle clé SSH (ed25519) ?" ; then
    ssh_email=$(gum input --placeholder "email@exemple.com" --prompt "📧  Email pour la clé : ")
    ssh-keygen -t ed25519 -C "$ssh_email" -N "" -f "$HOME/.ssh/id_ed25519"
    echoGreen "✅ Clé SSH générée avec succès."
    echo
    gum style --foreground 212 "Voici votre clé publique :"
    echo
    gum style --foreground 36 "$(cat "$HOME/.ssh/id_ed25519.pub")"
    echo
  else
    gum style --foreground 244 "⏩  Clé SSH non générée (tu pourras le faire plus tard)."
  fi
else
  gum style --foreground 82 "✅ Clé SSH déjà présente."
fi

echoCyan "====================================================="
echoCyan " Pensez à enregistrer votre clé SSH sur GitHub"
echoCyan "====================================================="

# Afficher la clé publique si elle existe
if [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
  echo
  gum style --foreground 36 "$(cat "$HOME/.ssh/id_ed25519.pub")"
  echo
elif [ -f "$HOME/.ssh/id_rsa.pub" ]; then
  echo
  gum style --foreground 36 "$(cat "$HOME/.ssh/id_rsa.pub")"
  echo
fi

echoCyan "====================================================="


echo
echoGreen "✅ Installation terminée — environnent Debian 13 prêt."
echo -n "node: "; node -v 2>/dev/null || echo "non installé"
echo -n "npm : "; npm -v 2>/dev/null || echo "non installé"
echo -n "php : "; php -v 2>/dev/null | head -n1 || echo "non installé"
echo

# cleanup
sudo apt-get clean
sudo rm -rf /tmp/*
