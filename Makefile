# ————————————————
# Makefile for dev
# ————————————————

# デフォルトターゲット
.PHONY: help
help:
	@echo "Usage: make [target]"
	@echo
	@echo "  make install       # composer & npm install"
	@echo "  make init          # 初期化 (Laravel プロジェクト作成)"
	@echo "  make fresh         # DB 初期化 & シーディング"
	@echo "  make app 		    # docker compose exec app bash"
	@echo "  make up            # docker compose up -d"
	@echo "  make down          # docker compose down"
	@echo "  make autoload      # composer dump-autoload"
	@echo "  make migrate       # php artisan migrate"
	@echo "  make test          # backend & frontend のテスト"
	@echo "  make lint          # PHP Pint & ESLint"
	@echo "  make storybook     # Storybook 起動"
	@echo "  make swagger-install # OpenAPI ドキュメント生成のためのインストール"
	@echo "  make build         # フロント／バック本番ビルド"
	@echo "  make generate-server # OpenAPI から Laravel API スタブを生成"
	@echo "  make install-breeze # Breeze インストール"


.PHONY: install
install: composer-install npm-install

.PHONY: composer-install
composer-install:
	docker compose exec app composer install --no-interaction --prefer-dist

.PHONY: npm-install
npm-install:
	docker compose exec app npm install

.PHONY: up
up:
	docker compose up -d

.PHONY: app
app:
	docker compose exec app bash

.PHONY: down
down:
	docker compose down

.PHONY: autoload
autoload:
	docker compose exec app composer dump-autoload


.PHONY: migrate
migrate:
	docker compose exec app php artisan migrate

.PHONY: fresh
fresh:
	docker compose exec app php artisan migrate:fresh --seed

.PHONY: init
init:
	docker compose up -d --build
	@echo "🌿 Create Laravel project (if not exists)"
	docker compose exec app bash -lc '\
	  if [ ! -f artisan ]; then \
	    composer create-project laravel/laravel:^11 /tmp/laravel_tmp --prefer-dist --no-interaction; \
	    cp -R /tmp/laravel_tmp/* .; \
	    cp -R /tmp/laravel_tmp/.* . 2>/dev/null || true; \
	    rm -rf /tmp/laravel_tmp; \
	  fi'	docker compose exec app composer install --no-interaction --prefer-dist
	docker compose exec app npm install
	docker compose exec app cp .env.example .env
	docker compose exec app bash -lc '\
	  if [ -f public/.htaccess.example ]; then \
	    cp public/.htaccess.example public/.htaccess; \
	  fi'
	docker compose exec app php artisan key:generate
	docker compose exec app php artisan storage:link
	@make fresh


.PHONY: test
test:
	# PHPUnit
	docker compose exec app ./vendor/bin/phpunit
	# Vitest
	docker compose exec app npm run test

.PHONY: lint
lint:
	# PHP Pint
	docker compose exec app ./vendor/bin/pint
	# ESLint
	docker compose exec app npm run lint

.PHONY: storybook
storybook:
	docker compose exec app npm run storybook

# .PHONY: swagger
# swagger:
# 	docker compose exec app php artisan l5-swagger:generate

.PHONY: swagger
swagger-install:
	docker compose exec app npm install --save swagger-ui-dist


.PHONY: build
build:
	# フロントビルド
	docker compose exec app npm run build
	# Laravel 設定キャッシュ等
	docker compose exec app php artisan config:cache

.PHONY: generate-server
generate-server:
	@echo "🛠 Generating Laravel API stubs via Docker image"
	docker run --rm \
	  -v "$(PWD)":/local \
	  -u "$(shell id -u):$(shell id -g)" \
	  openapitools/openapi-generator-cli:v7.13.0 \
	    generate \
	      -i /local/openapi.yaml \
	      -g php-laravel \
	      -o /local/app/OpenApiGenerated \
	      --skip-validate-spec \
	      --additional-properties='\
            composerPackageName=your-vendor/your-package,\
            artifactVersion=1.0.0,\
            apiPackage=Http\\Controllers\\Api,\
            modelPackage=Models,\
            invokerPackage=App' \

.PHONY: install-breeze
install-breeze:
	docker compose exec app composer require laravel/breeze --dev
	docker compose exec app php artisan breeze:install vue
	docker compose exec app npm install
	docker compose exec app npm run build
	docker compose exec app php artisan migrate

.PHONY: npm run dev
dev:
	docker compose exec app npm run dev
