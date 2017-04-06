#!/bin/bash

DOT_FILES=(.zshrc)

for file in ${DOT_FILES[@]}
do
    ln -sf $HOME/dotfiles/$file $HOME/$file
done

