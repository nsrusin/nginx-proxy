#!/bin/sh
set -eu

/scripts/templator.py /templates/nginx.conf.j2 /etc/nginx/nginx.conf
/scripts/templator.py /templates/redirector.conf.j2 /etc/nginx/conf.d/redirector.conf
