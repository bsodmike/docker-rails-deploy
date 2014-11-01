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
ADD nginx-sites.conf /etc/nginx/sites-enabled/default

# Install foreman
RUN gem install bundler
RUN gem install foreman

# Install Rails App
WORKDIR /home/app
ONBUILD ADD Gemfile /home/app/Gemfile
ONBUILD ADD Gemfile.lock /home/app/Gemfile.lock
ONBUILD RUN bundle install --without development test
ONBUILD ADD . /home/app
ONBUILD RUN mkdir -p /home/app/public/assets
ONBUILD RUN bundle exec rake assets:precompile
ONBUILD RUN chown -R www-data:www-data /home/app/public/assets

# Add default unicorn config
ADD unicorn.rb /home/app/config/unicorn.rb

# Add default foreman config
ADD Procfile /home/app/Procfile

ENV RAILS_ENV production

CMD foreman start -f Procfile
