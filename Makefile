IMAGE?=docker.io/mgoltzsche/liteide

build:
	docker build -t "$(IMAGE)" .

push:
	@[ "$(TAG)" ] || (echo no TAG specified; false)
	docker tag "$(IMAGE)" "$(IMAGE):$(TAG)"
	docker push "$(IMAGE):$(TAG)"

release:
	@[ "$(VERSION)" ] || (echo no VERSION specified; false)
	@{ \
		set -eu; \
		VERSION="$(VERSION)"; \
		TMPDIR=`mktemp -d`; \
		STATUS=0; \
		( \
			cp -rf . $$TMPDIR && \
			cd $$TMPDIR && \
			git tag -a "$$VERSION" -m"Release $$VERSION" && \
			make build && \
			make push TAG=latest && \
			make push TAG="$$VERSION" && \
			git push --tags \
		) || STATUS=1; \
		rm -rf $$TMPDIR; \
		exit $$STATUS; \
	}
