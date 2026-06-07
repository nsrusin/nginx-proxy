## nginx-proxy

Универсальный reverse-proxy на **nginx 1.31.1**, собранный из исходников на Alpine с расширенным набором модулей (как у ITGlobal `nginx-proxy`), но с **нативным ACME** (`ngx_http_acme_module`) вместо Certbot/jonasal.

Образ **не привязан к конкретному проекту**. Конфигурация сайтов и stream-маршрутизации монтируется с хоста в `user_conf.d/` и `stream.d/`.

### Модули

Собраны и доступны для подключения через `NGX_MODULES_LOADED`:

| Модуль | Описание |
|--------|----------|
| `ngx_http_acme` | Let's Encrypt / ACMEv2 (всегда загружен) |
| `ngx_http_brotli_filter` / `ngx_http_brotli_static` | Brotli |
| `ngx_http_geoip2` | GeoIP2 (MaxMind DB в образе) |
| `ngx_http_testcookie_access` | Anti-DDoS testcookie |
| `ngx_http_vhost_traffic_status` | VTS + Prometheus `/metrics` |
| `ndk_http`, `ngx_http_lua` | Lua scripting |
| `ngx_http_headers_more_filter` | headers-more |
| ngx_upstream_hc, ngx_dyn_upstream | Healthcheck, dynamic upstream (static) |

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

### Сборка и публикация

GeoIP2 DB скачиваются из публичного mirror при сборке. При необходимости официального MaxMind — передайте ключ на этапе build (`--build-arg MAXMIND_LICENSE_KEY=...`) локально, не коммитьте ключ в репозиторий.

```bash
cd /root/git/others/nginx-proxy
docker build -t s1ncher/nginx-proxy:1.31.1 .
docker tag s1ncher/nginx-proxy:1.31.1 s1ncher/nginx-proxy:latest
docker push s1ncher/nginx-proxy:1.31.1
docker push s1ncher/nginx-proxy:latest
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
