# redis-config - creates redis configuration for resque Omnibus installation
# - ripped from 'gitlab-selinux'
name 'redis-config'

license 'Apache-2.0'
#license_file File.expand_path('LICENSE', Omnibus::Config.project_root)

skip_transitive_dependency_licensing true

source path: File.expand_path('files/redis', Omnibus::Config.project_root)

build do
  command "mkdir -p #{install_dir}/etc/redis"
  copy 'redis.conf',"#{install_dir}/etc/redis/"
  command "mkdir -p #{install_dir}/sv/redis"
  copy 'run',"#{install_dir}/sv/redis/"
  # directory for local Redis Unix socket
  command "mkdir -p #{install_dir}/var/run/redis"
  touch "#{install_dir}/var/run/redis/.gitkeep"
end
