# git status with a dirty flag
function __git_status_flag {
  git_status="$(git status 2> /dev/null)"
  remote_pattern="^# Your branch is (.*) of"
  diverge_pattern="# Your branch and (.*) have diverged"
  if [[ ! ${git_status} =~ "working directory clean" ]]; then
    state="⚡"
    spacer=" "
  fi

  if [[ ${git_status} =~ ${remote_pattern} ]]; then
    spacer=" "
    if [[ ${BASH_REMATCH[1]} == "ahead" ]]; then
      remote="↑"
    else
      remote="↓"
    fi
  fi

  if [[ ${git_status} =~ ${diverge_pattern} ]]; then
    remote="↕"
    spacer=" "
  fi

  echo "${state}${remote}${spacer}"
}

export PS1='[\[\e[0;32m\]\u@\h \[\e[0;34m\]\w\[\033[00m\]]\[\e[22;35m\]$(__git_ps1 " [\[\e[33m\]$(__git_status_flag)\[\e[35m\]%s] ")\[\033[00m\]\$ '

alias fix_permissions='sudo find . -executable -print0 | sudo xargs -0 chmod o+rx; sudo find . ! -executable -print0 | sudo xargs -0 chmod o+r'

_pip_completion()
{
    COMPREPLY=( $( COMP_WORDS="${COMP_WORDS[*]}" \
                   COMP_CWORD=$COMP_CWORD \
                   PIP_AUTO_COMPLETE=1 $1 ) )
}
complete -o default -F _pip_completion pip
