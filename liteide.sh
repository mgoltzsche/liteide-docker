#!/bin/sh

[ $# -gt 0 -a $# -le 2 ] \
	|| (echo "Usage: $0 PROJECTDIR [PACKAGE]"; false) || exit 1

set -e

LITEIDE_VERSION="${LITEIDE_VERSION:-x37.1}"
LITEIDE_IMAGE="${LITEIDE_IMAGE:-mgoltzsche/liteide:$LITEIDE_VERSION}"
PRJDIR="$(cd ${1:-${GOPATH:-.}} && pwd)"
PKG="src/${2:-$(basename $PRJDIR)}"
if [ $# -eq 1 ] && [ -f "$PRJDIR/go.mod" ]; then
	PKG="src/$(grep -Em1 '^module\s+.*' "$PRJDIR/go.mod" | sed -E 's/^module\s+//')"
fi
LITEIDE_INI="${LITEIDE_INI:-}"
DOCKER_OPT=
[ ! -f "$PRJDIR"/liteide.ini ] \
	|| LITEIDE_INI="$PRJDIR"/liteide.ini
[ ! "$LITEIDE_INI" ] \
	|| DOCKER_OPT="$DOCKER_OPT --mount type=bind,src=${LITEIDE_INI},dst=/tmp/.config/liteide/liteide.ini"
! ([ -d "$PRJDIR"/.liteide-cache ] || [ "$LITEIDE_CACHE" = on ]) \
	|| DOCKER_OPT="$DOCKER_OPT -v ${PRJDIR}/.liteide-cache:/go"

docker run -d --name "liteide-$(basename $PRJDIR)" --rm \
	-e DISPLAY="${DISPLAY}" \
	-e CHUSR=$(id -u):$(id -g) \
	--mount type=bind,src=/tmp/.X11-unix,dst=/tmp/.X11-unix \
	--mount type=bind,src=/etc/machine-id,dst=/etc/machine-id \
	$DOCKER_OPT \
	--mount "type=bind,src=${PRJDIR},dst=/go/${PKG}" \
	"${LITEIDE_IMAGE}" \
	"/go/${PKG}"
