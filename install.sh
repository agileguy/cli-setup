#!/bin/bash
sudo apt install cbonsai btop ncdu bat unzip ffmpeg cmus zoxide eza tmux git curl ripgrep fd-find nodejs npm asciinema -y

sudo snap install httpie
sudo snap install kubectl --classic
sudo snap install helm --classic
sudo snap install gh
sudo snap install doctl
sudo snap install google-cloud-cli --classic
sudo snap install k9s --devmode
sudo snap install glances --classic
sudo snap install nvim --classic

sudo snap connect doctl:ssh-keys :ssh-keys
sudo snap connect doctl:kube-config 
curl -LSfs https://raw.githubusercontent.com/cantino/mcfly/master/ci/install.sh | sudo sh -s -- --git cantino/mcfly
curl -sS https://webinstall.dev/curlie | bash
curl -fsSL https://claude.ai/install.sh | bash
curl -sS https://raw.githubusercontent.com/agileguy/cli-setup/refs/heads/main/xplr-setup/xplr-setup.sh | bash

curl -o ~/.bashrc https://raw.githubusercontent.com/agileguy/cli-setup/refs/heads/main/.bashrc
git clone https://github.com/agileguy/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim

curl -o ~/.tmux.conf https://raw.githubusercontent.com/agileguy/cli-setup/refs/heads/main/tmux.conf
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

git clone https://github.com/magicmonty/bash-git-prompt.git ~/.bash-git-prompt --depth=1

source ~/.bashrc


