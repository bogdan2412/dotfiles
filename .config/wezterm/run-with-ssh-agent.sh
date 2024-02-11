#!/bin/sh

set -eu

find_sockets() {
  if [ "${XDG_RUNTIME_DIR-}" != "" ]; then
    CANDIDATE="${XDG_RUNTIME_DIR}/keyring/ssh"
    if [ -S "$CANDIDATE" ]; then
      echo "$CANDIDATE";
    fi
  fi
  if [ -x "$(which launchctl 2>&1)" ]; then 
    CANDIDATE=$(launchctl getenv SSH_AUTH_SOCK 2>/dev/null)
    if [ -S "$CANDIDATE" ]; then
      echo "$CANDIDATE";
    fi
  fi
  find -L /tmp "${TMPDIR-}" -maxdepth 1 -uid "$(id -u)" -type d -name "ssh-*" 2>/dev/null | while read -r DIR; do
    find "$DIR" -type s -name "agent.*" 2>/dev/null
  done
}

test_socket() {
  if ! [ -x "$(which ssh-add 2>&1)" ]; then return 1; fi

  if [ "${1-}" != "" ]; then export SSH_AUTH_SOCK="$1"; fi

  if [ "${SSH_AUTH_SOCK-}" = "" ]; then return 2; fi

  if ! [ -S "$SSH_AUTH_SOCK" ]; then return 3; fi

  ssh-add -l >/dev/null 2>&1
  RET_CODE=$?
  if [ $RET_CODE = 2 ]; then
    rm -f "$SSH_AUTH_SOCK"
    unset SSH_AUTH_SOCK
    return 4
  elif [ $RET_CODE != 0 ]; then
    unset SSH_AUTH_SOCK
    return 5
  else
    return 0
  fi
}

find_agent() {
  if test_socket; then return 0; fi

  for socket in $(find_sockets); do
    if test_socket "$socket"; then return 0; fi
  done
}

find_agent
if [ "$#" = 0 ]; then
  exec -a "-$(basename "$SHELL")" "$SHELL"
fi
exec "${@}"
