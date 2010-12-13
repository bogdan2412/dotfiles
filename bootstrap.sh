#!/bin/bash

REPOSITORY_PATH=$(dirname $(readlink -f $0))

PACKAGES=".gitconfig .vim .vimrc"

echo "Installing all symlink packages"
for PACKAGE in $PACKAGES; do
  if [ -h "$HOME/$PACKAGE" ]; then
    rm "$HOME/$PACKAGE"
  fi
  if [ -e "$HOME/$PACKAGE" ]; then
    echo "$HOME/$PACKAGE already exists."
    continue
  fi
  ln -s "$REPOSITORY_PATH/$PACKAGE" "$HOME/$PACKAGE"
done

echo "Compiling Command-T plugin in vim package"
cd $HOME/.vim/bundle/command-t/ruby/command-t
ruby extconf.rb
make
rm Makefile mkmf.log *.o
cd $OLDPWD

echo "Installing all snippet packages"
PACKAGES=".bashrc .profile"
BEGIN_MARKER="# ---- DOT FILES BOOTSTRAPPING BEGIN ----"
END_MARKER="# ---- DOT FILES BOOTSTRAPPING END ----"
for PACKAGE in $PACKAGES; do
  if [ ! -f "$HOME/$PACKAGE" ]; then
    touch "$HOME/$PACKAGE"
  fi
  matched_begin_markers=$(grep -x -c "$BEGIN_MARKER" "$HOME/$PACKAGE")
  matched_end_markers=$(grep -x -c "$END_MARKER" "$HOME/$PACKAGE")
  matched_markers=$(($matched_begin_markers + $matched_end_markers))
  if [ "$matched_begin_markers" == "1" -a "$matched_end_markers" == "1" ]; then
    # Try and remove already installed snippet.
    begin_line=$(grep -x -n "$BEGIN_MARKER" "$HOME/$PACKAGE")
    begin_line=${begin_line%%:*}
    end_line=$(grep -x -n "$END_MARKER" "$HOME/$PACKAGE")
    end_line=${end_line%%:*}

    sed -i "$begin_line,$end_line d" $HOME/$PACKAGE
  elif [ "$matched_markers" != "0" ]; then
    echo "Warning: unable to remove existing snippets in $PACKAGE"
  fi

  echo "$BEGIN_MARKER" >> $HOME/$PACKAGE
  cat $REPOSITORY_PATH/$PACKAGE >> $HOME/$PACKAGE
  echo "$END_MARKER" >> $HOME/$PACKAGE
done

echo "Done. Have fun!"
