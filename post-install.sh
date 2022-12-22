#!/usr/bin/env bash

echo "Install extra dependencies"
bin/extra-dependencies.sh

if [[ -d "/home/ubuntu/" ]]; then
  exit 0
fi

husky install

if [[ ! -f "bin/pre-commit.sh" ]]; then
  echo "pre-commit.sh not found. Creating one."
  echo "#!/usr/bin/env bash

npx pretty-quick --staged && npm test
" >> bin/pre-commit.sh
  chmod +x bin/pre-commit.sh
fi

if [[ ! -f ".husky/pre-commit" || `cat .husky/pre-commit | grep "bin/pre-commit.sh"` == "" ]]; then
    echo "Setting husky up"
    npx mrm@2 lint-staged
    npx husky-init
    pnpm i -D pretty-quick
    npx husky set .husky/pre-commit "bin/pre-commit.sh"
fi

bin/testing-dependencies.sh
