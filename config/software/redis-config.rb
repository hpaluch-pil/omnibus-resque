# redis-config - creates redis configuration for resque Omnibus installation
# - ripped from 'gitlab-selinux'
name 'redis-config'

license 'Apache-2.0'
#license_file File.expand_path('LICENSE', Omnibus::Config.project_root)

skip_transitive_dependency_licensing true

source path: File.expand_path('files/redis', Omnibus::Config.project_root)

build do
  # fortunately, copy is recursive
  copy '*',"#{install_dir}/"
end
