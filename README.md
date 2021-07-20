# docker로 code-server 만들기

## nginx 설정

> nginx/conf.d/default.conf

```conf
# nginx/conf.d/default.conf
server {
    listen 80;
    listen [::]:80;

	server_name {{domain.com}} {{www.domain.com}};

    root /home/nginx/html;
    index index.html index.htm;

    location / {
    }

	#certbot
    location ~ /.well-known/acme-challenge {
        allow all;
        root /var/www/certbot;
    }

	error_page 404 /404;
    location = /404 { # php 404 redirect
    }

    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
    }
}

```

```yml
nginx:
  image: nginx:latest
  container_name: nginx
  hostname: "nginx"
  environment:
    - TZ=Asia/Seoul
    - LANG=ko_KR.UTF-8
    - LANGUAGE=ko_KR.UTF-8
  volumes:
    - ../nginx/nginx.conf:/etc/nginx/nginx.conf:rw
    - ../nginx/conf.d:/etc/nginx/conf.d:rw
    - ../nginx/logs:/var/log/nginx:rw
    - ../code-server/config/workspace/nginx/html:/home/nginx/html:rw
    - ../certbot/data:/var/www/certbot
    - ../certbot/conf:/etc/nginx/ssl
    - /etc/localtime:/etc/localtime:ro
  ports:
    - 80:80
    - 443:443
  restart: unless-stopped
```

- nginx 컨태이너 생성

  `env> docker-compose up code-server`

## Let's Encrypt certbot으로 ssl 인증서 관리

```yml
certbot:
  image: certbot/certbot:latest
  container_name: certbot
  command: certonly --webroot --webroot-path=/var/www/certbot --email {{email}} --agree-tos --no-eff-email -d {{domain.com}} -d {{sub.domain.com}}
  volumes:
    - ../certbot/conf:/etc/letsencrypt
    - ../certbot/logs:/var/log/letsencrypt
    - ../certbot/data:/var/www/certbot
```

- ssl 인증서 생성하기

  `env> docker-com기ose up certbot`

## nginx ssl 설정

```c#
ssl_certificate /etc/nginx/ssl/live/{{domain.com}}/fullchain.pem;
ssl_certificate_key /etc/nginx/ssl/live/{{domain.com}}/privkey.pem;
ssl_trusted_certificate /etc/nginx/ssl/live/h{{domain.com}}/chain.pem;
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header X-Content-Type-Options "nosniff" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
add_header Content-Security-Policy "default-src * data: 'unsafe-eval' 'unsafe-inline'" always;
# add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
# enable strict transport security only if you understand the implications
ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.8.8 8.8.4.4 valid=300s;
resolver_timeout 10s;

```

- {{domain.com}} 인증서경로 변경

## code-server 컨테이너생성

```conf
#nginx/code-server.conf
server {
    listen 443 ssl http2;
    server_name	{{code.domain.com}};
    server_tokens off;

    include /etc/nginx/conf.d/ssl-conf;

    access_log  /var/log/nginx/code-server/access.log  main;
    error_log   /var/log/nginx/code-server/error.log   warn;

    location / {
        proxy_pass	 http://code-server:8443;
        proxy_redirect   off;
        proxy_set_header Host $host;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection upgrade;
        proxy_set_header Accept-Encoding gzip;
    }
}
```

```yml
code-server:
  image: linuxserver/code-server
  container_name: code-server
  hostname: "code-server"
  environment:
    - PUID=1000
    - PGID=100
    - TZ=Asia/Seoul
    - LANG=ko_KR.UTF-8
    - LANGUAGE=ko_KR.UTF-8
    - PASSWORD={{password}}#option
    - SUDO_PASSWORD={{password}}#option
  working_dir: /home/workspace
  volumes:
    - ../code-server/config:/config
  ports:
    #      - 8443:8443
    - 3009:5500
    - 3000-3003:3000-3003
  restart: unless-stopped
```

- code-server 컨태이너 생성
- **{{password}}** 변경

  `env> docker-compose up code-server`

# 최종 docker-compose.yml

```yml
#env/docker-compose.xml
version: "3"

services:
  nginx:
    image: nginx:latest
    container_name: nginx
    hostname: "nginx"
    environment:
      - TZ=Asia/Seoul
      - LANG=ko_KR.UTF-8
      - LANGUAGE=ko_KR.UTF-8
    volumes:
      - ../nginx/nginx.conf:/etc/nginx/nginx.conf:rw
      - ../nginx/conf.d:/etc/nginx/conf.d:rw
      - ../nginx/logs:/var/log/nginx:rw
      - ../code-server/config/workspace/nginx/html:/home/nginx/html:rw
      - ../certbot/data:/var/www/certbot
      - ../certbot/conf:/etc/nginx/ssl
      - /etc/localtime:/etc/localtime:ro
    ports:
      - 80:80
      - 443:443
    #      - 8443:8443
    restart: unless-stopped

  code-server:
    image: linuxserver/code-server
    container_name: code-server
    hostname: "code-server"
    environment:
      - PUID=1000
      - PGID=100
      - TZ=Asia/Seoul
      - LANG=ko_KR.UTF-8
      - LANGUAGE=ko_KR.UTF-8
      - PASSWORD={{password}}#option
      - SUDO_PASSWORD={{password}}#option
    working_dir: /home/workspace
    volumes:
      - ../code-server/config:/config
    ports:
      #      - 8443:8443
      - 3009:5500
      - 3000-3003:3000-3003
    restart: unless-stopped

  certbot:
    image: certbot/certbot:latest
    container_name: certbot
    command: certonly --webroot --webroot-path=/var/www/certbot --email {{email}} --agree-tos --no-eff-email -d {{domain.com}} -d {{sub.domain.com}}
    volumes:
      - ../certbot/conf:/etc/letsencrypt
      - ../certbot/logs:/var/log/letsencrypt
      - ../certbot/data:/var/www/certbot
```
