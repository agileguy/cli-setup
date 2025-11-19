#!/bin/bash
sudo apt install eza tmux git curl ripgrep fd-find -y

sudo snap install httpie
sudo snap install kubectl --classic
sudo snap install helm --classic
sudo snap install gh
sudo snap install doctl
sudo snap install google-cloud-cli --classic
snap install k9s --devmode

sudo snap connect doctl:ssh-keys :ssh-keys
sudo snap connect doctl:kube-config 

curl -LSfs https://raw.githubusercontent.com/cantino/mcfly/master/ci/install.sh | sudo sh -s -- --git cantino/mcfly
curl -sS https://webinstall.dev/curlie | bash

curl -o ~/.tmux.conf https://raw.githubusercontent.com/agileguy/cli-setup/refs/heads/main/.tmux.conf
curl -o ~/.bashrc https://raw.githubusercontent.com/agileguy/cli-setup/refs/heads/main/.bashrc

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
git clone https://github.com/magicmonty/bash-git-prompt.git ~/.bash-git-prompt --depth=1

source ~/.bashrc


