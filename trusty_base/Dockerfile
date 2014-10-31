FROM ubuntu:trusty
MAINTAINER Michael de Silva <michael@inertialbox.com>

# install ruby 2.1.2 from source
# Ref https://registry.hub.docker.com/u/litaio/ruby/dockerfile/
RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
  DEBIAN_FRONTEND=noninteractive apt-get -y install \
    wget \
    build-essential \
    curl \
    git-core \
    libcurl4-openssl-dev \
    libreadline-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    libyaml-dev \
    zlib1g-dev \
    python-dev \
    python-setuptools \
    python-software-properties \
    software-properties-common \
    mysql-client

# install essentials
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install \
    git \
    vim \
    atop \
    htop \
    silversearcher-ag

# Add official git and nginx APT repositories
RUN apt-add-repository ppa:git-core/ppa
RUN apt-add-repository ppa:nginx/stable

RUN curl -O http://ftp.ruby-lang.org/pub/ruby/2.1/ruby-2.1.2.tar.gz && \
  tar -zxvf ruby-2.1.2.tar.gz && \
  cd ruby-2.1.2 && \
  ./configure --disable-install-doc && \
  make && \
  make install && \
  cd .. && \
  rm -r ruby-2.1.2 ruby-2.1.2.tar.gz && \
  echo 'gem: --no-document' > /usr/local/etc/gemrc

RUN apt-get update
