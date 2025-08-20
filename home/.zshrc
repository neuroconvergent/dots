# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# The following lines were added by compinstall

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' completions 1
zstyle ':completion:*' glob 1
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'
zstyle ':completion:*' max-errors 2
zstyle ':completion:*' menu select=1
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' substitute 1
zstyle ':completion:*' verbose false
zstyle :compinstall filename '/home/sundar/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
# End of lines configured by zsh-newuser-install
#
# init mode to enable sourcing due to zsh-vi mode
ZVM_INIT_MODE=sourcing

#Keybindings
#Force emacs mode
#bindkey -e
# ctrl-left and ctrl-right
bindkey "\e[1;5D" backward-word
bindkey "\e[1;5C" forward-word
# ctrl-bs and ctrl-del
bindkey "\e[3;5~" kill-word
bindkey "\C-_"    backward-kill-word
# del, home and end
bindkey "\e[3~" delete-char
bindkey "\e[H"  beginning-of-line
bindkey "\e[F"  end-of-line
# alt-bs
bindkey "\e\d"  undo
# Reverse search
bindkey '^R' history-incremental-search-backward

#Environments
export VISUAL=nvim
export EDITOR=nvim
export VISUAL EDITOR=nvim
export PATH="$HOME/PATH:$PATH"
export PATH="$HOME/.emacs.d/bin:$PATH"

alias dotfiles="/usr/bin/git --git-dir=$HOME/arch_dotfiles/ --work-tree=$HOME"
alias hyprland-config="/usr/bin/git --git-dir=$HOME/hyprland-config --work-tree=$HOME"
alias pacfind="pacman -Slq | fzf --multi --preview 'pacman -Si {1}' | xargs -ro sudo pacman -S"
alias parufind="paru -Slq | fzf --multi --preview 'paru -Si {1}' | xargs -ro paru -S"
alias calibre-launch='QT_QPA_PLATFORM="xcb" calibre' 
alias nvidia-env='DRI_PRIME=pci-0000_01_00_0 __VK_LAYER_NV_optimus=NVIDIA_only __GLX_VENDOR_LIBRARY_NAME=nvidia'
alias davinciresolve='QT_QPA_PLATFORM=xcb DRI_PRIME=pci-0000_01_00_0 __VK_LAYER_NV_optimus=NVIDIA_only __GLX_VENDOR_LIBRARY_NAME=nvidia /opt/resolve/bin/resolve'
alias ls='exa'
alias ll='exa -la'
alias cat='bat'
alias lstree="exa -aR | grep ":$" | perl -pe 's/:$//;s/[^-][^\/]*\//    /g;s/^    (\S)/└── \1/;s/(^    |    (?= ))/│   /g;s/    (\S)/└── \1/'"
alias histfind="cat ~/.histfile| fzf | wl-copy"

export NEXTCLOUD_PHP_CONFIG=/etc/webapps/nextcloud/php.ini

setopt globdots

# install these plugins with pacman
eval $(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/theme.json)
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh
clear

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh



eval $(thefuck --alias)
# ruby gems configuration
export GEM_HOME="$HOME/gems"
export PATH="$HOME/gems/bin:$PATH"
export PATH=$PATH:$(ruby -e 'print Gem.user_dir')/bin

# Created by `pipx` on 2024-12-30 16:52:30
export PATH="$PATH:/home/sundar/.local/bin"

# zoxide
eval "$(zoxide init --cmd cd zsh)"

# yazi auto change directory
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
