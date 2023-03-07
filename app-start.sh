#!/usr/bin/env bash

help () {
  echo "
No options or invalid option.

Accepted options:               Optional:   Defaults:

    -a [app name]               no
    -p [port number]            no
    -b [build folder]           yes         build0
    -h [healthcheck endpoint]   yes         healthcheck
    -c [total used cores]       yes         max
    -B [building folder]        yes         build

Examples:

    app-start.sh -a sale -p 8077 -c 2
    app-start.sh -a staking -p 9090 -b build_latest -h ping
"
}

cyan_echo() {
  local string="$1"
  echo -e "\033[36m$string\033[0m"
}

while getopts "a:b:p:h:c:B:" opt; do
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
  c)
    CORES=$OPTARG
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

if [[ "$CORES" == "" ]]; then
  CORES=max
fi

cyan_echo "--- Installing and building..."
pnpm i

pnpm test
if [[ "$?" == "1" ]]
then
  cyan_echo "--- Test failed. Exiting..."
  exit 1
fi

nice -n 19 pnpm build

if [[ $BUNDLE != $BUILD ]]; then
  cyan_echo "--- Syncing build folders..."
  rsync -a $BUILD/ $BUNDLE --delete
fi

if [[ `pm2 list | grep $APP | grep online` ]]; then
  pm2 delete $APP
fi

pm2 start index.js -i $CORES --name $APP
pm2 save

sleep 1

cyan_echo "--- Checking if everything works..."
OK=`curl http://localhost:$PORT/$HEALTHCHECK`

if [[ "$OK" != "ok" ]]
then
  cyan_echo "
--- APP NOT WORKING PROPERLY!!!
"
else
  cyan_echo "--- All seems working fine."
  cyan_echo "--- Listening on http://localhost:$PORT"
fi
