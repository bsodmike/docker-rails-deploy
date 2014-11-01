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

docker ps -a | grep "mysql[^\-]" > /dev/null 2>&1
if [ $? -ne 0 ]; then
  docker run -d --name mysql --restart=on-failure:5 -v /tmp:/tmp -v /etc/mysql:/etc/mysql -v /var/lib/mysql:/var/lib/mysql -p 3306:3306 -e "MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}" -e "MYSQL_USER=${APP_NAME}" -e "MYSQL_PASSWORD=${MYSQL_PASSWORD}" -e "MYSQL_DATABASE=${APP_NAME}_production" mysql:5.7
fi

# Build app
build_app()
{
  echo -e "\n===> Commencing app rebuild...\n"
  docker build -t ${ORG}/${APP_NAME}-app ~/hack/inertialbox.com
  echo -e "\n===> Completed app rebuild.\n"
}

docker images | grep "^${ORG}/${APP_NAME}-app" > /dev/null 2>&1
if [ $? -ne 0 ]; then
  build_app
elif [ -n "$REBUILD" ]; then
  build_app
fi

docker ps -a | grep "[^-]app\b" > /dev/null 2>&1
[ $? -eq 0 ] && docker stop app && docker rm app
docker run -d --name app --restart=on-failure:5 -v /var/log/nginx/:/var/log/nginx/ -v /var/lib/mysql:/var/lib/mysql -v /tmp:/tmp -p 80:80 -e "SECRET_KEY_BASE=${SECRET_KEY_BASE}" --link mysql:webdb ${ORG}/${APP_NAME}-app

echo -e "\n===> Done.\n"
