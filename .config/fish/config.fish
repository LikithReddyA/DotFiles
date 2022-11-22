if status is-interactive
    # Commands to run in interactive sessions can go here
end

### EXPORT ###
set fish_greeting                                 # Supresses fish's intro message
set TERM "xterm-256color"                         # Sets the terminal type
set EDITOR "alacritty -e nvim"                    # $EDITOR use Neovim in terminal

# Aliases
alias vim='nvim'

### SETTING THE STARSHIP PROMPT ###
starship init fish | source

### Neofetch
neofetch
