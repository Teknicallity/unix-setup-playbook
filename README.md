
# Unix Setup Playbook

## Installation
### Mac
- Go through initial mac setup
- Run `bash pre-setup-mac.sh`
- Run `ansible-playbook -i localhost, main.yaml`

### Linux


## To Add


- curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
- Then :PlugInstall in vim
- change spacing: defaults -currentHost write -globalDomain NSStatusItemSpacing -int 8
- change highlight: defaults -currentHost write -globalDomain NSStatusItemSpacing -int 4
- Dock Changes:
    - keep smooth animation time, but remove delay:
        - `defaults write com.apple.dock autohide-delay -float 0; killall Dock`

    - instantly reveal:
        - `defaults write com.apple.dock autohide-time-modifier -int 0; killall Dock`

    - restore default behavior:
        - `defaults delete com.apple.dock autohide-delay; killall Dock`
