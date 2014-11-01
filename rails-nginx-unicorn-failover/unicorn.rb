app_dir = "/home/app"

working_directory app_dir

pid "#{app_dir}/tmp/#{ENV['UNICORN_NAME']}.pid"

stderr_path "#{app_dir}/log/#{ENV['UNICORN_NAME']}.stderr.log"
stdout_path "#{app_dir}/log/#{ENV['UNICORN_NAME']}.stdout.log"

worker_processes 1
listen "/tmp/#{ENV['UNICORN_NAME']}.sock", :backlog => 64
timeout 30
