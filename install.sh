apt update
apt upgrade -y

apt install snapd eza tmux git curl openssh-server ripgrep fd-find

curl -sS https://webinstall.dev/curlie | bash

snap install httpie
snap install kubectl --classic
snap install helm --classic
snap install gh
snap install doctl --classic
snap install google-cloud-cli --classic

snap connect doctl:ssh-keys :ssh-keys
snap connect doctl:kube-config 
