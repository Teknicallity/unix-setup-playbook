
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
- defaults write com.apple.dock autohide-time-modifier -float 0.5; killall Dock
- defaults write com.apple.dock autohide-delay -float 0.05; killall Dock
