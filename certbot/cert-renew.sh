#!/bin/bash
# 인증서 갱신 
docker run --rm --name certbot \
-v './conf:/etc/letsencrypt' \
-v './logs:/var/log/letsencrypt' \
-v './data:/var/www/certbot' \
certbot/certbot renew --server https://acme-v02.api.letsencrypt.org/directory --cert-nam.