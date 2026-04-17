#!/usr/bin/env bash
read -rs -p "Enter your Mac password for sudo: " SUDO_PASS
echo

xcode-select --install

# Wait for Xcode CLI tools before proceeding
until xcode-select -p &>/dev/null; do
  sleep 5
done

# Install Homebrew if not present - must NOT be run with sudo
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Apple Silicon: ensure /opt/homebrew is owned by the user
if [[ $(uname -m) == "arm64" ]]; then
  if [[ $(stat -f "%Su" /opt/homebrew) != "$(whoami)" ]]; then
    echo "Fixing /opt/homebrew ownership..."
    sudo chown -R "$(whoami)" /opt/homebrew
  fi
fi

# Install ansible via pipx (isolated environment)
brew install pipx
pipx install --include-deps ansible
pipx ensurepath
export PATH="$PATH:$HOME/.local/bin"

# Install required Ansible collections
ansible-galaxy collection install -r requirements.yaml

# Run the playbook
export SUDO_PASS

ansible-playbook -i hosts.yaml main.yaml
