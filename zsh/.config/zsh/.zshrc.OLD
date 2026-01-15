# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
#if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
#fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
#zinit light zsh-users/zsh-completions
#zinit light zsh-users/zsh-autosuggestions

# Completion styling
zinit pack="bgn-binary+keys" for fzf
zinit light Aloxaf/fzf-tab
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Provides enhancd, lsd, bat, and eza.
# zinit light b4b4r07/enhancd
# zinit light Peltoche/lsd
zinit wait"1" lucid from"gh-r" as"program" for \
    sbin"**/eza*" ver"v0.23.4" if'[[ $OSTYPE != darwin* ]]' eza-community/eza \
    sbin"fzf" ver"0.67.0" atload'eval "$(fzf --zsh)"' junegunn/fzf \
    sbin"**/delta*" ver"0.18.2" atload"alias diff='delta -ns'" dandavison/delta \
    sbin"**/fd*" ver"v10.2.0" cp"**/fd.1 -> $ZPFX/man/man1" completions @sharkdp/fd

# Install fzf
zinit ice wait lucid from"gh-r" as"null" sbin"fzf" \
    atclone"./fzf --zsh > init.zsh" \
    atpull"%atclone" \
    src"init.zsh" \
    atload"source ${CONFIG_DIR}/fzf/config.zsh"
zinit light junegunn/fzf

zinit wait lucid for \
  atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
     zdharma/fast-syntax-highlighting \
  blockf \
     zsh-users/zsh-completions \
  atload"!_zsh_autosuggest_start" \
     zsh-users/zsh-autosuggestions

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
#zinit snippet OMZP::archlinux
#zinit snippet OMZP::aws
#zinit snippet OMZP::kubectl
#zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# Prompt
# eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/zen.toml)"
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

zle_highlight+=(paste:none)

# Setup history params
HISTSIZE=5000
#HISTFILE=~/.zsh_history
HISTFILE=~/.local/share/zsh/history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory  # Append to the history file
setopt sharehistory  # Share history across terminals
setopt hist_ignore_space  # Ignore commands that start with a space
setopt hist_ignore_all_dups  # Ignore duplicate commands
setopt hist_save_no_dups  # Don't save duplicate commands
setopt hist_ignore_dups  # Ignore duplicate entries
setopt hist_find_no_dups  # Ignore duplicate entries
setopt hist_reduce_blanks  # Remove superfluous blanks

# Shell integrations
#eval "$($HOME/.fzf/bin/fzf --zsh)"
# eval "$(fzf --zsh)"

# Zoxide integration
eval "$(zoxide init --cmd cd zsh)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# -------------------------------------------
# 👉 CUSTOM SOURCES
# -------------------------------------------
source "$ZDOTDIR/functions.zsh"
source "$ZDOTDIR/aliases.zsh"
source "$ZDOTDIR/hack.zsh"

# eza (better `ls`)
# ------------------------------------------------------------------------------
# if type eza &>/dev/null; then
#   alias l="eza --icons=always"
#   alias la="eza -a --icons=always"
#   alias lh="eza -ad --icons=always .*"
#   alias ll="eza -lg --icons=always"
#   alias lla="eza -lag --icons=always"
#   alias llh="eza -lagd --icons=always .*"
#   alias ls="eza --icons=always"
#   alias lt2="eza -lTg --level=2 --icons=always"
#   alias lt3="eza -lTg --level=3 --icons=always"
#   alias lt4="eza -lTg --level=4 --icons=always"
#   alias lt="eza -lTg --icons=always"
#   alias lta2="eza -lTag --level=2 --icons=always"
#   alias lta3="eza -lTag --level=3 --icons=always"
#   alias lta4="eza -lTag --level=4 --icons=always"
#   alias lta="eza -lTag --icons=always"
# else
#   echo ERROR: eza could not be found. Skip setting up eza aliases.
# fi


# Simplified PATH management
path_add() { 
  [[ -d "$1" && ":$PATH:" != *":$1:"* ]] && PATH="$1:$PATH"
}

# Essential paths only
essential_paths=(
  "$HOME/.local/bin"
  "$HOME/bin"
  "$HOME/go/bin"
  "/usr/local/go/bin"
  "$HOME/dotfiles/localbin"
  "/opt/nvim-linux-x86_64/bin"
  "$HOME/.fzf/bin"
)

for p in $essential_paths; do path_add $p; done

microfetch

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
