# ————————————————
# Makefile for dev
# ————————————————

# デフォルトターゲット
.PHONY: help
help:
	@echo "Usage: make [target]"
	@echo
	@echo "  make install       # composer & npm install"
	@echo "  make up            # docker compose up -d --build"
	@echo "  make down          # docker compose down"
	@echo "  make migrate       # php artisan migrate"
	@echo "  make test          # backend & frontend のテスト"
	@echo "  make lint          # PHP Pint & ESLint"
	@echo "  make storybook     # Storybook 起動"
	@echo "  make swagger       # OpenAPI ドキュメント生成"
	@echo "  make build         # フロント／バック本番ビルド"
	@echo

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
	docker compose up -d --build

.PHONY: app
app:
	docker compose up -d


.PHONY: down
down:
	docker compose down

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

.PHONY: swagger
swagger:
	docker compose exec app php artisan l5-swagger:generate

.PHONY: build
build:
	# フロントビルド
	docker compose exec app npm run build
	# Laravel 設定キャッシュ等
	docker compose exec app php artisan config:cache
