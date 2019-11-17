#!/bin/bash

set -euo pipefail

toolbox run -c ocaml sudo dnf upgrade --refresh -y
toolbox run -c wine sudo dnf upgrade --refresh -y
toolbox run -c python sudo dnf upgrade --refresh -y
toolbox run -c media sudo dnf upgrade --refresh -y
