apt update
apt upgrade -y

apt install snapd eza tmux git curl openssh-server ripgrep fd-find

curl -sS https://webinstall.dev/curlie | bash
curl -LSfs https://raw.githubusercontent.com/cantino/mcfly/master/ci/install.sh | sh -s -- --git cantino/mcfly

snap install httpie
snap install kubectl --classic
snap install helm --classic
snap install gh
snap install doctl --classic
snap install google-cloud-cli --classic

snap connect doctl:ssh-keys :ssh-keys
snap connect doctl:kube-config 

curl -o ~/.config/tmux/tmux.conf https://raw.githubusercontent.com/agileguy/cli-setup/refs/heads/main/tmux.conf
curl -o ~/.bashrc https://raw.githubusercontent.com/agileguy/cli-setup/refs/heads/main/.bashrc

source ~/.bashrc
