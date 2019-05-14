#!/bin/sh

[ $# -gt 0 -a $# -le 2 ] \
	|| (echo "Usage: $0 PROJECTDIR [PKG]"; false) || exit 1

set -e

LITEIDE_IMAGE="${LITEIDE_IMAGE:-mgoltzsche/liteide:x36}"
PRJDIR="$(cd ${1:-${GOPATH:-.}} && pwd)"
PKG="${2:-}"
LITEIDE_INI="${LITEIDE_INI:-}"
[ ! "$PKG" ] || PKG="src/$PKG"
MOUNTS="${MOUNTS:-}"
[ ! -f "$PRJDIR"/liteide.ini ] || LITEIDE_INI="$PRJDIR"/liteide.ini
[ ! "$LITEIDE_INI" ] || MOUNTS="$MOUNTS --mount 'type=bind,src=${LITEIDE_INI},dst=/tmp/.config/liteide/liteide.ini'"

docker run --name liteide --rm \
	-u $(id -u):$(id -g) \
	-e DISPLAY="${DISPLAY}" \
	--mount type=bind,src=/tmp/.X11-unix,dst=/tmp/.X11-unix \
	--mount type=bind,src=/etc/machine-id,dst=/etc/machine-id \
	--mount "type=bind,src=${PRJDIR},dst=/work/${PKG}" \
	$MOUNTS \
	"${LITEIDE_IMAGE}" \
	"/work/${PKG}"
