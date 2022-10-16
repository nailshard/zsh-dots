#!/bin/zsh

if [[ ! -e $HOME/.zshrc ]]; then
	[[ -f $HOME/.config/zsh/zshrc ]] && ln -s $HOME/.config/zsh/zshrc $HOME/.zshrc
fi
