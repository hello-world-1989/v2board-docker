# Thanks ukid
# https://github.com/ukid/v2board-docker

# https://hub.docker.com/r/ukid/v2board/tags

FROM alpine:3.15
RUN apk update
RUN apk add --no-cache bash php7 curl supervisor redis php7-zlib php7-xml php7-phar php7-intl php7-dom php7-xmlreader php7-ctype php7-session php7-mbstring php7-tokenizer php7-gd php7-redis php7-bcmath php7-iconv php7-pdo php7-posix php7-gettext php7-simplexml php7-sodium php7-sysvsem php7-fpm php7-mysqli php7-json php7-openssl php7-curl php7-sockets php7-zip php7-pdo_mysql php7-xmlwriter php7-opcache php7-gmp php7-pdo_sqlite php7-sqlite3 php7-pcntl php7-fileinfo git mailcap libcap

RUN mkdir /www
RUN mkdir /wwwlogs
RUN mkdir -p /run/php
RUN mkdir -p /run/caddy
RUN mkdir -p /run/supervisor

COPY config/php-fpm.conf /etc/php7/php-fpm.d/www.conf
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN apkArch="$(apk --print-arch)"; \
    case "${apkArch}" in \
        aarch64) arch='arm64' ;; \
        x86_64) arch='amd64' ;; \
        *) echo >&2 "error: unsupported architecture: $apkArch"; exit 1 ;; \
    esac; \
    url="https://github.com/caddyserver/caddy/releases/download/v1.0.4/caddy_v1.0.4_linux_${arch}.tar.gz"; \
    curl --silent --show-error --fail --location --header "Accept: application/tar+gzip, application/x-gzip, application/octet-stream" -o - ${url} | tar --no-same-owner -C /usr/bin/ -xz caddy && \
    chmod 0755 /usr/bin/caddy && \
    addgroup -S caddy && \
    adduser -D -S -s /sbin/nologin -G caddy caddy && \
    setcap cap_net_bind_service=+ep `readlink -f /usr/bin/caddy` && \
    /usr/bin/caddy -version

WORKDIR /www
EXPOSE 80
EXPOSE 443

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
