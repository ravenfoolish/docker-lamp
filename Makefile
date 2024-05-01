SHELL=/bin/bash

## args
UID = $(shell id -u ${USER})
GID = $(shell id -g ${USER})
WHOAMI = $(shell whoami)

ifeq ($(shell uname), Darwin)
	# Default group id is '20' on macOS. This group id is already exsit on Linux Container. So set a same value as uid.
	GID = $(UID)
endif

export UID GID WHOAMI

install:
	@echo "Building the Docker images..."
	@make build
	@echo "Starting up the Docker containers..."
	@make up
	@echo "Executing installation commands inside the 'app' container..."
	docker compose exec app gosu $(WHOAMI) bash -c "\
		set -xe; \
		composer install && \
		cp .env.example .env && \
		php artisan key:generate && \
		php artisan storage:link && \
		chmod -R 777 storage bootstrap/cache"
	@echo "Refreshing the database..."
	@make fresh
create-project:
	@echo "Creating directories..."
	mkdir -p src
	@echo "Building the Docker images..."
	@make build
	@echo "Starting up the Docker containers..."
	@make up
	@echo "Executing commands inside the 'app' container..."
	docker compose exec app gosu $(WHOAMI) bash -c "\
		set -xe; \
		composer create-project --prefer-dist laravel/laravel . && \
		php artisan storage:link && \
		chmod -R 777 storage bootstrap/cache"
build:
	docker compose build
up:
	docker compose up -d
stop:
	docker compose stop
down:
	docker compose down --remove-orphans
down-v:
	docker compose down --remove-orphans --volumes
restart:
	@make down
	@make up
destroy:
	docker compose down --rmi all --volumes --remove-orphans
remake:
	@make destroy
	@make install
ps:
	docker compose ps
web:
	docker compose exec web bash
app:
	docker compose exec app gosu $(WHOAMI) bash
tinker:
	docker compose exec app php artisan tinker
dump:
	docker compose exec app php artisan dump-server
test:
	docker compose exec app php artisan test
migrate:
	docker compose exec app php artisan migrate
fresh:
	docker compose exec app php artisan migrate:fresh --seed
seed:
	docker compose exec app php artisan db:seed
dacapo:
	docker compose exec app php artisan dacapo
rollback-test:
	docker compose exec app php artisan migrate:fresh
	docker compose exec app php artisan migrate:refresh
optimize:
	docker compose exec app php artisan optimize
optimize-clear:
	docker compose exec app php artisan optimize:clear
cache:
	docker compose exec app composer dump-autoload -o
	@make optimize
	docker compose exec app php artisan event:cache
	docker compose exec app php artisan view:cache
cache-clear:
	docker compose exec app composer clear-cache
	@make optimize-clear
	docker compose exec app php artisan event:clear
	docker compose exec app php artisan view:clear
db:
	docker compose exec db bash
sql:
	docker compose exec db bash -c 'mysql -u $$MYSQL_USER -p$$MYSQL_PASSWORD $$MYSQL_DATABASE'
redis:
	docker compose exec redis redis-cli
ide-helper:
	docker compose exec app php artisan clear-compiled
	docker compose exec app php artisan ide-helper:generate
	docker compose exec app php artisan ide-helper:meta
	docker compose exec app php artisan ide-helper:models --nowrite
pint:
	docker compose exec app ./vendor/bin/pint -v
pint-test:
	docker compose exec app ./vendor/bin/pint -v --test
