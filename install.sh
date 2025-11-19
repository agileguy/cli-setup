#!/bin/bash
apt install eza tmux git curl ripgrep fd-find -y

snap install httpie
snap install kubectl --classic
snap install helm --classic
snap install gh
snap install doctl
snap install google-cloud-cli --classic

snap connect doctl:ssh-keys :ssh-keys
snap connect doctl:kube-config 

curl -LSfs https://raw.githubusercontent.com/cantino/mcfly/master/ci/install.sh | sh -s -- --git cantino/mcfly
curl -sS https://webinstall.dev/curlie | bash

curl -o ~/.tmux.conf https://raw.githubusercontent.com/agileguy/cli-setup/refs/heads/main/.tmux.conf
curl -o ~/.bashrc https://raw.githubusercontent.com/agileguy/cli-setup/refs/heads/main/.bashrc

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

source ~/.bashrc


