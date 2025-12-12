#!/bin/bash
make install_tools
make install_skkjisho
make install_tpm
make install_systemd_sshagent

git clone https://github.com/ompugao/vim-bundle ~/.config/nvim
nvim -c PlugInstall -c qall
