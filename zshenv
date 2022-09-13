#!/bin/zsh

[[ -f $HOME/.zshrc ]] || [[ $HOME/.config/zsh/zshrc ]] \
	&& ln -s $HOME/.config/zsh/zshrc $HOME/.zshrc
