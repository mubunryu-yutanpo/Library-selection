# Dockerfile
FROM php:8.2-apache

# 必要なパッケージ＋Node.js/NPM を追加（npm でビルドツールを使いたい場合）
RUN apt-get update \
  && apt-get install -y curl git unzip libzip-dev libonig-dev libpng-dev \
  && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get install -y nodejs \
  && docker-php-ext-install pdo_mysql zip mbstring \
  && a2enmod rewrite

# Apache のドキュメントルートを public 配下に変更
RUN sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/*.conf

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# ホストのコードをそのままマウントする想定なので、COPY は不要
