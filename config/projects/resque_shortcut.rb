# shortcut that just install files - do NOT use it for build
name "resque_shortcut"
maintainer "henryk.paluch@pickering.cz"
homepage "https://github.com/resque/resque"

install_dir "#{default_root}/#{name}"

build_version Omnibus::BuildVersion.semver
build_iteration 1

# Creates required build directories
dependency "preparation"

# version manifest file
dependency "version-manifest"

# This shortcut only copies configuration files...

# our local configuration files
dependency "main-config"

exclude "**/.git"
exclude "**/bundler/git"

