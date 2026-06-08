## nginx-proxy

Универсальный reverse-proxy на **nginx**, собранный из исходников на Alpine с расширенным набором модулей и **нативным ACME** (`ngx_http_acme_module`).

Образ **не привязан к конкретному проекту**. Конфигурация сайтов и stream-маршрутизации монтируется с хоста в `user_conf.d/` и `stream.d/`.

### Модули

Собраны и доступны для подключения через `NGX_MODULES_LOADED`:

| Модуль | Описание |
|--------|----------|
| `ngx_http_acme` | Let's Encrypt / ACMEv2 (всегда загружен) |
| `ngx_http_brotli_filter` / `ngx_http_brotli_static` | Brotli |
| `ngx_http_geoip2` | GeoIP2 (GeoLite2 DB в образе) |
| `ngx_http_testcookie_access` | Anti-DDoS testcookie |
| `ngx_http_vhost_traffic_status` | VTS + Prometheus `/metrics` |
| `ndk_http`, `ngx_http_lua` | Lua scripting |
| `ngx_http_headers_more_filter` | headers-more |
| ngx_upstream_hc, ngx_dyn_upstream | Healthcheck, dynamic upstream (static) |

GeoLite2 Country/City скачиваются при сборке из публичного mirror (`GEOLITE_MIRROR_BASE` в CI).

### Переменные окружения

| Variable | Default | Description |
|----------|---------|-------------|
| `ACME_EMAIL` | — | **Обязательно.** Email для Let's Encrypt |
| `ACME_STAGING` | `0` | `1` — staging LE |
| `NGX_MODULES_LOADED` | `ngx_http_brotli_filter` | Список модулей через запятую |
| `NGX_IPV6_ENABLED` | `false` | IPv6 для default-серверов |
| `NGX_LEVYUE_SITES_REJECTED` | `true` | Default TLS reject для неизвестных SNI |

### Тома и конфигурация

| Путь в контейнере | Назначение |
|-------------------|------------|
| `/etc/nginx/user_conf.d/` | Ваши `server { }` блоки (прокси, ACME-сертификаты) |
| `/etc/nginx/stream.d/` | Stream/SNI-маршрутизация (опционально) |
| `/var/cache/nginx/acme-letsencrypt` | Состояние ACME (volume) |

В `user_conf.d` для HTTPS используйте issuer `letsencrypt` из базового `nginx.conf`:

```nginx
server {
    listen 443 ssl;
    server_name example.com;

    acme_certificate letsencrypt;
    ssl_certificate     $acme_certificate;
    ssl_certificate_key $acme_certificate_key;
    ssl_certificate_cache max=2;
    include ssl_params;

    location / {
        proxy_pass http://127.0.0.1:8080;
    }
}
```

Порт **80** занят redirector-ом (HTTP→HTTPS + `/nginx_status`). HTTP-01 challenges обрабатывает модуль ACME автоматически.

### CI/CD

Сборка, линтеры, Trivy-скан и push в Docker Hub — GitHub Actions (`.github/workflows/docker.yml`).

Перед сборкой job **lint** проверяет:
- **actionlint** — workflow-файлы
- **hadolint** — `Dockerfile` (конфиг `.hadolint.yaml`)
- **shellcheck** — скрипты в `src/scripts/`

Версии nginx, модулей и GeoLite2 mirror заданы в `env` workflow-файла и передаются в `docker build` через `build-args`.

| Событие | Теги в Docker Hub |
|---------|-------------------|
| PR → `main` | `s1ncher/nginx-proxy:<version>-pr<N>` |
| push в `main` | `s1ncher/nginx-proxy:<version>`, `:latest` |

Секреты репозитория: `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`.

### Локальная сборка

Передайте те же `build-arg`, что в workflow (см. `.github/workflows/docker.yml`), например:

```bash
cd /root/git/others/nginx-proxy
docker build \
  --build-arg NGINX_VERSION=1.31.1 \
  --build-arg GPP_VER=15.2.0-r2 \
  --build-arg LUAROCS_VER=3.13.0 \
  --build-arg LIBMAXMINDDB_VERSION=1.13.3 \
  --build-arg GEOLITE_MIRROR_BASE=https://raw.githubusercontent.com/8bitsaver/maxmind-geoip/release \
  --build-arg NGX_BROTLI_COMMIT=a71f9312c2deb28875acc7bacfdd5695a111aa53 \
  --build-arg NGX_TESTCOOKIE_COMMIT=7d263d4322b7de6b99b486e5e10ecaf0295890ad \
  --build-arg NGX_GEOIP2_COMMIT=cbaa35461c62a99d2577e6bae3273492502d8769 \
  --build-arg NGX_VTS_COMMIT=b2a036ab6c1ffd5615f9ea57d6710287590735cd \
  --build-arg NGX_UPSTREAM_HC_TAG=1.3.8 \
  --build-arg NGX_DYNAMIC_UPSTREAM_TAG=2.3.5 \
  --build-arg NGX_LUAJIT_TAG=v2.1-20260415 \
  --build-arg NGX_DEVELKIT_TAG=v0.3.4 \
  --build-arg NGX_LUA_TAG=v0.10.29 \
  --build-arg NGX_LUA_RCORE_TAG=v0.1.32 \
  --build-arg NGX_LUA_LRUC_TAG=v0.15 \
  --build-arg NGX_HEADERS_MORE_TAG=v0.39 \
  --build-arg NGX_ACME_TAG=v0.4.0 \
  -t s1ncher/nginx-proxy:1.31.1 .
```

### Пример запуска

```bash
docker run -d --name nginx-proxy --restart unless-stopped \
  --network host \
  -e ACME_EMAIL=admin@example.com \
  -v nginx-acme:/var/cache/nginx/acme-letsencrypt \
  -v /opt/nginx-proxy/user_conf.d:/etc/nginx/user_conf.d:ro \
  -v /opt/nginx-proxy/stream.d:/etc/nginx/stream.d:ro \
  s1ncher/nginx-proxy:1.31.1
```

Пример проектной конфигурации (Grafana + SNI mux с Xray): роль `nginx_proxy` в репозитории `others/vpn-grafana`.
