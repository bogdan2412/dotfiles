#!/bin/sh

set -eu

REPOSITORY_PATH=$(dirname "$(readlink -f "$0")")

usage() {
  echo "USAGE: $0 [--minimal|--full]"
  exit 1
}

if [ "$#" -ne 1 ]; then
  usage
fi

MINIMAL=false
if [ "$1" = "--minimal" ]; then
  MINIMAL=true
elif [ "$1" != "--full" ]; then
  usage
fi

PACKAGES_MINIMAL="
  .config/tmux
  .config/wezterm
  .zsh
"
PACKAGES_OTHER="
  .config/awesome
  .config/btop
  .config/dust
  .config/gtk-3.0/settings.ini
  .config/kitty
  .config/lsd
  .config/nvim
  .config/tmux
  .config/wezterm
  .emacs.d
  .gitconfig
  .gtkrc-2.0
  .i3
  .i3status.conf
  .spacemacs
  .zsh
  bin/chromium
  bin/create-toolboxes.sh
  bin/git-patdiff
  bin/git-svn-diff
  bin/i3-emulate-awesomewm-workspaces.py
  bin/icat
  bin/signal
  bin/steam
  bin/update-toolboxes.sh
  bin/vimdiff
"

if $MINIMAL; then
  PACKAGES_CLEANUP="$PACKAGES_OTHER"
  PACKAGES_INSTALL="$PACKAGES_MINIMAL"
else
  PACKAGES_CLEANUP=""
  PACKAGES_INSTALL="$PACKAGES_MINIMAL $PACKAGES_OTHER"
fi

echo "Checking out git submodules"
if ! [ -f "$REPOSITORY_PATH/nerd-fonts/.git" ]; then
  git -C "$REPOSITORY_PATH" clone --filter=blob:none --no-checkout https://github.com/ryanoasis/nerd-fonts.git
  git -C "$REPOSITORY_PATH" submodule absorbgitdirs
fi
git -C "$REPOSITORY_PATH/nerd-fonts" sparse-checkout set
git -C "$REPOSITORY_PATH/nerd-fonts" sparse-checkout add patched-fonts/Meslo
git -C "$REPOSITORY_PATH/nerd-fonts" reset >/dev/null
git -C "$REPOSITORY_PATH/nerd-fonts" sparse-checkout reapply
git -C "$REPOSITORY_PATH/nerd-fonts" checkout .
git -C "$REPOSITORY_PATH/nerd-fonts" clean -fdx

git -C "$REPOSITORY_PATH" submodule update --init

echo "Installing all symlink packages"
install_link () {
  SOURCE=$1
  DESTINATION=$2
  if [ -h "$DESTINATION" ]; then
    rm "$DESTINATION"
  fi
  if [ -e "$DESTINATION" ]; then
    echo "$DESTINATION already exists."
    return 1
  fi
  mkdir -p "$(dirname "$DESTINATION")"
  ln -s "$SOURCE" "$DESTINATION"
}

cleanup_old_config () {
  OLD_CONFIG=$1
  REPLACED_BY=${2-}

  if [ -h "$OLD_CONFIG" ]; then
    rm "$OLD_CONFIG"
  fi
  if [ -e "$OLD_CONFIG" ]; then
    if [ -n "$REPLACED_BY" ]; then
      echo "Deprecated $OLD_CONFIG exists, cannot install $REPLACED_BY."
    else
      echo "Deprecated $OLD_CONFIG exists."
    fi
    exit 1
  fi
}

cleanup_old_config "$HOME/.screenrc"
for PACKAGE in $PACKAGES_CLEANUP; do
  cleanup_old_config "$HOME/$PACKAGE"
done
for PACKAGE in $PACKAGES_INSTALL; do
  if [ "$PACKAGE" = ".emacs.d" ]; then
    install_link \
      "$REPOSITORY_PATH/.emacs.d" "$HOME/.emacs.d"
    install_link \
      "$REPOSITORY_PATH/.spacemacs-layer" "$HOME/.emacs.d/private/bogdan"
  elif [ "$PACKAGE" = ".config/tmux" ]; then
    cleanup_old_config "$HOME/.tmux.conf" "$PACKAGE"
    install_link "$REPOSITORY_PATH/$PACKAGE" "$HOME/$PACKAGE"
  elif [ "$PACKAGE" = ".config/nvim" ]; then
    cleanup_old_config "$HOME/.vim" "$PACKAGE"
    cleanup_old_config "$HOME/.vimrc" "$PACKAGE"
    rm -f "$HOME/.viminfo"
    install_link "$REPOSITORY_PATH/$PACKAGE" "$HOME/$PACKAGE"
  else
    install_link "$REPOSITORY_PATH/$PACKAGE" "$HOME/$PACKAGE"
  fi
done

echo "Installing all snippet packages"
PACKAGES_MINIMAL=".zshrc"
PACKAGES_OTHER=".bashrc .profile"
if $MINIMAL; then
  PACKAGES_INSTALL=$PACKAGES_MINIMAL
else
  PACKAGES_INSTALL="$PACKAGES_MINIMAL $PACKAGES_OTHER"
fi

BEGIN_MARKER="# ---- DOT FILES BOOTSTRAPPING BEGIN ----"
END_MARKER="# ---- DOT FILES BOOTSTRAPPING END ----"
for PACKAGE in $PACKAGES_INSTALL; do
  if [ ! -f "$HOME/$PACKAGE" ]; then
    touch "$HOME/$PACKAGE"
  fi
  matched_begin_markers=$(grep -x -c "$BEGIN_MARKER" "$HOME/$PACKAGE" || true)
  matched_end_markers=$(grep -x -c "$END_MARKER" "$HOME/$PACKAGE" || true)
  matched_markers=$((matched_begin_markers + matched_end_markers))
  if [ "$matched_begin_markers" -eq 1 ] && [ "$matched_end_markers" -eq 1 ]; then
    # shellcheck disable=SC2002
    cat "$REPOSITORY_PATH/$PACKAGE" | sed -i.bak -e "/^$BEGIN_MARKER$/,/^$END_MARKER$/{ r /dev/stdin" -e '//!d; }' "$HOME/$PACKAGE"
    if diff -q "$HOME/$PACKAGE.bak" "$HOME/$PACKAGE" >/dev/null 2>&1; then
      rm "$HOME/$PACKAGE.bak"
    fi
  else
    if [ "$matched_markers" -ne 0 ]; then
      echo "Warning: unable to remove existing snippets in $PACKAGE"
    fi

    {
      echo "$BEGIN_MARKER"
      cat "$REPOSITORY_PATH/$PACKAGE"
      echo "$END_MARKER"
    } >> "$HOME/$PACKAGE"
  fi
done

if [ -h "$HOME/.zprofile" ]; then
  rm "$HOME/.zprofile"
fi
if [ -e "$HOME/.zprofile" ]; then
  echo "$HOME/.zprofile already exists."
else
  ln -s "$HOME/.profile" "$HOME/.zprofile"
fi

if ! $MINIMAL; then
  echo "Installing fonts"
  "$REPOSITORY_PATH/nerd-fonts/install.sh" --link
fi

echo "Done. Have fun!"
