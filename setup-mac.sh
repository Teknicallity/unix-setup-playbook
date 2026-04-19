#!/usr/bin/env bash

# ---------------------------------------------------------------------------
# Profile selection
# Usage: ./setup-mac.sh [-p <profile>] [-y]
#   -p, --profile   personal | work | both  (or first letter: p, w, b)
#   -y, --yes       skip confirmation prompt
# Default profile: personal
# ---------------------------------------------------------------------------
PROFILE=""
AUTO_YES=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -y|--yes)       AUTO_YES=true; shift ;;
    -p|--profile)   PROFILE="$2"; shift 2 ;;
    *)              echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Expand first-letter shorthand
case "${PROFILE,,}" in
  w*) PROFILE=work ;;
  p*) PROFILE=personal ;;
  b*) PROFILE=both ;;
  "")
    if $AUTO_YES; then
      PROFILE=personal
    else
      echo "Select install profile:"
      echo "  1) personal (default)"
      echo "  2) work"
      echo "  3) both"
      read -rp "Choice [1]: " CHOICE
      case "${CHOICE:-1}" in
        1|p*) PROFILE=personal ;;
        2|w*) PROFILE=work ;;
        3|b*) PROFILE=both ;;
        *) echo "Invalid choice."; exit 1 ;;
      esac
      AUTO_YES=true
    fi
    ;;
  *) echo "Unknown profile '$PROFILE'. Use: personal, work, or both (or first letter)."; exit 1 ;;
esac

if ! $AUTO_YES; then
  read -rp "Install profile: '$PROFILE'. Continue? [Y/n]: " CONFIRM
  [[ "${CONFIRM:-Y}" =~ ^[Yy] ]] || { echo "Aborted."; exit 0; }
fi

# ---------------------------------------------------------------------------

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
ansible-playbook -i localhost, main.yaml --ask-become-pass -e profile="$PROFILE"
