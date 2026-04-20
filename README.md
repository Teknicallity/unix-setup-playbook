
# Unix Setup Playbook

## Installation

### Mac

1. Complete initial macOS setup (create user account, connect to Wi-Fi, sign in to App Store)
2. Clone this repo and run the setup script:

   ```bash
   git clone https://github.com/Teknicallity/unix-setup-playbook.git && cd unix-setup-playbook
   bash setup-mac.sh
   ```

The script installs Xcode CLI tools, Homebrew, Ansible, the required collections, and runs the playbook.

> **Note:** The playbook is idempotent — re-running it will pull the latest dotfiles and install any new apps added to `config.yaml`.

### Linux

1. Clone this repo and run the setup script:

   ```bash
   git clone https://github.com/Teknicallity/unix-setup-playbook.git && cd unix-setup-playbook
   bash setup-linux.sh
   ```

The script detects your package manager (apt/dnf/pacman), installs Ansible, the required collections, and runs the playbook.

## App Drift Detection

### Mac Brew Audit

Run `brew-check-drift.sh` to get a list of Mac Apps on the system which are not in the list.

## To Add

- curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
- Then :PlugInstall in vim
- defaults write com.apple.dock autohide-time-modifier -float 0.5; killall Dock
- defaults write com.apple.dock autohide-delay -float 0.05; killall Dock
- defaults write com.apple.dock minimize-to-application -bool true && killall Dock
