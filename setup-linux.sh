#!/usr/bin/env bash

# Install Ansible
if command -v apt &>/dev/null; then
  sudo apt update && sudo apt install -y ansible
elif command -v dnf &>/dev/null; then
  sudo dnf install -y ansible
elif command -v pacman &>/dev/null; then
  sudo pacman -Sy --noconfirm ansible
else
  echo "Unsupported package manager. Install Ansible manually and re-run this script."
  exit 1
fi

# Install required Ansible collections
ansible-galaxy collection install -r requirements.yaml

# Run the playbook
ansible-playbook -i localhost, main.yaml --ask-become-pass
