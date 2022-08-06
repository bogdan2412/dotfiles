#!/bin/sh

set -euo pipefail

upgrade() {
  container=$1
  toolbox run -c "$container" sudo dnf upgrade --refresh -y
  toolbox run -c "$container" sudo dnf autoremove -y
  toolbox run -c "$container" sudo dnf clean all
}

upgrade ocaml &
upgrade media &
upgrade node &
upgrade freerdp &
upgrade python &
upgrade wine &
upgrade golang &

wait
