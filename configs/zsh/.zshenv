#!/usr/bin/env zsh

[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# Secrets
#[ -f "$HOME/.env" ] && source "$HOME/.env"

# Set up relevant XDG base directories.
# Spec: https://specifications.freedesktop.org/basedir-spec/latest/index.html
# ------------------------------------------------------------------------------
#export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
#export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
#export XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}

# Make sure directories actually exist
#xdg_base_dirs=("$XDG_CACHE_HOME" "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME")
#for dir in "${xdg_base_dirs[@]}"; do
#  if [[ ! -d "$dir" ]]; then
#    mkdir -p "$dir"
#  fi
#done

# Set ZDOTDIR here. All other Zsh related configuration happens there.
# ------------------------------------------------------------------------------
export ZDOTDIR=${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}

# Set up default editor
# ------------------------------------------------------------------------------
#export EDITOR=nvim
#export VISUAL=nvim

# Locale settings
#export LANG="en_US.UTF-8" # Sets default locale for all categories
#export LC_ALL="en_US.UTF-8" # Overrides all other locale settings
#export LC_CTYPE="en_US.UTF-8" # Controls character classification and case conversion

# Add /usr/local/bin to the beginning of the PATH environment variable.
# This ensures that executables in /usr/local/bin are found before other directories in the PATH.
#export PATH="/usr/local/bin:$PATH"

# Set LDFLAGS environment variable for the linker to use the specified directories for library files.
# This is useful when building software that depends on non-standard library locations, like zlib and bzip2 in this case.
#export LDFLAGS="-L/usr/local/opt/zlib/lib -L/usr/local/opt/bzip2/lib"

# Set CPPFLAGS environment variable for the C/C++ preprocessor to use the specified directories for header files.
# This is useful when building software that depends on non-standard header locations, like zlib and bzip2 in this case.
#export CPPFLAGS="-I/usr/local/opt/zlib/include -I/usr/local/opt/bzip2/include"

# Hide computer name in terminal
export DEFAULT_USER="$(whoami)"
