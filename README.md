# docker-lamp 🐳

## 概要

docker-compose を使用して、シンプルな LAMP (Laravel、Apache、MySQL、PHP) 開発環境を構築します。

Windows(WSL2)、macOS(M1)、Linuxに対応。

## コンテナ構成

```text
├── app
├── db
└── adminer
```

### app コンテナ

- Base image
  - [php:8.2-apache](https://hub.docker.com/_/php):8.2-apache
  - [composer](https://hub.docker.com/_/composer):2.7

### db コンテナ

- Base image
  - [mysql/mysql-server](https://hub.docker.com/r/mysql/mysql-server):8.0

### adminer コンテナ

- Base image
  - [adminer](https://hub.docker.com/_/adminer)

## ディレクトリ構成

```text
.
├── src # Laravelプロジェクトのルートディレクトリ
├── infra
│     └── docker
│          ├── mysql
│          │   ├── Dockerfile
│          │   └── my.cnf
│          └── php
│              ├── 000-default.conf
│              ├── Dockerfile
│              ├── entrypoint.sh
│              ├── php.deploy.ini
│              ├── php.development.ini
│              └── xdebug.ini
├── Makefile
└── compose.yaml
```

## 使い方

### A. Laravelプロジェクトの新規作成

プロジェクトフォルダにGitクローンする

```bash
git clone https://xacro.backlog.jp/git/XACRO/docker-lamp.git .
```

以下のコマンドを実行

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
$ docker compose exec app php artisan migrate:fresh
```

上記のコマンドがエラーなく終了したら <http://localhost> でアクセスできるようになるはず。

※最新のLaravelバージョンがインストールされます。

### A'. Laravelプロジェクトをバージョン指定して新規作成

バージョンを指定したい場合の手順です。

※php.8.2と互換性のないバージョンを指定するとエラーが発生する可能性があります。
<https://readouble.com/laravel/11.x/ja/releases.html>

```bash
$ git clone https://xacro.backlog.jp/git/XACRO/docker-lamp.git .
$ mkdir -p src
$ docker compose build
$ make up
$ docker compose exec app gosu $(whoami) bash -c "\
    composer create-project --prefer-dist 'laravel/laravel=9.*' . && \
    php artisan key:generate && \
    php artisan storage:link && \
    chmod -R 777 storage bootstrap/cache && \ 
    php artisan migrate"
```

上記のコマンドがエラーなく終了したら <http://localhost> でアクセスできるようになるはず。

### B. 既存のLaravelプロジェクトの環境を構築する

プロジェクトフォルダにGitクローンする

```bash
git clone https://xacro.backlog.jp/git/XACRO/docker-lamp.git .
```

src フォルダの配下に既存のLaravelプロジェクトを配置する

```bash
$ mkdir -p src
$ cp -r /path/to/your/laravel-project src

# or...

git clone https://github.com/[account name]/[repository name].git ./src
```

以下のコマンドを実行

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
$ docker compose exec app php artisan migrate:fresh
```

上記のコマンドがエラーなく終了したら <http://localhost> でアクセスできるようになるはず。

※プロジェクトの構成によっては、追加の設定が必要な場合があります。

## コンテナの実行ユーザーとホストの実行ユーザーを同じにする

`make` コマンドを使用した場合のみ、ホストユーザーの UID、GID、および USERNAME をコンテナー実行ユーザーと同じにすることができます。

`docker compose` コマンドで直接実行した場合は、ホストユーザーとコンテナー実行ユーザーが異なるため、ファイルのパーミッションが正しく設定されない可能性があります。

## 基本コマンド

```bash
# コンテナを起動する
$ make up

# or...

$ docker compose up -d

# コンテナを終了する
$ make down

# or...

$ docker compose down

# コンテナ、イメージ、ボリュームを破棄する
$ make destroy

# or...

$ docker compose down --rmi all --volumes

# コンテナ、ボリュームを破棄する
$ make down-v

# or...

$ docker compose down --volumes

```

### 非root ユーザーとしてappコンテナにログイン

```bash
$ make app
docker compose exec app gosu username bash
username@a5a88db461e9:/var/www/html$
```

### root ユーザーとしてappコンテナにログイン

```bash
$ docker compose exec app bash
root@a5a88db461e9:/var/www/html#
```

### dbコンテナのMySQLに接続する

```bash
$ make sql

# or...

$ docker compose exec db bash -c 'mysql -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE'
```

### Laravelのマイグレーションを実行する

```bash
# migrate
$ make migrate

# or...

docker compose exec app php artisan migrate

# all drop table & migrate & seeding
$ make fresh

# or...

docker compose exec app php artisan migrate:fresh --seed

# seeding
$ make seed

# or...

docker compose exec app php artisan db:seed

```

### テストの実行

```bash
$ make test

# or...

docker compose exec app php artisan test
```

## adminer

<http://localhost:8888> でデータベース管理ツールadminerにアクセスできます。
ログイン情報は以下の通りです。

```text
username: root
password: password
database: laravel
```

## コードエディターの機能拡張

WSLのファイルをVSCodeで編集できるようにするために、拡張プラグイン[WSL](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl)を入れる。

## その他

- vagrantの環境を継続して使用したい場合は、Virtual Boxのバージョンをv6.1にアップデートしてください。

- 上記ドキュメントの中で不明点や間違っている点などあれば、遠慮なくご指摘ください。

Docker公式ドキュメント
[Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
