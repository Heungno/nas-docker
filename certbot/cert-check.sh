#!/bin/bash
# 인증인 확인
docker run -it --rm --name certbot \
-v '/share/homes/docker/certbot/conf:/etc/letsencrypt' \
-v '/share/homes/docker/certbot/logs:/var/log/letsencrypt' \
-v '/share/homes/docker/certbot/data:/var/www/certbot' \
certbot/certbot certificates

