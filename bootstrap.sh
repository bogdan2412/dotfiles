#!/bin/sh

set -eu

REPOSITORY_PATH=$(dirname "$(readlink -f "$0")")
SPACEMACS=true
if [ "${1:-}" = "--no-spacemacs" ]; then
  SPACEMACS=false
fi

PACKAGES="
  .config/awesome
  .config/btop
  .config/dust
  .config/gtk-3.0/settings.ini
  .config/kitty
  .config/lsd
  .config/nvim
  .config/tmux
  .emacs.d
  .gitconfig
  .gtkrc-2.0
  .i3
  .i3status.conf
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

for PACKAGE in $PACKAGES; do
  if [ "$PACKAGE" = ".emacs.d" ]; then
    if $SPACEMACS; then
      install_link \
        "$REPOSITORY_PATH/.emacs.d-with-spacemacs" "$HOME/.emacs.d"
      install_link \
        "$REPOSITORY_PATH/.spacemacs" "$HOME/.spacemacs"
      install_link \
        "$REPOSITORY_PATH/.spacemacs-layer" "$HOME/.emacs.d/private/bogdan"
    else
      install_link \
        "$REPOSITORY_PATH/.emacs.d-without-spacemacs" "$HOME/.emacs.d"
    fi
  elif [ "$PACKAGE" = ".config/tmux" ]; then
    if [ -h "$HOME/.tmux.conf" ]; then
      rm "$HOME/.tmux.conf"
    fi
    if [ -e "$HOME/.tmux.conf" ]; then
      echo "$HOME/.tmux.conf already exists, cannot install $PACKAGE."
      exit 1
    fi

    install_link "$REPOSITORY_PATH/$PACKAGE" "$HOME/$PACKAGE"
  else
    install_link "$REPOSITORY_PATH/$PACKAGE" "$HOME/$PACKAGE"
  fi
done

echo "Installing all snippet packages"
PACKAGES=".bashrc .profile .zshrc"
BEGIN_MARKER="# ---- DOT FILES BOOTSTRAPPING BEGIN ----"
END_MARKER="# ---- DOT FILES BOOTSTRAPPING END ----"
for PACKAGE in $PACKAGES; do
  if [ ! -f "$HOME/$PACKAGE" ]; then
    touch "$HOME/$PACKAGE"
  fi
  matched_begin_markers=$(grep -x -c "$BEGIN_MARKER" "$HOME/$PACKAGE" || true)
  matched_end_markers=$(grep -x -c "$END_MARKER" "$HOME/$PACKAGE" || true)
  matched_markers=$((matched_begin_markers + matched_end_markers))
  if [ "$matched_begin_markers" -eq 1 ] && [ "$matched_end_markers" -eq 1 ]; then
    cat "$REPOSITORY_PATH/$PACKAGE" | sed -i.bak -e "/^$BEGIN_MARKER$/,/^$END_MARKER$/{ r /dev/stdin" -e '//!d; }' "$HOME/$PACKAGE"
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

echo "Installing fonts"
"$REPOSITORY_PATH/nerd-fonts/install.sh" --link

echo "Done. Have fun!"
