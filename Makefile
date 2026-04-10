TAG ?= clover/openresty
PLATFORM ?= linux/amd64

latest:
	docker buildx build --platform ${PLATFORM} --tag ${TAG}:$@ --push .

.PHONY: latest
