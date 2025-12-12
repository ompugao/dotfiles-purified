#!/bin/bash
make install_tools
make install_skkjisho
make install_tpm
make install_systemd_sshagent

git clone https://github.com/ompugao/vim-bundle ~/.config/nvim
#$HOME/.local/share/mise/shims/nvim -c PlugInstall -c qall  #this does not work since neovim hangs claiming that no plugins installed
