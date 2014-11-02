#!/bin/bash

WORKDIR=${PWD}
ORG=inertialbox
APP_NAME=inertialbox
APP_REPO=git@bitbucket.org:bsodmike/inertialbox.com.git
#SECRET_KEY_BASE=foo
#MYSQL_ROOT_PASSWORD=0mDF30W43I
#MYSQL_PASSWORD=A307W7oP52j6Fxv

docker images | grep "^${ORG}/trusty-base" > /dev/null 2>&1
[ $? -ne 0 ] && docker build -t ${ORG}/trusty-base trusty_base

docker images | grep "^${ORG}/rails-nginx-unicorn" > /dev/null 2>&1
[ $? -ne 0 ] && docker build -t ${ORG}/rails-nginx-unicorn rails-nginx-unicorn

docker images | grep "^${ORG}/rails-nginx-unicorn-failover" > /dev/null 2>&1
[ $? -ne 0 ] && docker build -t ${ORG}/rails-nginx-unicorn-failover rails-nginx-unicorn-failover

docker ps -a | grep "mysql[^\-]" > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo -e "\n===> Running mysql instance...\n"
  docker run -d --name mysql --restart=on-failure:5 \
    -v /tmp:/tmp \
    -v /etc/mysql:/etc/mysql \
    -v /var/lib/mysql:/var/lib/mysql \
    -p 3306:3306 \
    -e "MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}" \
    -e "MYSQL_USER=${APP_NAME}" \
    -e "MYSQL_PASSWORD=${MYSQL_PASSWORD}" \
    -e "MYSQL_DATABASE=${APP_NAME}_production" \
    mysql:5.7
fi

# Fetch app
ls /opt/deploy > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo -e "\n*** Set SSH deploy key for root user, to clone '${APP_REPO}'\n"
  mkdir -p /opt/deploy > /dev/null 2>&1
  [ $? -ne 0 ] && echo -e "\n--[ERROR]: Unable to create '/opt/deploy' - need sudo!\n" && exit 1

  # Ref: http://serverfault.com/a/631149
  ssh -o "StrictHostKeyChecking no" -o PasswordAuthentication=no bitbucket.org

  git clone $APP_REPO /opt/deploy/app
  [ $? -ne 0 ] && echo -e "\n--[ERROR]: Unable to clone repo!\n" && exit 1
  git clone -b docker/failover --single-branch $APP_REPO /opt/deploy/app_failover
  [ $? -ne 0 ] && echo -e "\n--[ERROR]: Unable to clone repo!\n" && exit 1
fi

git_pull(){
  cd /opt/deploy/app && git pull
  cd /opt/deploy/app_failover && git pull
  cd $WORKDIR
  echo -e "\n===> Fetched latest app changes from git repo '${APP_REPO}'\n"
}

[ -n "$DEPLOY" ] && git_pull

# Build app
build_app(){
  echo -e "\n===> Commencing app rebuild...\n"
  docker build -t ${ORG}/${APP_NAME}-app /opt/deploy/app
  docker build -t ${ORG}/${APP_NAME}-app-failover /opt/deploy/app_failover
  echo -e "\n===> Completed app rebuild.\n"
}

docker images | grep "^${ORG}/${APP_NAME}-app" > /dev/null 2>&1
[ $? -ne 0 ] && build_app

docker images | grep "^${ORG}/${APP_NAME}-app-failover" > /dev/null 2>&1
[ $? -ne 0 ] && build_app

[ -n "$REBUILD" ] && build_app

docker images | grep '<none>' > /dev/null 2>&1
[ $? -eq 0 ] && echo -e "\n===> Removing stale images.\n" &&\
  docker images | grep '<none>' | awk '{print $3}' | xargs docker rmi

docker ps -a | grep "[^-]app\b" > /dev/null 2>&1
[ $? -eq 0 ] && echo -e "\n===> Stopping and removing app container.\n" &&\
  docker stop app > /dev/null 2>&1 && docker rm app > /dev/null 2>&1

docker ps -a | grep "[^-]app-failover\b" > /dev/null 2>&1
[ $? -eq 0 ] && echo -e "\n===> Stopping and removing app-failover container.\n" &&\
  docker stop app-failover > /dev/null 2>&1 && docker rm app-failover > /dev/null 2>&1

docker ps -a | grep "mysql[^\-]" | grep "Exited" > /dev/null 2>&1
[ $? -eq 0 ] && echo -e "\n===> Starting the mysql container.\n" &&\
  docker start mysql

echo -e "\n===> Linking and running app instance...\n"
docker run -d --name app --restart=on-failure:5 \
  -v /var/log/nginx/:/var/log/nginx/ \
  -v /var/lib/mysql:/var/lib/mysql \
  -v /tmp:/tmp \
  -p 8080:80 \
  -e "SECRET_KEY_BASE=${SECRET_KEY_BASE}" \
  -e "UNICORN_NAME=unicorn" \
  --link mysql:webdb \
  ${ORG}/${APP_NAME}-app

echo -e "\n===> Linking and running app failover instance...\n"
docker run -d --name app-failover \
  -v /var/log/nginx-app-failover/:/var/log/nginx/ \
  -v /tmp:/tmp \
  -p 8081:80 \
  -e "SECRET_KEY_BASE=${SECRET_KEY_BASE}" \
  -e "UNICORN_NAME=unicorn_failover" \
  --link mysql:webdb \
  ${ORG}/${APP_NAME}-app-failover

echo -e "\n===> Done.\n"
