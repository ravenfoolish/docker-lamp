# docker-lamp 🐳

Build a simple LAMP (Laravel, Apache, MySQL, PHP) development environment with docker-compose. Compatible with Windows(WSL2), macOS(M1) and Linux.

## Usage

### Create an initial Laravel project

1. Click [Use this template](https://github.com/ucan-lab/docker-laravel/generate)
2. Git clone & change directory
3. Execute the following command

#### tips

When you use `make` command, the host user's UID, GID, and USERNAME can be the same as the container execution user.

```bash
$ make create-project

# or...

$ mkdir -p src
$ docker compose build
$ docker compose up -d
$ docker compose exec app composer create-project --prefer-dist laravel/laravel .
$ docker compose exec app php artisan key:generate
$ docker compose exec app php artisan storage:link
$ docker compose exec app chmod -R 777 storage bootstrap/cache
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
$ docker compose exec app composer install
$ docker compose exec app cp .env.example .env
$ docker compose exec app php artisan key:generate
$ docker compose exec app php artisan storage:link
$ docker compose exec app chmod -R 777 storage bootstrap/cache
```

http://localhost

### Login to the app container as a non-root user

```bash
$ make app
docker compose exec app gosu username bash
username@a5a88db461e9:/var/www/html$
```

### Login to the app container as a root user

```bash
$ docker compose exec app bash
root@a5a88db461e9:/var/www/html#
```

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
