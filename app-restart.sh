#!/usr/bin/env bash

help () {
  echo "
No options or invalid option.

Accepted options:               Optional:   Defaults:

    -a [app name]               no
    -p [port number]            no
    -b [build folder]           yes         build0
    -h [healthcheck endpoint]   yes         healthcheck

Examples:

    app-restart.sh -a sale -p 8077
    app-restart.sh -a staking -p 9090 -b build_latest -h ping
"
}

while getopts "a:b:p:h:" opt; do
  case $opt in
  a)
    APP=$OPTARG
    ;;
  b)
    BUILD=$OPTARG
    ;;
  p)
    PORT=$OPTARG
    ;;
  h)
    HEALTHCHECK=$OPTARG
    ;;
  \?)
    help
    exit 1
    ;;
  esac
done

if [[ "$APP" == "" || "$PORT" == "" ]]; then
  help
  exit 1
fi

if [[ "$HEALTHCHECK" == "" ]]; then
  HEALTHCHECK=healthcheck
fi

if [[ "$BUILD" == "" ]]; then
  BUILD=build0
fi

echo "--- Backing up the current build..."
cp -r $BUILD ../build-backup

echo "--- Getting current HEAD from git..."
COMMIT=`git rev-parse HEAD`

echo "--- Pulling, installing and building..."
git pull
pnpm i
pnpm build

echo "--- Syncing build folders..."
rsync -a build/ $BUILD --delete

pm2 restart $APP

sleep 1

echo "--- Checking if everything works..."
OK=`curl http://localhost:$PORT/$HEALTHCHECK`

if [[ "$OK" != "ok" ]]
then
  echo "
--- App not working properly. Reverting to
$COMMIT
"
  git reset --hard $COMMIT
  pnpm i
  rsync -a ../build-backup/ $BUILD --delete
  pm2 restart $APP
else
  echo "--- All seems working fine."
fi

rm -rf ../build-backup
