# copies main configuration files that does not depend to any specific service
name 'main-config'

license 'Apache-2.0'

skip_transitive_dependency_licensing true

source path: File.expand_path('files/main', Omnibus::Config.project_root)

build do
  # fortunately, copy is recursive
  copy '*',"#{install_dir}/"
end
