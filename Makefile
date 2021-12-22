IMAGE?=docker.io/mgoltzsche/liteide

build:
	docker build -t "$(IMAGE)" .
