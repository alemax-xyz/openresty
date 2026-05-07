FROM library/debian:stable-slim AS build

ENV LANG=C.UTF-8

RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get update

RUN echo "deb [trusted=true] http://openresty.org/package/debian bookworm openresty" > /etc/apt/sources.list.d/openresty.list \
 && apt-get update

RUN mkdir -p /build /rootfs
WORKDIR /build
RUN apt-get download \
        openresty \
        openresty-openssl3 \
        openresty-pcre2 \
        openresty-zlib
RUN find *.deb | xargs -I % dpkg-deb -x % /rootfs

WORKDIR /rootfs

RUN rm -rf \
        etc/* \
        lib \
        usr/share \
        usr/local/openresty/luajit/include \
        usr/local/openresty/luajit/lib/pkgconfig \
        usr/local/openresty/nginx/conf/*.default \
 && mkdir -p var/log \
 && ln -s /usr/local/openresty/nginx/conf etc/nginx \
 && ln -s /usr/local/openresty/nginx/logs var/log/nginx \
 && ln -s /dev/stderr usr/local/openresty/nginx/logs/error.log \
 && ln -s /dev/stdout usr/local/openresty/nginx/logs/access.log \
 && sed -i -r \
        -e 's,^ *[#;]? *user *.*$,user root root;,g' \
        -e 's,^ *[#;]? *worker_processes *.*$,worker_processes auto;,g' \
        usr/local/openresty/nginx/conf/nginx.conf

COPY etc/ etc/
COPY usr/ usr/

WORKDIR /

FROM clover/base

ENV LANG=C.UTF-8 \
    OPENRESTY_DIRECTIVES="error_log /dev/stderr warn;"

COPY --from=build /rootfs /

EXPOSE 80 443
