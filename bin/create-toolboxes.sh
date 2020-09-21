#!/bin/bash

set -euo pipefail

FEDORA_VERSION=$(rpm -E %fedora)
SOURCE_IMAGE=registry.fedoraproject.org/f$FEDORA_VERSION/fedora-toolbox:$FEDORA_VERSION
UPDATED_IMAGE=fedora-toolbox-$(date +%Y%m%d)

podman pull "$SOURCE_IMAGE"
WORKING_CONTAINER=$(buildah from --cap-add CAP_SETFCAP "$SOURCE_IMAGE")
buildah run "$WORKING_CONTAINER" -- bash -c "dnf upgrade --refresh -y"
buildah run "$WORKING_CONTAINER" -- bash -c "dnf install -y emacs vim zsh"
buildah run "$WORKING_CONTAINER" -- bash -c "dnf autoremove -y"
buildah run "$WORKING_CONTAINER" -- bash -c "dnf clean all"
buildah commit "$WORKING_CONTAINER" "$UPDATED_IMAGE"
buildah rm "$WORKING_CONTAINER"

CREATE_ARGS="--image $UPDATED_IMAGE"

toolbox create $CREATE_ARGS -c ocaml || true
toolbox run -c ocaml sudo dnf install -y fuse-devel g++ libffi-devel opam openssl-devel pcre-devel zlib-devel
toolbox run -c ocaml sudo dnf autoremove -y
toolbox run -c ocaml sudo dnf clean all
toolbox run -c ocaml opam init --compiler=4.09.0 --no-setup

toolbox create $CREATE_ARGS -c python || true
toolbox run -c python sudo dnf install -y python3-beautifulsoup4 python3-html5lib python3-netifaces python3-pycodestyle
toolbox run -c python sudo dnf autoremove -y
toolbox run -c python sudo dnf clean all

toolbox create $CREATE_ARGS -c wine || true
toolbox run -c wine sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
toolbox run -c wine sudo dnf install -y wine xorg-x11-drv-nvidia
toolbox run -c wine sudo dnf autoremove -y
toolbox run -c wine sudo dnf clean all

toolbox create $CREATE_ARGS -c media || true
toolbox run -c media sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
toolbox run -c media sudo dnf install -y beets beets-plugins cuetools ffmpeg flac ImageMagick plex-media-player shntool xorg-x11-drv-nvidia unrar youtube-dl
toolbox run -c media sudo dnf autoremove -y
toolbox run -c media sudo dnf clean all

toolbox create $CREATE_ARGS -c freerdp || true
toolbox run -c freerdp sudo dnf install -y freerdp
toolbox run -c freerdp sudo dnf autoremove -y
toolbox run -c freerdp sudo dnf clean all

toolbox create $CREATE_ARGS -c node || true
toolbox run -c node sudo dnf install -y alsa-lib libX11-xcb libXScrnSaver npm nss
toolbox run -c node sudo dnf autoremove -y
toolbox run -c node sudo dnf clean all
