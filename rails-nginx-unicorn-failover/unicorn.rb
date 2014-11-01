app_dir = "/home/app"

working_directory app_dir

pid "#{app_dir}/tmp/unicorn_failover.pid"

stderr_path "#{app_dir}/log/unicorn.stderr.log"
stdout_path "#{app_dir}/log/unicorn.stdout.log"

worker_processes 1
listen "/tmp/unicorn_failover.sock", :backlog => 64
timeout 30
