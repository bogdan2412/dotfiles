# Path to your oh-my-zsh installation.
export ZSH=$HOME/.zsh/oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="agnoster"
if [[ -z "$WEZTERM_PANE" ]]; then
  DEFAULT_USER="bogdan2412"
fi

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM=$HOME/.zsh

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-syntax-highlighting)

# User configuration

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

fpath=(/usr/local/share/zsh-completions $fpath)

source $ZSH/oh-my-zsh.sh

unset HISTSIZE
unset SAVEHIST
setopt inc_append_history auto_cd extended_glob no_match notify
bindkey -e

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern root)
ZSH_HIGHLIGHT_PATTERNS+=('rm *' 'fg=white,bold,bg=red'
                         'sudo *' 'standout')

function fix_permissions() {
  sudo find . -executable -exec chmod o+rx {} + &&
  sudo find . ! -executable -exec chmod o+r {} +
}

function ec {
  emacsclient -c "$@" &
}

alias ccat='pygmentize -g'
alias ls='ls --color'

function git {
  if [[ "$1" == "log" ]]; then
    shift;
    command git log --ext-diff "$@"
  else
    command git "$@"
  fi
}

if which lsd >/dev/null 2>&1; then
  unalias ls
  function ls {
    if git rev-parse --git-dir >/dev/null 2>&1; then
      command lsd --git "${@}"
    else
      command lsd "${@}"
    fi
  }

  alias lt="ls -l --tree"
  alias lta="ls -la --tree"
fi

# Oh-my-zsh currently doesn't report OSC7 working directory and hostname over
# SSH, because it causes problems for Konsole users, but WezTerm behaves
# correctly.
if ! typeset -f omz_termsupport_cwd > /dev/null; then
  function omz_termsupport_cwd {
    local URL_HOST URL_PATH
    URL_HOST="$(omz_urlencode -P $HOST)" || return 1
    URL_PATH="$(omz_urlencode -P $PWD)" || return 1
    printf "\e]7;file://%s%s\e\\" "${URL_HOST}" "${URL_PATH}"
  }

  add-zsh-hook precmd omz_termsupport_cwd
fi

function tmux_user_var {
  if [[ -n "$TMUX" ]]; then
    printf "\ePtmux;\e\e]1337;SetUserVar=IS_TMUX=dHJ1ZQ==\e\e\\\\\e\\"
  else
    printf "\e]1337;SetUserVar=IS_TMUX=ZmFsc2U=\e\\"
  fi
}
PROMPT="$PROMPT"'%{$(tmux_user_var)%}'
