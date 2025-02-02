FROM golang:1.23.4-alpine3.20 AS build
RUN apk add --update --no-cache git make g++ qtchooser qt5-qttools qt5-qtbase-dev qt5-qtbase-x11 qt5-qtwebengine-dev xkeyboard-config
ARG LITEIDE_VERSION=x38.3
ARG GOTOOLS_VERSION=v1.5.4
ARG GOCODE_VERSION=v1.5.2
ARG GOMODIFYTAGS_VERSION=v1.17.0
RUN git -c 'advice.detachedHead=false' clone -b "${LITEIDE_VERSION}" --single-branch https://github.com/visualfc/liteide.git /liteide-src
WORKDIR /liteide-src/build
RUN ./update_pkg.sh
# Get Go tools because `build_linux.sh` requires them and `update_pkg.sh` silently failed to build the older versions when using a newer Go version.
# See https://github.com/visualfc/liteide#update-liteide-tools-for-support-new-golang-version
RUN git -c 'advice.detachedHead=false' clone -b "${GOTOOLS_VERSION}" --single-branch https://github.com/visualfc/gotools.git /liteide-src/liteidex/src/github.com/visualfc/gotools
RUN git -c 'advice.detachedHead=false' clone -b "${GOCODE_VERSION}" --single-branch https://github.com/visualfc/gocode.git /liteide-src/liteidex/src/github.com/visualfc/gocode
RUN git -c 'advice.detachedHead=false' clone -b "${GOMODIFYTAGS_VERSION}" --single-branch https://github.com/fatih/gomodifytags.git /liteide-src/liteidex/src/github.com/fatih/gomodifytags
RUN QTDIR=/usr/lib/qt5 ./build_linux.sh

FROM golang:1.23.4-alpine3.20

# Add gosu for easy stepdown from root
ENV GOSU_VERSION=1.17
RUN set -ex; \
	apk add --update --no-cache gnupg; \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64.asc"; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc || rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	chmod +x /usr/local/bin/gosu; \
	gosu nobody true; \
	apk del --purge gnupg

RUN apk add --update --no-cache qt5-qtbase-x11 qt5-qtwebengine libcanberra-gtk3 adwaita-icon-theme ttf-dejavu git gcc gdb musl-dev linux-headers make bash curl gcompat libc6-compat
COPY --from=build /liteide-src/build/liteide /opt/liteide
ENV PATH=/go/bin:/usr/local/go/bin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/liteide/bin \
	GOROOT=/usr/local/go \
	HOME=/opt/liteide/home \
	DISPLAY=:0
RUN set -ex; \
	go install golang.org/x/tools/cmd/godoc@v0.25.0; \
	go install golang.org/x/tools/cmd/guru@v0.19.0; \
	go install github.com/go-delve/delve/cmd/dlv@v1.23.0; \
	rm -rf /opt/liteide/home/.cache /go/src/*; \
	mv /go/bin/* /usr/local/bin/; \
	rm -rf /go/*

ADD entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/go"]
