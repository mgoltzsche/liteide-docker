#!/bin/sh

CHUSR="${CHUSR:-0:0}"
chown -R "$CHUSR" "$HOME" /opt/liteide/share/liteide/liteenv &&
find /go -type d -exec chown "$CHUSR" {} + || exit 1
[ ! -d "$1/vendor" ] || export GOFLAGS="-mod=vendor $GOFLAGS"

gosu "$CHUSR" sh -c "HOME='$HOME' /opt/liteide/bin/liteide $@" &
PID=$!

termNow() {
	trap : 2 3 15
	kill -15 $PID
}

trap termNow 2 3 15
wait
