#!/bin/bash

ORG=inertialbox

docker images | grep "^${ORG}/trusty-base" > /dev/null 2>&1
[ $? -ne 0 ] && docker build -t ${ORG}/trusty-base trusty_base

docker images | grep "^${ORG}/nginx-load-balancer" > /dev/null 2>&1
[ $? -ne 0 ] && echo -e "\n===> Building image for the base load balancer.\n" &&\
  docker build -t ${ORG}/nginx-load-balancer nginx-load-balancer

docker images | grep "^${ORG}/load-balancer-one" > /dev/null 2>&1
[ $? -ne 0 ] && echo -e "\n===> Building image for load balancer ONE.\n" &&\
  docker build -t ${ORG}/load-balancer-one inertialbox/load-balancer-one

[ -n "$REBUILD" ] && echo -e "\n===> Re-building image for load balancer ONE.\n" &&\
  docker build -t ${ORG}/load-balancer-one inertialbox/load-balancer-one

docker ps -a | grep "[^\-]load-balancer-one" > /dev/null 2>&1
[ $? -ne 0 ] && echo -e "\n===> Running load balancer ONE.\n" && \
  docker run -d --name load-balancer-one \
  -v /var/log/load-balancer-one/:/var/log/nginx/ \
  -p 80:80 ${ORG}/load-balancer-one

echo -e "\n===> Done.\n"
