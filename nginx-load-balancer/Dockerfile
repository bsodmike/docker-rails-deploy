FROM ubuntu:trusty
MAINTAINER Michael de Silva <michael@inertialbox.com>

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
  DEBIAN_FRONTEND=noninteractive apt-get -y install \
    wget \
    build-essential \
    curl \
    git-core \
    python-dev \
    python-setuptools \
    python-software-properties \
    software-properties-common 

# install essentials
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install \
    git \
    vim \
    atop \
    htop \
    silversearcher-ag

# Add official git and nginx APT repositories
RUN apt-add-repository ppa:git-core/ppa
RUN add-apt-repository -y ppa:nginx/stable

# Install Nginx.
RUN apt-get install -qq -y nginx
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf
RUN chown -R www-data:www-data /var/lib/nginx

# Add default nginx config
ONBUILD ADD nginx-balancer.conf /etc/nginx/sites-enabled/default
# Add default foreman config
ONBUILD ADD Procfile /home/app/Procfile

# Install foreman
RUN gem install bundler
RUN gem install foreman

WORKDIR /home/app

CMD foreman start -f Procfile
