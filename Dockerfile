# Choose the desired PHP version
# Choices available at https://hub.docker.com/_/php/ stick to "-cli" versions recommended
FROM php:8.0-cli

MAINTAINER Adam Culp <adamculp@uws.net>

ENV TARGET_DIR="/usr/local/lib/php-code-quality" \
    COMPOSER_ALLOW_SUPERUSER=1 \
    TIMEZONE=America/New_York \
    PHP_MEMORY_LIMIT=512M

RUN mkdir -p $TARGET_DIR

WORKDIR $TARGET_DIR

COPY composer-installer.sh $TARGET_DIR/
COPY composer-wrapper.sh /usr/local/bin/composer

RUN apt-get update && \
    apt-get install -y wget && \
    apt-get install -y zip && \
    apt-get install -y git && \
    apt-get install -y libxml2-dev && \
    docker-php-ext-install xml

RUN chmod 744 $TARGET_DIR/composer-installer.sh
RUN chmod 744 /usr/local/bin/composer

# Run composer installation of needed tools
RUN $TARGET_DIR/composer-installer.sh && \
   composer selfupdate || true && \
   composer init --name dokify/php-code-quality && \
   composer require --prefer-stable --prefer-dist \
       "squizlabs/php_codesniffer" \
       "phpunit/phpunit" \
       "phploc/phploc" \
       "pdepend/pdepend" \
       "phpmd/phpmd" \
       "sebastian/phpcpd" \
       "friendsofphp/php-cs-fixer" \
       "phpcompatibility/php-compatibility" \
       "phpmetrics/phpmetrics" \
       "phpstan/phpstan"
