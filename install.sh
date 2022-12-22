#!/usr/bin/env bash

BK=
if [[ -d "bin" ]]; then
  BK=1
  echo "Backing up existing sub folder bin..."
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
