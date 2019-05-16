#!/bin/sh

[ $# -gt 0 -a $# -le 2 ] \
	|| (echo "Usage: $0 PROJECTDIR [PACKAGE]"; false) || exit 1

set -e

LITEIDE_VERSION="${LITEIDE_VERSION:-x36}"
LITEIDE_IMAGE="${LITEIDE_IMAGE:-mgoltzsche/liteide:$LITEIDE_VERSION}"
PRJDIR="$(cd ${1:-${GOPATH:-.}} && pwd)"
PKG="src/${2:-$(basename $PRJDIR)}"
LITEIDE_INI="${LITEIDE_INI:-}"
DOCKER_OPT=
[ ! -f "$PRJDIR"/liteide.ini ] || LITEIDE_INI="$PRJDIR"/liteide.ini
[ ! "$LITEIDE_INI" ] || DOCKER_OPT="$DOCKER_OPT --mount 'type=bind,src=${LITEIDE_INI},dst=/tmp/.config/liteide/liteide.ini'"

docker run -d --name liteide --rm \
	-u $(id -u):$(id -g) \
	-e DISPLAY="${DISPLAY}" \
	--mount type=bind,src=/tmp/.X11-unix,dst=/tmp/.X11-unix \
	--mount type=bind,src=/etc/machine-id,dst=/etc/machine-id \
	--mount "type=bind,src=${PRJDIR},dst=/go/${PKG}" \
	$DOCKER_OPT \
	"${LITEIDE_IMAGE}" \
	"/go/${PKG}"
