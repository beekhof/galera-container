IMAGE_NAME=galera
IMAGE_TAG=latest
IMAGE_REPO=quay.io
IMAGE_USER=beekhof

IMAGE=$(IMAGE_REPO)/$(IMAGE_USER)/$(IMAGE_NAME):$(IMAGE_TAG)
IMAGE_STATUS=https://$(IMAGE_REPO)/repository/$(IMAGE_USER)/$(IMAGE_NAME)/status

build:
	echo "building container..."
	docker build --tag "$(IMAGE)" -f Dockerfile . 

# For gcr users, run `gcloud docker -a` to have access.
# For quay users, run `docker login quay.io` 
local-publish: build
	@echo "building container..."
	docker build --tag "${IMAGE}" -f Dockerfile .
	@echo "Uploading to $(IMAGE)"
	docker push $(IMAGE)
	@echo "upload complete"

publish: push wait

export:
	docker save $(IMAGE)  | gzip > $(IMAGE).tar.gz

pf:
	wget -O peer-finder.go https://raw.githubusercontent.com/kubernetes/contrib/master/peer-finder/peer-finder.go

push:
	git push

wait:
	date
	@echo "Waiting for $(IMAGE) to build..." 
	sleep 5
	-while [ "x$$(curl -s $(IMAGE_STATUS) | tr '<' '\n' | grep -v -e '>$$'  -e '^/' | sed 's/.*>//' | tail -n 1)" = xbuilding ]; do sleep 50; /bin/echo -n .; done
	curl -s $(IMAGE_STATUS) | tr '<' '\n' | grep -v -e ">$$"  -e '^/' | sed 's/.*>//' | tail -n 1
	date
