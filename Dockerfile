FROM golang:1.12-alpine AS build
RUN apk add --update --no-cache git make g++ qt5-qttools qt5-qtbase-dev qt5-qtbase-x11 qt5-qtwebkit xkeyboard-config
ARG LITEIDE_VERSION=x36
RUN git clone -b "${LITEIDE_VERSION}" --single-branch https://github.com/visualfc/liteide.git
WORKDIR /go/liteide/build
RUN ./update_pkg.sh
RUN QTDIR=/usr/lib/qt5 ./build_linux.sh

FROM golang:1.12-alpine
RUN apk add --update --no-cache qt5-qtbase-x11 qt5-qtwebkit libcanberra-gtk3 adwaita-icon-theme ttf-dejavu git
COPY --from=build /go/liteide/build/liteide /opt/liteide
ENV PATH=/go/bin:/usr/local/go/bin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/liteide/bin \
	GOROOT=/usr/local/go DISPLAY=:0 HOME=/opt/liteide/home
RUN go get golang.org/x/tools/cmd/godoc golang.org/x/lint/golint \
	&& rm -rf /opt/liteide/home/.cache \
	&& chmod -R go+wt /opt/liteide/home \
		/opt/liteide/share/liteide/liteenv \
		/go
ENTRYPOINT ["/opt/liteide/bin/liteide"]
CMD ["/go"]