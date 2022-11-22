#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

export EDITOR="alacritty -e nvim"

### SETTING THE STARSHIP PROMPT ###
eval "$(starship init bash)"

neofetch
