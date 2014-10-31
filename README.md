# Docker

## Notes

### MySQL

Ref: https://github.com/tutumcloud/tutum-docker-mysql

**TODO**: Switch to the MySQL image for v5.7
* https://registry.hub.docker.com/_/mysql/
* https://github.com/docker-library/mysql/blob/master/5.7/Dockerfile
* Upgrade to docker 1.2.0
(http://blog.docker.com/2014/08/announcing-docker-1-2-0/) and use
restart policies
* Do not use supervisord etc.
* Use an init system
* Systemd + docker start with CoreOS

```
# Build the mysql image
docker build -t inertialbox/mysql ~/hack_ops/packer-digitalocean-docker/docker/mysql/5.6

# Start a data volume container, mysql-data
docker run --name mysql-data -v /var/lib/mysql inertialbox/trusty-base /bin/true

# Run an interactive mysql container; note that the `/run.sh` script needs to be invoked manually via the bash prompt.
# --rm passed to remove container on exit; nice n' tidy.
docker run -ti --rm --volumes-from mysql-data -v /etc/mysql:/etc/mysql --name mysql -p 3306:3306 -e MYSQL_PASS="0mDF30W43I" inertialbox/mysql /bin/bash
```

Run the `mysql` instance with `-d` in the background; this will
automatically launch the `run.sh` script as per its `Dockerfile`
command.

```
docker run -d --volumes-from mysql-data -v /etc/mysql:/etc/mysql --name mysql -p 3306:3306 -e MYSQL_PASS="0mDF30W43I" inertialbox/mysql
```

#### Persisted Images

```
$ docker save inertialbox/mysql > ~/docker_images/inertialbox_mysql.tar
```
