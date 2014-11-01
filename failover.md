## TODO
* app2 needs a unique socket for unicorn (Done)


docker run -d --name app --restart=on-failure:5 -v /var/log/nginx/:/var/log/nginx/ -v /var/lib/mysql:/var/lib/mysql -v /tmp:/tmp -p 8080:80 -e "SECRET_KEY_BASE=foo" --link mysql:webdb inertialbox/inertialbox-app


docker build -t inertialbox/rails-nginx-unicorn-failover rails-nginx-unicorn-failover
docker build -t inertialbox/inertialbox-app-failover ~/hack/inertialbox.com_failover


docker run -d --name app-failover -v /var/log/nginx-app-failover/:/var/log/nginx/ -v /tmp:/tmp -p 8081:80 -e "SECRET_KEY_BASE=foo2" --link mysql:webdb inertialbox/inertialbox-app-failover
