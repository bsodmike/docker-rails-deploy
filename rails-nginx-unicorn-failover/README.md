# Rails(+ Nginx, Unicorn) Dockerfile

Easy useable docker for rails. less configuration, affordable production.

## What's include

* unicorn, nginx, foreman
* mysql

# Usage

* Create `Dockerfile` to your project and paste below code.

```
# Dockerfile
FROM inertialbox/rails-nginx-unicorn
MAINTAINER Michael de Silva <michael@inertialbox.com>

EXPOSE 80
```

* Add `unicorn` gem(maybe uncomment `gem 'unicorn'` in `Gemfile`)

## Build and run docker

```
# build your dockerfile
$ docker build -t your/project .

# run container
$ docker run -d -p 80:80 -e SECRET_KEY_BASE=secretkey your/project
```

