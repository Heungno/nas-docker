#!/bin/bash
# 인증서 갱신 
docker run --rm --name certbot \
-v '/share/homes/docker/certbot/conf:/etc/letsencrypt' \
-v '/share/homes/docker/certbot/logs:/var/log/letsencrypt' \
-v '/share/homes/docker/certbot/data:/var/www/certbot' \
certbot/certbot renew --server https://acme-v02.api.letsencrypt.org/directory --cert-name {{domain.com}}