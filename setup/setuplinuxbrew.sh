#!/bin/bash
if [ ! -d $HOME/.linuxbrew ]; then
    git clone https://github.com/Homebrew/linuxbrew.git ~/.linuxbrew
fi

export PATH="$PATH:$HOME/.linuxbrew/bin"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$HOME/.linuxbrew/lib"
