#
# Copyright 2020 YOUR NAME
#
# All Rights Reserved.
#

name "resque"
maintainer "CHANGE ME"
homepage "https://CHANGE-ME.com"

# Defaults to C:/resque on Windows
# and /opt/resque on all other platforms
install_dir "#{default_root}/#{name}"

build_version Omnibus::BuildVersion.semver
build_iteration 1

# Creates required build directories
dependency "preparation"

# resque dependencies/components
# dependency "somedep"

exclude "**/.git"
exclude "**/bundler/git"
