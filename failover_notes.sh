#!/bin/bash

docker run -d --name app --restart=on-failure:5 -v /var/log/nginx/:/var/log/nginx/ -v /var/lib/mysql:/var/lib/mysql -v /tmp:/tmp -p 8080:80 -e "SECRET_KEY_BASE=foo" -e "UNICORN_NAME=unicorn.sock" --link mysql:webdb inertialbox/inertialbox-app


docker build -t inertialbox/rails-nginx-unicorn-failover rails-nginx-unicorn-failover
docker build -t inertialbox/inertialbox-app-failover ~/hack/inertialbox.com_failover


docker run -d --name app-failover -v /var/log/nginx-app-failover/:/var/log/nginx/ -v /tmp:/tmp -p 8081:80 -e "SECRET_KEY_BASE=foo2" --link mysql:webdb inertialbox/inertialbox-app-failover


docker build -t inertialbox/nginx-load-balancer nginx-load-balancer
docker run -d --name load-balancer -v /var/log/nginx-load-balancer/:/var/log/nginx/ -p 80:80 inertialbox/nginx-load-balancer
