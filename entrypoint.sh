#!/bin/sh

set -e

CHUSR="${CHUSR:-0:0}"
chown -R "$CHUSR" "$HOME" /opt/liteide/share/liteide/liteenv
find /go -type d -exec chown "$CHUSR" {} +

if [ -d "$1/vendor" ]; then
	export GOFLAGS="-mod=vendor $GOFLAGS"
elif [ -f "$1/go.mod" ]; then
	export GO111MODULE=${GO111MODULE:-on}
fi

gosu "$CHUSR" sh -c "HOME='$HOME' /opt/liteide/bin/liteide $@" &
PID=$!

termNow() {
	trap : 2 3 15
	kill -15 $PID
}

trap termNow 2 3 15
wait
