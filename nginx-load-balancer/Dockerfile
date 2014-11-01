FROM inertialbox/trusty-base
MAINTAINER Michael de Silva <michael@inertialbox.com>

# Install nodejs
RUN apt-get update
RUN apt-get install -qq -y nodejs # JS runtime
RUN apt-get install -y libmysqlclient-dev # for mysql2 gem

# Intall software-properties-common for add-apt-repository
RUN apt-get install -qq -y software-properties-common

# Install Nginx.
RUN add-apt-repository -y ppa:nginx/stable
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
