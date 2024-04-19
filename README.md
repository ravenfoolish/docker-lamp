# docker-lamp 🐳

Build a simple LAMP (Laravel, Apache, MySQL, PHP) development environment with docker-compose. Compatible with Windows(WSL2), macOS(M1) and Linux.

## Usage

### Create an initial Laravel project

1. Click [Use this template](https://github.com/ucan-lab/docker-laravel/generate)
2. Git clone & change directory
3. Execute the following command

```bash
$ make create-project

# or...

$ mkdir -p src
$ docker compose build
$ docker compose up -d
$ docker compose exec app gosu $(WHOAMI) bash -c "\
    composer create-project --prefer-dist laravel/laravel . && \
    php artisan key:generate && \
    php artisan storage:link && \
    chmod -R 777 storage bootstrap/cache"
$ docker compose exec app php artisan migrate
```

http://localhost

### Create an existing Laravel project

1. Git clone & change directory
2. Execute the following command

```bash
$ make install

# or...

$ docker compose build
$ docker compose up -d
$ docker compose exec app gosu $(WHOAMI) bash -c "\
    composer install && \
    cp .env.example .env && \
    php artisan key:generate && \
    php artisan storage:link && \
    chmod -R 777 storage bootstrap/cache"
$ docker compose exec app php artisan migrate:fresh
```

http://localhost

## Container structures

```bash
├── app
├── db
└── adminer
```

### app container

- Base image
  - [php:8.2-apache](https://hub.docker.com/_/php):8.2-apache
  - [composer](https://hub.docker.com/_/composer):2.7

### db container

- Base image
  - [mysql/mysql-server](https://hub.docker.com/r/mysql/mysql-server):8.0

### adminer container

- Base image
  - [adminer](https://hub.docker.com/_/adminer)
