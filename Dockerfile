FROM golang:1.13-alpine AS build
RUN apk add --update --no-cache git make g++ qt5-qttools qt5-qtbase-dev qt5-qtbase-x11 qt5-qtwebkit xkeyboard-config
ARG LITEIDE_VERSION=x36.2
RUN git clone -b "${LITEIDE_VERSION}" --single-branch https://github.com/visualfc/liteide.git
WORKDIR /go/liteide/build
RUN ./update_pkg.sh
RUN QTDIR=/usr/lib/qt5 ./build_linux.sh

FROM golang:1.13-alpine
RUN apk add --update --no-cache qt5-qtbase-x11 qt5-qtwebkit libcanberra-gtk3 adwaita-icon-theme ttf-dejavu git gcc musl-dev bash
COPY --from=build /go/liteide/build/liteide /opt/liteide
ENV PATH=/go/bin:/usr/local/go/bin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/liteide/bin \
	GOROOT=/usr/local/go DISPLAY=:0 HOME=/opt/liteide/home
RUN go get golang.org/x/tools/cmd/godoc golang.org/x/lint/golint \
	&& rm -rf /opt/liteide/home/.cache /go/src/* \
	&& mv /go/bin/* /usr/local/bin/ \
	&& rm -rf /go/*

# Add gosu for easy stepdown from root
ENV GOSU_VERSION 1.11
RUN set -x \
	&& apk add --update --no-cache gnupg \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64.asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
	&& rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true \
	&& apk del --purge gnupg

ADD entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/go"]
