#!/bin/bash

set -euo pipefail

toolbox run -c ocaml sudo dnf upgrade --refresh -y
toolbox run -c ocaml sudo dnf autoremove -y
toolbox run -c ocaml sudo dnf clean all

toolbox run -c python sudo dnf upgrade --refresh -y
toolbox run -c python sudo dnf autoremove -y
toolbox run -c python sudo dnf clean all

toolbox run -c wine sudo dnf upgrade --refresh -y
toolbox run -c wine sudo dnf autoremove -y
toolbox run -c wine sudo dnf clean all

toolbox run -c media sudo dnf upgrade --refresh -y
toolbox run -c media sudo dnf autoremove -y
toolbox run -c media sudo dnf clean all

toolbox run -c freerdp sudo dnf upgrade --refresh -y
toolbox run -c freerdp sudo dnf autoremove -y
toolbox run -c freerdp sudo dnf clean all
