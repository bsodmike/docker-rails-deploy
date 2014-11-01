#!/bin/bash

ORG=inertialbox

docker images | grep "^${ORG}/nginx-load-balancer" > /dev/null 2>&1
[ $? -ne 0 ] && echo -e "\n===> Building image for the load balancer.\n" && docker build -t inertialbox/nginx-load-balancer nginx-load-balancer

docker ps -a | grep "[^\-]load-balancer" > /dev/null 2>&1
[ $? -ne 0 ] && echo -e "\n===> Running the load balancer.\n" && docker run -d --name load-balancer -v /var/log/nginx-load-balancer/:/var/log/nginx/ -p 80:80 inertialbox/nginx-load-balancer

echo -e "\n===> Done.\n"
