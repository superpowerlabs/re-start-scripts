#!/usr/bin/env bash

help () {
  echo "
No options or invalid option.

Accepted options:               Optional:   Defaults:

    -a [app name]               no
    -p [port number]            no
    -b [build folder]           yes         build0
    -h [healthcheck endpoint]   yes         healthcheck
    -B [building folder]        yes         build

Examples:

    app-restart.sh -a sale -p 8077
    app-restart.sh -a staking -p 9090 -b build_latest -h ping
"
}

while getopts "a:b:p:h:B:" opt; do
  case $opt in
  a)
    APP=$OPTARG
    ;;
  b)
    BUILD0=$OPTARG
    ;;
  B)
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

if [[ "$BUILD0" == "" ]]; then
  BUILD0=build0
fi

if [[ "$BUILD" == "" ]]; then
  BUILD=build
fi

echo "--- Backing up the current build..."
cp -r $BUILD0 ../build-backup

echo "--- Getting current HEAD from git..."
COMMIT=`git rev-parse HEAD`

echo "--- Pulling, installing and building..."
git pull
pnpm i

pnpm test
if [[ "$?" == "1" ]]
then
  echo "--- Test failed. Exiting..."
  exit 1
fi

nice -n 19 pnpm build

echo "--- Syncing build folders..."
rsync -a $BUILD/ $BUILD0 --delete

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
  rsync -a ../build-backup/ $BUILD0 --delete
  pm2 restart $APP
else
  echo "--- All seems working fine."
  echo "--- Listening on http://localhost:$PORT"
fi

rm -rf ../build-backup
