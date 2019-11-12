include .env 

repo=quay.io/chiefy/alpine-php-mediawiki

.PHONY: build
build:
	COMPOSER_HASH=$(COMPOSER_HASH) \
	MW_VERSION=$(MW_VERSION) \
	MW_PATCH_VERSION=$(MW_PATCH_VERSION) \
	docker build -t $(repo):$(MW_VERSION).$(MW_PATCH_VERSION) .

.PHONY: up
up: 
	@docker-compose up -d 
