#!/bin/bash

REPOSITORY_PATH=$(dirname $(readlink -f $0))

PACKAGES=".gitconfig .vim .vimrc"

echo "Symlinking all packages"
for PACKAGE in $PACKAGES; do
  if [ -e "$HOME/$PACKAGE" ]; then
    if [ -h "$HOME/$PACKAGE" ]; then
      rm "$HOME/$PACKAGE"
    else
      echo "$HOME/$PACKAGE already exists."
      continue
    fi
  fi
  ln -s "$REPOSITORY_PATH/$PACKAGE" "$HOME/$PACKAGE"
done

echo "Compiling Command-T plugin in vim package"
cd $HOME/.vim/bundle/command-t/ruby/command-t
ruby extconf.rb
make
rm Makefile mkmf.log *.o
cd $OLDPWD

echo "Done. Have fun!"
