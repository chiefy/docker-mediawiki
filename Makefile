include .env 

repo=ghcr.io/chiefy/alpine-mediawiki
full_image=$(repo):$(MW_VERSION).$(MW_PATCH_VERSION)

.PHONY: push 
push:
	@docker push $(full_image)
	@docker push $(repo):latest

.PHONY: build
build:
	@docker build \
	--build-arg COMPOSER_HASH=$(COMPOSER_HASH) \
	--build-arg MW_VERSION=$(MW_VERSION) \
	--build-arg MW_PATCH_VERSION=$(MW_PATCH_VERSION) \
	-t $(full_image) .
	@docker tag $(full_image) $(repo):latest

.PHONY: up
up: 
	@docker-compose up -d 
