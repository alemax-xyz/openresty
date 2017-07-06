FROM library/ubuntu:xenial AS build

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
RUN apt-get update && \
    apt-get install -y \
        python-software-properties \
        software-properties-common \
        apt-utils \
        wget

RUN wget -qO - https://openresty.org/package/pubkey.gpg | apt-key add - && \
    add-apt-repository -y "deb http://openresty.org/package/ubuntu xenial main" && \
    apt-get update

RUN mkdir -p /build/image
WORKDIR /build
RUN apt-get download \
    openresty \
    openresty-openssl \
    openresty-pcre \
    openresty-zlib
RUN for file in *.deb; do dpkg-deb -x ${file} image/; done

WORKDIR /build/image
RUN rm -rf \
        etc/* \
        lib/* \
        usr/share/* \
        usr/local/openresty/luajit/include \
        usr/local/openresty/luajit/lib/pkgconfig \
        usr/local/openresty/nginx/conf/*.default \
        usr/local/openresty/nginx/sbin/stap-nginx \
        usr/local/openresty/nginx/tapset && \
    mkdir -p var/log && \
    ln -s /usr/local/openresty/nginx/conf etc/nginx && \
    ln -s /usr/local/openresty/nginx/logs var/log/nginx && \
    ln -s /dev/stderr usr/local/openresty/nginx/logs/error.log  && \
    ln -s /dev/stdout usr/local/openresty/nginx/logs/access.log  && \
    sed -i -r \
        -e 's,^ *[#;]? *user *.*$,user root root;,g' \
        -e 's,^ *[#;]? *worker_processes *.*$,worker_processes auto;,g' \
        usr/local/openresty/nginx/conf/nginx.conf


FROM clover/base

WORKDIR /
COPY --from=build /build/image /

CMD ["openresty", "-g", "daemon off;"]

EXPOSE 80 443
