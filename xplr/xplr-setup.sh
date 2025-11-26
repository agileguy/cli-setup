platform="linux"  # or "macos"
# Download
wget -o ./xplr-$platform.tar.gz https://github.com/sayanarijit/xplr/releases/latest/download/xplr-$platform.tar.gz
# Extract
tar xzvf ./xplr-$platform.tar.gz
# Place in $PATH
sudo mv xplr /usr/local/bin/
rm ./xplr-$platform.tar.gz
curl -o ~/.config/xplr/init.lua https://raw.githubusercontent.com/agileguy/cli-setup/refs/heads/main/xplr/init.lua
