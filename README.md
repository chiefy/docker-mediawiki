# docker-mediawiki

A working docker-compose orchestration of PHP5-fpm / nginx / mysql and mediawiki

## About

I have been looking around for a decent docker-based orchestration of Mediawiki, yet haven't found one. As an exercise I got Mediawiki running on lightweight Alpine linux based docker images of latest nginx, and php5-fpm w/ Mediawiki. This setup uses MySQL for persistence, but you can use any of the engines that mediawiki supports (postgres, sqlite etc.).

## Usage

`docker-compose up -d`

This will get you a brand new mediawiki installation, you need to install it by visiting `http://localhost`

## Options

Some of the `volume` properties in the `docker-compose.yml` have been commented out. When uncommented, you can auto-import a SQL backup and mount an existing `LocalSettings.php` for mediawiki to bootstrap an existing wiki.

## TODO

  * Generate `Makefile` to template some of this out for different scenarios
  * Is there an official `alpine-nginx` container? If so, use that.
  * Enable caching
  * HTTPS/SSL cert support
