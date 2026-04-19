#!/usr/bin/env bash

# ---------------------------------------------------------------------------
# Profile selection
# Usage: ./setup-linux.sh [-p <profile>] [-y]
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
ansible-playbook -i localhost, main.yaml --ask-become-pass -e profile="$PROFILE"
