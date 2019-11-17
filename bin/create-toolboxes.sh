#!/bin/bash

set -euo pipefail

toolbox create -c ocaml || true
toolbox run -c ocaml sudo dnf upgrade -y --refresh
toolbox run -c ocaml sudo dnf install -y emacs g++ libffi-devel opam openssl-devel vim zlib-devel zsh
toolbox run -c ocaml opam init --compiler=4.07.1 --no-setup

toolbox create -c python || true
toolbox run -c python sudo dnf upgrade -y --refresh
toolbox run -c python sudo dnf install -y emacs python3-beautifulsoup4 python3-html5lib vim zsh

toolbox create -c wine || true
toolbox run -c wine sudo dnf upgrade -y --refresh
toolbox run -c wine sudo dnf install -y emacs wine vim zsh

toolbox create -c media || true
toolbox run -c media sudo dnf upgrade -y --refresh
toolbox run -c media sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
toolbox run -c media sudo dnf install -y emacs ffmpeg plex-media-player vim youtube-dl zsh
