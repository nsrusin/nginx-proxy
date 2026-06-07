ARG NGINX_VERSION=1.31.1
FROM nginx:${NGINX_VERSION}-alpine

ARG PIP_JINJA2_VERSION=3.1.6

ENV NGX_BROTLI_REPO=https://github.com/google/ngx_brotli.git \
    NGX_BROTLI_COMMIT=a71f9312c2deb28875acc7bacfdd5695a111aa53 \
    NGX_BROTLI_PATH=ngx_brotli

ENV NGX_TESTCOOKIE_REPO=https://github.com/kyprizel/testcookie-nginx-module.git \
    NGX_TESTCOOKIE_COMMIT=7d263d4322b7de6b99b486e5e10ecaf0295890ad \
    NGX_TESTCOOKIE_PATH=testcookie-nginx-module

ENV NGX_GEOIP2_REPO=https://github.com/leev/ngx_http_geoip2_module.git \
    NGX_GEOIP2_COMMIT=cbaa35461c62a99d2577e6bae3273492502d8769 \
    NGX_GEOIP2_PATH=ngx_http_geoip2_module

ENV LIBMAXMINDDB_VERSION=1.13.3 \
    LIBMAXMINDDB_PATH=libmaxminddb

ENV NGX_VTS_REPO=https://github.com/vozlt/nginx-module-vts.git \
    NGX_VTS_COMMIT=b2a036ab6c1ffd5615f9ea57d6710287590735cd \
    NGX_VTS_PATH=ngx_vts

ENV MAXMIND_PATH=GeoIP2 \
    MAXMIND_CITY_PATH=GeoIP2City

ENV NGX_UPSTREAM_HC_TAG=1.3.8 \
    NGX_UPSTREAM_HC_MODULE_PATH=ngx_upstream_hc \
    NGX_UPSTREAM_HC_MODULE_REPO=https://github.com/ZigzagAK/ngx_dynamic_healthcheck.git

ENV NGX_DYNAMIC_UPSTREAM_TAG=2.3.5 \
    NGX_DYNAMIC_UPSTREAM_MODULE_PATH=ngx_dyn_upstream \
    NGX_DYNAMIC_UPSTREAM_MODULE_REPO=https://github.com/ZigzagAK/ngx_dynamic_upstream.git

ENV NGX_LUAJIT_TAG=v2.1-20260415 \
    NGX_LUAJIT_PATH=ngx_luajit \
    NGX_LUAJIT_REPO=https://github.com/openresty/luajit2.git

ENV NGX_DEVELKIT_TAG=v0.3.4 \
    NGX_DEVELKIT_PATH=ngx_develkit \
    NGX_DEVELKIT_REPO=https://github.com/vision5/ngx_devel_kit.git

ENV NGX_LUA_TAG=v0.10.29 \
    NGX_LUA_PATH=ngx_lua \
    NGX_LUA_REPO=https://github.com/openresty/lua-nginx-module.git

ENV NGX_LUA_RCORE_TAG=v0.1.32 \
    NGX_LUA_RCORE_PATH=ngx_lua_rcore \
    NGX_LUA_RCORE_REPO=https://github.com/openresty/lua-resty-core.git

ENV NGX_LUA_LRUC_TAG=v0.15 \
    NGX_LUA_LRUC_PATH=ngx_lua_lruc \
    NGX_LUA_LRUC_REPO=https://github.com/openresty/lua-resty-lrucache.git

ENV NGX_HEADERS_MORE_TAG=v0.39 \
    NGX_HEADERS_MORE_PATH=ngx_headers_more \
    NGX_HEADERS_MORE_REPO=https://github.com/openresty/headers-more-nginx-module.git

ENV NGX_ACME_REPO=https://github.com/nginx/nginx-acme.git \
    NGX_ACME_TAG=v0.4.0 \
    NGX_ACME_PATH=ngx_acme

ENV LUAROCS_VER=3.13.0
ENV LUAROCS_PREFIX=/usr/local
ENV LUAROCS_PKG_DIR=${LUAROCS_PREFIX}/share/lua/5.1
ENV GPP_VER=15.2.0-r2

ENV LUAJIT_PREFIX=/usr/local
ENV LUAJIT_LIB=${LUAJIT_PREFIX}/lib
ENV LUAJIT_INC=${LUAJIT_PREFIX}/include/luajit-2.1

ENV NGX_ACME_STATE_PREFIX=/var/cache/nginx

WORKDIR /tmp

RUN set -euo pipefail && \
    apk update --no-cache && \
    apk upgrade --no-cache && \
    apk add --no-cache curl \
                        openssl \
                        lua5.1-dev \
                        g++=${GPP_VER} \
                        wget \
                        py3-jinja2 \
                        bash && \
    apk add --no-cache --virtual .build-deps \
    libc-dev \
    make \
    openssl-dev \
    pcre2-dev \
    zlib-dev \
    linux-headers \
    libxslt-dev \
    gd-dev \
    geoip-dev \
    libedit-dev \
    bash \
    alpine-sdk \
    findutils \
    perl-dev \
    brotli-dev \
    git \
    cargo \
    rust \
    clang-dev \
    pkgconf && \
    wget "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" -O nginx.tar.gz && \
    git clone ${NGX_BROTLI_REPO} "${NGX_BROTLI_PATH}-${NGX_BROTLI_COMMIT}" && \
    cd "${NGX_BROTLI_PATH}-${NGX_BROTLI_COMMIT}" && git reset --hard "${NGX_BROTLI_COMMIT}" && \
    git submodule update --init && cd .. && \
    git clone ${NGX_TESTCOOKIE_REPO} "${NGX_TESTCOOKIE_PATH}-${NGX_TESTCOOKIE_COMMIT}" && \
    cd "${NGX_TESTCOOKIE_PATH}-${NGX_TESTCOOKIE_COMMIT}" && git reset --hard "${NGX_TESTCOOKIE_COMMIT}" && cd .. && \
    git clone ${NGX_GEOIP2_REPO} "${NGX_GEOIP2_PATH}-${NGX_GEOIP2_COMMIT}" && \
    cd "${NGX_GEOIP2_PATH}-${NGX_GEOIP2_COMMIT}" && git reset --hard "${NGX_GEOIP2_COMMIT}" && cd .. && \
    git clone ${NGX_VTS_REPO} "${NGX_VTS_PATH}-${NGX_VTS_COMMIT}" && \
    cd "${NGX_VTS_PATH}-${NGX_VTS_COMMIT}" && git reset --hard "${NGX_VTS_COMMIT}" && cd .. && \
    git clone -b ${NGX_UPSTREAM_HC_TAG} --depth 1 "${NGX_UPSTREAM_HC_MODULE_REPO}" "${NGX_UPSTREAM_HC_MODULE_PATH}-${NGX_UPSTREAM_HC_TAG}" && \
    git clone -b ${NGX_DYNAMIC_UPSTREAM_TAG} --depth 1 "${NGX_DYNAMIC_UPSTREAM_MODULE_REPO}" "${NGX_DYNAMIC_UPSTREAM_MODULE_PATH}-${NGX_DYNAMIC_UPSTREAM_TAG}" && \
    git clone -b ${NGX_LUAJIT_TAG} --depth 1 ${NGX_LUAJIT_REPO} ${NGX_LUAJIT_PATH}-${NGX_LUAJIT_TAG} && \
    git clone -b ${NGX_DEVELKIT_TAG} --depth 1 ${NGX_DEVELKIT_REPO} ${NGX_DEVELKIT_PATH}-${NGX_DEVELKIT_TAG} && \
    git clone -b ${NGX_LUA_TAG} --depth 1 ${NGX_LUA_REPO} ${NGX_LUA_PATH}-${NGX_LUA_TAG} && \
    git clone -b ${NGX_LUA_RCORE_TAG} --depth 1 ${NGX_LUA_RCORE_REPO} ${NGX_LUA_RCORE_PATH}-${NGX_LUA_RCORE_TAG} && \
    git clone -b ${NGX_LUA_LRUC_TAG} --depth 1 ${NGX_LUA_LRUC_REPO} ${NGX_LUA_LRUC_PATH}-${NGX_LUA_LRUC_TAG} && \
    git clone -b ${NGX_HEADERS_MORE_TAG} --depth 1 ${NGX_HEADERS_MORE_REPO} ${NGX_HEADERS_MORE_PATH}-${NGX_HEADERS_MORE_TAG} && \
    git clone -b ${NGX_ACME_TAG} --depth 1 ${NGX_ACME_REPO} "${NGX_ACME_PATH}-${NGX_ACME_TAG}" && \
    wget "https://github.com/maxmind/libmaxminddb/releases/download/${LIBMAXMINDDB_VERSION}/libmaxminddb-${LIBMAXMINDDB_VERSION}.tar.gz" -O ${LIBMAXMINDDB_PATH}.tar.gz && \
    wget "http://luarocks.github.io/luarocks/releases/luarocks-${LUAROCS_VER}.tar.gz" -O luarocks.tar.gz && \
    curl -L -o GeoLite2-Country.mmdb "https://raw.githubusercontent.com/8bitsaver/maxmind-geoip/release/GeoLite2-Country.mmdb" && \
    mv -f GeoLite2-Country.mmdb /usr/share/GeoLite2-Country.mmdb && \
    test -s /usr/share/GeoLite2-Country.mmdb && \
    curl -L -o GeoLite2-City.mmdb "https://raw.githubusercontent.com/8bitsaver/maxmind-geoip/release/GeoLite2-City.mmdb" && \
    mv -f GeoLite2-City.mmdb /usr/share/GeoLite2-City.mmdb && \
    test -s /usr/share/GeoLite2-City.mmdb && \
    cd ${NGX_LUAJIT_PATH}-${NGX_LUAJIT_TAG} && make PREFIX=${LUAJIT_PREFIX} && make install && \
    cd ../${NGX_LUA_RCORE_PATH}-${NGX_LUA_RCORE_TAG} && make install LUA_LIB_DIR=${LUAROCS_PKG_DIR} && \
    cd ../${NGX_LUA_LRUC_PATH}-${NGX_LUA_LRUC_TAG} && make install LUA_LIB_DIR=${LUAROCS_PKG_DIR} && \
    cd ../ && \
    tar -zxf ${LIBMAXMINDDB_PATH}.tar.gz && \
    cd libmaxminddb-${LIBMAXMINDDB_VERSION} && \
    ./configure && make && make install && ldconfig ./ && \
    cd ../ && \
    tar -zxf luarocks.tar.gz && \
    cd luarocks-${LUAROCS_VER} && \
    ./configure \
        --prefix=${LUAROCS_PREFIX} \
        --with-lua=${LUAJIT_PREFIX} \
        --with-lua-include=${LUAJIT_INC} && \
    make build && \
    make install && \
    cd ../ && \
    tar -zxf nginx.tar.gz && \
    cd nginx-$NGINX_VERSION && \
    NGX_ACME_STATE_PREFIX=${NGX_ACME_STATE_PREFIX} ./configure \
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --modules-path=/usr/lib/nginx/modules \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/var/run/nginx.pid \
        --lock-path=/var/run/nginx.lock \
        --http-client-body-temp-path=/var/cache/nginx/client_temp \
        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
        --with-perl_modules_path=/usr/lib/perl5/vendor_perl \
        --user=nginx \
        --group=nginx \
        --with-file-aio \
        --with-threads \
        --with-http_addition_module \
        --with-http_auth_request_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_mp4_module \
        --with-http_random_index_module \
        --with-http_realip_module \
        --with-http_secure_link_module \
        --with-http_slice_module \
        --with-http_ssl_module \
        --with-http_stub_status_module \
        --with-http_sub_module \
        --with-http_v2_module \
        --with-http_v3_module \
        --with-ipv6 \
        --with-mail \
        --with-mail_ssl_module \
        --with-stream \
        --with-stream_realip_module \
        --with-stream_ssl_module \
        --with-stream_ssl_preread_module \
        --with-cc-opt='-Os -Wformat -Werror=format-security -g' \
        --with-ld-opt="-Wl,--as-needed,-O1,--sort-common -Wl,-z,pack-relative-relocs,-rpath,${LUAJIT_LIB}" \
        --with-compat \
        --add-dynamic-module="$(pwd)/../${NGX_BROTLI_PATH}-${NGX_BROTLI_COMMIT}" \
        --add-dynamic-module="$(pwd)/../${NGX_TESTCOOKIE_PATH}-${NGX_TESTCOOKIE_COMMIT}" \
        --add-dynamic-module="$(pwd)/../${NGX_GEOIP2_PATH}-${NGX_GEOIP2_COMMIT}" \
        --add-dynamic-module="$(pwd)/../${NGX_VTS_PATH}-${NGX_VTS_COMMIT}" \
        --add-dynamic-module="$(pwd)/../${NGX_DEVELKIT_PATH}-${NGX_DEVELKIT_TAG}" \
        --add-dynamic-module="$(pwd)/../${NGX_LUA_PATH}-${NGX_LUA_TAG}" \
        --add-dynamic-module="$(pwd)/../${NGX_HEADERS_MORE_PATH}-${NGX_HEADERS_MORE_TAG}" \
        --add-dynamic-module="$(pwd)/../${NGX_ACME_PATH}-${NGX_ACME_TAG}" \
        --add-module="$(pwd)/../${NGX_UPSTREAM_HC_MODULE_PATH}-${NGX_UPSTREAM_HC_TAG}"  \
        --add-module="$(pwd)/../${NGX_DYNAMIC_UPSTREAM_MODULE_PATH}-${NGX_DYNAMIC_UPSTREAM_TAG}" && \
    make modules && make && make install && \
    cd ../ && \
    apk del .build-deps && \
    rm -rf /tmp/* && \
    mkdir -p /etc/nginx/app \
             /etc/nginx/user_conf.d \
             /etc/nginx/stream.d \
             /var/www/html/anti-ddos \
             /var/cache/nginx/acme-letsencrypt \
             /templates && \
    printf '%s\n' '# mount your site configs over this directory' > /etc/nginx/user_conf.d/00-placeholder.conf && \
    printf '%s\n' '# mount stream configs here (optional)' > /etc/nginx/stream.d/00-placeholder.conf && \
    touch /etc/nginx/env.conf && \
    chown -R nginx:nginx /var/cache/nginx

WORKDIR /etc/nginx

ENV NGX_MODULES_AVAILABLE="ngx_http_acme,ngx_http_brotli_filter,ngx_http_brotli_static,ngx_http_geoip2,ngx_http_testcookie_access,ngx_http_vhost_traffic_status,ndk_http,ngx_http_lua,ngx_http_headers_more_filter"
ENV NGX_MODULES_LOADED="ngx_http_brotli_filter"
ENV NGX_LEVYUE_SITES_REJECTED=true
ENV NGX_IPV6_ENABLED=false

ENV LUA_PATH=${LUAROCS_PKG_DIR}/?.lua;${LUAROCS_PKG_DIR}/?/init.lua;${LUAJIT_PREFIX}/share/luajit-2.1/?.lua;;
ENV LUA_CPATH=${LUAJIT_PREFIX}/lib/lua/5.1/?.so;${LUAJIT_PREFIX}/lib/lua/5.1/loadall.so;;

COPY ssl_params /etc/nginx/
COPY templates/ /templates/
COPY anti-ddos/include.testcookie anti-ddos/whitelist.lst /etc/nginx/app/
COPY anti-ddos/aes.min.js.txt /var/www/html/anti-ddos/aes.min.js
COPY --chmod=750 src/scripts/templator.py /scripts/
COPY --chmod=750 src/scripts/40-acme-env.envsh src/scripts/50-prep-default-config.sh /docker-entrypoint.d/

HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
    CMD curl --silent --fail http://localhost/nginx_status --output /dev/null || exit 1
