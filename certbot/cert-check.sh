#!/bin/bash
# 인증인 확인
docker run -it --rm --name certbot \
-v './conf:/etc/letsencrypt' \
-v './logs:/var/log/letsencrypt' \
-v './data:/var/www/certbot' \
certbot/certbot certificates