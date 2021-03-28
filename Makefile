IMAGETAG?=latest

build:
	docker build -t mgoltzsche/liteide:${IMAGETAG} .
