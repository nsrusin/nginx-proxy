Anti-DDOS

- В каждый location, для котрого планируем включать testcookie во время DDOS, добавлем:
```
    testcookie off; ##-AUTO-DDOS-LABEL-##
    limit_req zone=chill burst=3 nodelay; ##-AUTO-LIMIT-REQ-LABEL-##
```
- Для location со статичными файлами, например:
`   location ~* ^.+\.(?:css|map|cur|js|jpeg|jpg|gif|htc|ico|png|otf|ttf|eot|woff|woff2|svg|webp)$`
`   location ~ /wp-content/uploads/(?<path>.+)\.(?<ext>jpe?g|png|gif)$`
достаточно добавить:
`    limit_req zone=static burst=100 nodelay;`

- В конфиг каждого защищаемого сайта добавляем:
```
location = /aes.min.js {
    gzip on;
    gzip_min_length 1000;
    gzip_types text/plain;
    gzip_static on;
    root /var/www/html/anti-ddos/;
}
```
- В начало секции server конфигов защищаемых сайтов добавляем. Для каждого из них нужно указать уникальный ${testcookie_name} (в 2 местах) и ${testcookie_secret} = рандом из 64 символов.
```
    # Anti-DDOS measures

    testcookie_name ${testcookie_name};
    testcookie_secret ${testcookie_secret};
    include /etc/nginx/app/include.testcookie;
    #HTML check
    testcookie_refresh_template '<html><body><script>document.cookie="${testcookie_name}=$testcookie_set";location.href="$testcookie_nexturl";</script></body></html>';

    # /Anti-DDOS
```
