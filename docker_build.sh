#!/bin/bash

docker build -t inertialbox/trusty-base trusty_base
docker build -t inertialbox/rails-nginx-unicorn rails-nginx-unicorn
