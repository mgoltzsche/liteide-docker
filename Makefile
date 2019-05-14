LITEIDE_VERSION?=x36
IMAGE=mgoltzsche/liteide:${LITEIDE_VERSION}

build:
	docker build -t ${IMAGE} .
