#!/usr/bin/env bash

xcode-select --install

# Wait for Xcode CLI tools before proceeding
until xcode-select -p &>/dev/null; do
  sleep 5
done

# Install Homebrew if not present - must NOT be run with sudo
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install ansible via pipx (isolated environment)
brew install pipx
pipx install --include-deps ansible
pipx ensurepath
export PATH="$PATH:$HOME/.local/bin"

# Install required Ansible collections
ansible-galaxy collection install -r requirements.yaml

# Run the playbook
ansible-playbook -i hosts.yaml --ask-become-pass main.yaml
