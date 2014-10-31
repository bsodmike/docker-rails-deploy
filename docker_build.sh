#!/bin/bash

docker build -t inertialbox/trusty-base ~/hack_ops/packer-digitalocean-docker/docker/trusty_base
docker build -t inertialbox/rails-nginx-unicorn ~/hack_ops/packer-digitalocean-docker/docker/rails-nginx-unicorn
