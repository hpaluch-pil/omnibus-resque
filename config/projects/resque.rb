name "resque"
maintainer "henryk.paluch@pickering.cz"
homepage "https://github.com/resque/resque"

install_dir "#{default_root}/#{name}"

build_version Omnibus::BuildVersion.semver
build_iteration 1

# Creates required build directories
dependency "preparation"

# version manifest file
dependency "version-manifest"

# all these three must have same version, otherwise very weird things will happen!!!
override :ruby, version: "2.6.6"
override :rubygems, version: "2.6.6"
override :bundler, version: "2.6.6"

# resque dependencies/components
dependency "nokogiri"
override :nokogiri, version: "1.10.10"
dependency "resque"
dependency "redis"
# our local configuration files
dependency "main-config"

# change FTP to HTTP(S), because corporate network does not support FTP
override :libffi, version: '3.2.1', source: { sha256: "d06ebb8e1d9a22d19e38d63fdb83954253f39bedc5d46232a05645685722ca37", url: "http://sourceware.org/pub/libffi/libffi-3.2.1.tar.gz" }
override :libxml2, version: '2.9.10', source: { sha256: "aafee193ffb8fe0c82d4afef6ef91972cbaf5feea100edc2f262750611b4be1f", url: "http://xmlsoft.org/sources/libxml2-2.9.10.tar.gz" }
override :libxslt, version: '1.1.34', source: { sha256: "98b1bd46d6792925ad2dfe9a87452ea2adebf69dcb9919ffd55bf926a7f93f7f", url: "http://xmlsoft.org/sources/libxslt-1.1.34.tar.gz" }

exclude "**/.git"
exclude "**/bundler/git"

# exclude manpages and documentation - ripped from gitlab-omnibus
#exclude 'embedded/man'
exclude 'embedded/share/doc'
exclude 'embedded/share/gtk-doc'
exclude 'embedded/share/info'
exclude 'embedded/share/man'

