LATEST_VERSION?=$(shell git fetch && git tag | sort -V | tail -n 1)
BUMPED_VERSION=$(shell semver bump patch ${LATEST_VERSION})
REPOSITORY=bamaas/dyet-developer
IMAGE=${REPOSITORY}:${BUMPED_VERSION}
CONTAINER_NAME=dyet-developer

# K8s
POD_NAME=dyet-developer
NAMESPACE=default

image:											## Build image locally
	docker build -f dyet-developer/Dockerfile -t ${IMAGE} ./dyet-developer

run_local:										## Run image locally
	docker run -d --rm --name ${CONTAINER_NAME} ${IMAGE} /bin/bash -c "sleep 99999"
	docker exec -it ${CONTAINER_NAME} /bin/bash

stop_local:
	docker stop ${CONTAINER_NAME}

push:
	docker push ${IMAGE}

deploy:
	kubectl -n ${NAMESPACE} get po ${POD_NAME} || \
	kubectl -n ${NAMESPACE} run ${POD_NAME} --image=${REPOSITORY}:${LATEST_VERSION} --command -- sleep 99999999

exec: deploy
	kubectl -n ${NAMESPACE} wait --for=condition=Ready pod/${POD_NAME}
	kubectl -n ${NAMESPACE} exec -it ${POD_NAME} -- /bin/sh

remove:
	kubectl -n ${NAMESPACE} delete po ${POD_NAME}

tag:
	echo "${BUMPED_VERSION}" > .tags

git-tag:
	$(eval LATEST_COMMIT_SHA := $(shell git rev-parse --short HEAD))
	git tag -a ${BUMPED_VERSION} ${LATEST_COMMIT_SHA} -m "New release version"
	git push --set-upstream origin ${BUMPED_VERSION}
	@echo "Tag added."