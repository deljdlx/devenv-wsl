#!/usr/bin/env bash
set -e

sudo apt-get update -y

sudo apt-get install -y --no-install-recommends \
  iproute2 iputils-ping net-tools dnsutils \
  traceroute socat netcat-openbsd curl wget openssl \
  git vim nano less jq yq unzip zip tree file man-db bash-completion \
  lsof procps psmisc htop rsync ripgrep fd-find locate inotify-tools \
  ca-certificates ncdu mariadb-client openssh-client

# install make
sudo apt-get install -y --no-install-recommends make
sudo apt-get install -y --no-install-recommends wget curl

# install nodejs and npm and n
echoGreen "Install NodeJS and npm"
sudo apt-get install -y --no-install-recommends \
  nodejs npm
sudo npm install -g n
sudo n stable


echoGreen "Install PHP 8.4 and extensions"
#install php 8.4 and composer
# add repository for php 8.4
sudo apt-get update
sudo apt-get -y install lsb-release ca-certificates curl apt-transport-https
sudo curl -sSLo /tmp/debsuryorg-archive-keyring.deb https://packages.sury.org/debsuryorg-archive-keyring.deb
sudo dpkg -i /tmp/debsuryorg-archive-keyring.deb
sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
sudo apt-get update -y

sudo apt-get install -y --no-install-recommends \
  php8.4 php8.4-cli php8.4-common php8.4-fpm php8.4-mysql php8.4-xml php8.4-curl php8.4-mbstring php8.4-zip php8.4-bcmath php8.4-intl php8.4-gd php8.4-imagick php8.4-dev php8.4-soap

curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer


echoGreen 'Add user to docker group'
sudo usermod -aG docker $USER

sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*
echo
echoGreen "✅ Installation terminée — outils de diagnostic prêts."
echo


mkdor -p ~/.ssh

if ! git config --global user.name > /dev/null; then
  read -rp "Enter your git user.name: " git_username
  git config --global user.name "$git_username"
fi
if ! git config --global user.email > /dev/null; then
  read -rp "Enter your git user.email: " git_email
  git config --global user.email "$git_email"
fi


