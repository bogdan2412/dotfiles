#!/bin/bash

set -euo pipefail

SOURCE_IMAGE=registry.fedoraproject.org/f31/fedora-toolbox:31
UPDATED_IMAGE=fedora-toolbox-$(date +%Y%m%d)

WORKING_CONTAINER=$(buildah from --cap-add CAP_SETFCAP "registry.fedoraproject.org/f31/fedora-toolbox:31")
buildah run "$WORKING_CONTAINER" -- bash -c "dnf upgrade --refresh -y && dnf autoremove -y && dnf clean all"
buildah commit "$WORKING_CONTAINER" "$UPDATED_IMAGE"

CREATE_ARGS="--image $UPDATED_IMAGE"

toolbox create $CREATE_ARGS -c ocaml || true
toolbox run -c ocaml sudo dnf upgrade --refresh -y
toolbox run -c ocaml sudo dnf install -y emacs g++ libffi-devel opam openssl-devel pcre-devel vim zlib-devel zsh
toolbox run -c ocaml sudo dnf autoremove -y
toolbox run -c ocaml sudo dnf clean all
toolbox run -c ocaml opam init --compiler=4.09.0 --no-setup

toolbox create $CREATE_ARGS -c python || true
toolbox run -c python sudo dnf upgrade --refresh -y
toolbox run -c python sudo dnf install -y emacs python3-beautifulsoup4 python3-html5lib vim zsh
toolbox run -c python sudo dnf autoremove -y
toolbox run -c python sudo dnf clean all

toolbox create $CREATE_ARGS -c wine || true
toolbox run -c wine sudo dnf upgrade --refresh -y
toolbox run -c wine sudo dnf install -y wine
toolbox run -c wine sudo dnf autoremove -y
toolbox run -c wine sudo dnf clean all

toolbox create $CREATE_ARGS -c media || true
toolbox run -c media sudo dnf upgrade --refresh -y
toolbox run -c media sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
toolbox run -c media sudo dnf install -y ffmpeg ImageMagick plex-media-player xorg-x11-drv-nvidia unrar youtube-dl zsh
toolbox run -c media sudo dnf autoremove -y
toolbox run -c media sudo dnf clean all

toolbox create $CREATE_ARGS -c freerdp || true
toolbox run -c freerdp sudo dnf upgrade --refresh -y
toolbox run -c freerdp sudo dnf install -y freerdp
toolbox run -c freerdp sudo dnf autoremove -y
toolbox run -c freerdp sudo dnf clean all

toolbox create $CREATE_ARGS -c node || true
toolbox run -c node sudo dnf upgrade --refresh -y
toolbox run -c node sudo dnf install -y alsa-lib libX11-xcb libXScrnSaver npm nss
toolbox run -c node sudo dnf autoremove -y
toolbox run -c node sudo dnf clean all
