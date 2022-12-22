#!/usr/bin/env bash

BK=
if [[ -d "bin" ]]; then
  BK=1
  echo "Backing up existing sub folder bin..."
  if [[ -f "bin/app-restart.sh" ]]; then
    rm bin/app-restart.sh
    rm bin/app-start.sh
    rm bin/post-install.sh
    rm bin/testing-dependencies.sh
  fi
  mv bin bin-backup
fi

git clone https://github.com/superpowerlabs/re-start-scripts bin

echo "Cleaning..."
rm bin/README.md
rm bin/install.sh
rm -rf bin/.git

if [[ "$BK" != "" ]]; then
  echo "Restoring existing sub folder bin..."
  mv bin-backup/* bin
  rm -rf bin-backup
fi
