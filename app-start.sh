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
    -C

Examples:

    app-start.sh -a sale -p 8077 -c 2
    app-start.sh -a staking -p 9090 -b build_latest -h ping
"
}

while getopts "a:b:p:h:c:B:C:" opt; do
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
  c)
    CORES=$OPTARG
    ;;
  C)
    ECHO=$OPTARG
    ;;
  \?)
    help
    exit 1
    ;;
  esac
done

echo $ECHO

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

if [[ "$CORES" == "" ]]; then
  CORES=max
fi

if [[ `pm2 list | grep $APP | grep online` ]]; then
  pm2 delete $APP
fi

echo "--- Installing and building..."
pnpm i
pnpm build

echo "--- Syncing build folders..."
rsync -a $BUILD/ $BUILD0 --delete

pm2 start index.js -i $CORES --name $APP
pm2 save

sleep 1

echo "--- Checking if everything works..."
OK=`curl http://localhost:$PORT/$HEALTHCHECK`

if [[ "$OK" != "ok" ]]
then
  echo "
--- APP NOT WORKING PROPERLY!!!
"
else
  echo "--- All seems working fine."
fi
