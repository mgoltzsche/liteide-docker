#!/bin/sh

set -e

[ $# -eq 1 ] || (echo 'Supported args: PROJECTDIR' >&2; false)

DIROWNER="$(stat -c '%u' "$1")"
CHUSR="${CHUSR:-$DIROWNER}"
chown "$CHUSR" "$HOME" /opt/liteide/share/liteide/liteenv/* /go

if [ -d "$1/vendor" ]; then
	export GOFLAGS="${GOFLAGS:--mod=vendor}"
elif [ -f "$1/go.mod" ]; then
	export GO111MODULE=${GO111MODULE:-on}
fi

gosu "$CHUSR" sh -c "HOME='$HOME' /opt/liteide/bin/liteide '$1'" &
PID=$!

termNow() {
	trap : 2 3 15
	kill -15 $PID
}

trap termNow 2 3 15
wait
