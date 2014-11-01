#!/bin/bash

ORG=inertialbox
APP_NAME=inertialbox
SECRET_KEY_BASE=foo
MYSQL_ROOT_PASSWORD=0mDF30W43I
MYSQL_PASSWORD=A307W7oP52j6Fxv

docker images | grep "^${ORG}/trusty-base" > /dev/null 2>&1
[ $? -ne 0 ] && docker build -t ${ORG}/trusty-base trusty_base

docker images | grep "^${ORG}/rails-nginx-unicorn" > /dev/null 2>&1
[ $? -ne 0 ] && docker build -t ${ORG}/rails-nginx-unicorn rails-nginx-unicorn

docker images | grep "^${ORG}/rails-nginx-unicorn-failover" > /dev/null 2>&1
[ $? -ne 0 ] && docker build -t ${ORG}/rails-nginx-unicorn-failover rails-nginx-unicorn-failover

docker ps -a | grep "mysql[^\-]" > /dev/null 2>&1
if [ $? -ne 0 ]; then
  docker run -d --name mysql --restart=on-failure:5 -v /tmp:/tmp -v /etc/mysql:/etc/mysql -v /var/lib/mysql:/var/lib/mysql -p 3306:3306 -e "MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}" -e "MYSQL_USER=${APP_NAME}" -e "MYSQL_PASSWORD=${MYSQL_PASSWORD}" -e "MYSQL_DATABASE=${APP_NAME}_production" mysql:5.7
fi

# Build app
build_app()
{
  echo -e "\n===> Commencing app rebuild...\n"
  docker build -t ${ORG}/${APP_NAME}-app ~/hack/inertialbox.com
  docker build -t ${ORG}/${APP_NAME}-app-failover ~/hack/inertialbox.com_failover
  echo -e "\n===> Completed app rebuild.\n"
}

docker images | grep "^${ORG}/${APP_NAME}-app" > /dev/null 2>&1
[ $? -ne 0 ] && build_app

docker images | grep "^${ORG}/${APP_NAME}-app-failover" > /dev/null 2>&1
[ $? -ne 0 ] && build_app

[ -n "$REBUILD" ] && build_app

docker images | grep '<none>' > /dev/null 2>&1
[ $? -eq 0 ] && echo -e "\n===> Removing stale images.\n" && docker images | grep '<none>' | awk '{print $3}' | xargs docker rmi

docker ps -a | grep "[^-]app\b" > /dev/null 2>&1
[ $? -eq 0 ] && echo -e "\n===> Stopping and removing app container.\n" && docker stop app && docker rm app

docker ps -a | grep "[^-]app-failover\b" > /dev/null 2>&1
[ $? -eq 0 ] && echo -e "\n===> Stopping and removing app-failover container.\n" && docker stop app-failover && docker rm app-failover

docker ps -a | grep "mysql[^\-]" | grep "Exited" > /dev/null 2>&1
[ $? -eq 0 ] && echo -e "\n===> Starting the mysql container.\n" && docker start mysql

echo -e "\n===> Linking and running app instance...\n"
docker run -d --name app --restart=on-failure:5 -v /var/log/nginx/:/var/log/nginx/ -v /var/lib/mysql:/var/lib/mysql -v /tmp:/tmp -p 8080:80 -e "SECRET_KEY_BASE=${SECRET_KEY_BASE}" --link mysql:webdb ${ORG}/${APP_NAME}-app

echo -e "\n===> Linking and running app failover instance...\n"
docker run -d --name app-failover -v /var/log/nginx-app-failover/:/var/log/nginx/ -v /tmp:/tmp -p 8081:80 -e "SECRET_KEY_BASE=${SECRET_KEY_BASE}" --link mysql:webdb ${ORG}/${APP_NAME}-app-failover

echo -e "\n===> Done.\n"
