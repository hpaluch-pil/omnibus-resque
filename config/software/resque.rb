name "resque"
default_version "2.0.0"

dependency "ruby"
dependency "rubygems"

build do
  env = with_standard_compiler_flags(with_embedded_path)
  gem "install resque --no-rdoc --no-ri -v #{version}", env: env
end

