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
    -d [don't pull]             yes         false

Examples:

    app-restart.sh -a sale -p 8077
    app-restart.sh -a staking -p 9090 -b build_latest -h ping
"
}

cyan_echo() {
  local string="$1"
  echo -e "\033[36m$string\033[0m"
}

while getopts "a:b:p:h:B:d:" opt; do
  case $opt in
  a)
    APP=$OPTARG
    ;;
  b)
    BUNDLE=$OPTARG
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
  d)
    DONT_PULL=$OPTARG
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

if [[ "$BUNDLE" == "" ]]; then
  BUNDLE=build0
fi

if [[ "$BUILD" == "" ]]; then
  BUILD=build
fi

cyan_echo "--- Backing up the current build..."
cp -r $BUNDLE ../build-backup

cyan_echo "--- Getting current HEAD from git..."
COMMIT=`git rev-parse HEAD`

if [[ "$DONT_PULL" != "true" ]]; then
  cyan_echo "--- Pulling..."
  git pull
fi

cyan_echo "--- Updating dependencies..."
pnpm i

cyan_echo "--- Testing..."
pnpm test
if [[ "$?" == "1" ]]
then
  cyan_echo "--- Test failed. Exiting..."
  exit 1
fi

cyan_echo "--- Building nicely..."
nice -n 19 pnpm build

if [[ $BUNDLE != $BUILD ]]; then
  cyan_echo "--- Syncing $BUILD >> $BUNDLE..."
  rsync -a $BUILD/ $BUNDLE --delete
fi

cyan_echo "--- Restarting app..."
pm2 restart $APP

sleep 1

cyan_echo "--- Checking if everything works..."
OK=`curl http://localhost:$PORT/$HEALTHCHECK`

if [[ "$OK" != "ok" ]]
then
  cyan_echo "
--- App not working properly. Reverting to
$COMMIT
"
  git reset --hard $COMMIT
  pnpm i
  rsync -a ../build-backup/ $BUNDLE --delete
  pm2 restart $APP
else
  cyan_echo "--- All seems working fine."
  cyan_echo "--- Listening on http://localhost:$PORT"
fi

rm -rf ../build-backup
