#!/bin/sh

set -euo pipefail

FEDORA_VERSION=$(rpm -E %fedora)
SOURCE_IMAGE=registry.fedoraproject.org/fedora-toolbox:$FEDORA_VERSION
UPDATED_IMAGE=fedora-toolbox-$(date +%Y%m%d)

podman pull "$SOURCE_IMAGE"
WORKING_CONTAINER=$(buildah from --cap-add CAP_SETFCAP "$SOURCE_IMAGE")
buildah run "$WORKING_CONTAINER" -- sh -c "dnf upgrade --refresh -y"
buildah run "$WORKING_CONTAINER" -- sh -c "echo > /etc/yum.repos.d/vscode.repo '\
[vscode]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc'"
buildah run "$WORKING_CONTAINER" -- rpm --import https://packages.microsoft.com/keys/microsoft.asc
buildah run "$WORKING_CONTAINER" -- sh -c "dnf install -y bat code emacs fzf htop jq ripgrep ShellCheck vim zsh"
buildah run "$WORKING_CONTAINER" -- sh -c "dnf autoremove -y"
buildah run "$WORKING_CONTAINER" -- sh -c "dnf clean all"
buildah commit "$WORKING_CONTAINER" "$UPDATED_IMAGE"
buildah rm "$WORKING_CONTAINER"

CREATE_ARGS="--image $UPDATED_IMAGE"

toolbox create $CREATE_ARGS -c ocaml || true
toolbox run -c ocaml sudo dnf install -y clang-tools-extra fuse-devel g++ git-filter-repo gmp-devel inotify-tools libffi-devel opam openssl-devel pcre-devel zlib-devel
toolbox run -c ocaml sudo dnf autoremove -y
toolbox run -c ocaml sudo dnf clean all
toolbox run -c ocaml opam init --bare --no-setup default git+https://github.com/ocaml/opam-repository

toolbox create $CREATE_ARGS -c media || true
toolbox run -c media sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
toolbox run -c media sudo dnf install -y beets beets-plugins cuetools ffmpeg flac ImageMagick plex-media-player shntool xorg-x11-drv-nvidia unrar youtube-dl
toolbox run -c media sudo dnf autoremove -y
toolbox run -c media sudo dnf clean all

toolbox create $CREATE_ARGS -c node || true
toolbox run -c node sudo dnf install -y alsa-lib libX11-xcb libXScrnSaver npm nss
toolbox run -c node sudo dnf autoremove -y
toolbox run -c node sudo dnf clean all

toolbox create $CREATE_ARGS -c freerdp || true
toolbox run -c freerdp sudo dnf install -y freerdp
toolbox run -c freerdp sudo dnf autoremove -y
toolbox run -c freerdp sudo dnf clean all

toolbox create $CREATE_ARGS -c python || true
toolbox run -c python sudo dnf install -y python3-beautifulsoup4 python3-html5lib python3-netifaces python3-pycodestyle
toolbox run -c python sudo dnf autoremove -y
toolbox run -c python sudo dnf clean all

toolbox create $CREATE_ARGS -c wine || true
toolbox run -c wine sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
toolbox run -c wine sudo dnf install -y wine xorg-x11-drv-nvidia
toolbox run -c wine sudo dnf autoremove -y
toolbox run -c wine sudo dnf clean all

toolbox create $CREATE_ARGS -c golang || true
toolbox run -c golang sudo dnf install -y golang
toolbox run -c golang sudo dnf autoremove -y
toolbox run -c golang sudo dnf clean all
