include .env 

repo=quay.io/chiefy/alpine-php-mediawiki

.PHONY: build
build:
	docker build \
	--build-arg COMPOSER_HASH=$(COMPOSER_HASH) \
	--build-arg MW_VERSION=$(MW_VERSION) \
	--build-arg MW_PATCH_VERSION=$(MW_PATCH_VERSION) \
	-t $(repo):$(MW_VERSION).$(MW_PATCH_VERSION) .

.PHONY: up
up: 
	@docker-compose up -d 
