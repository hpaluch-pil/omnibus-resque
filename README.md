resque Omnibus project
======================
This project creates (someday in future) full-stack platform-specific packages for
`resque` using [Chef-Omnibus](https://github.com/chef/omnibus)!

WARNING! It is highly experimental stuff! 

Installation
------------

Tested under Debian10/amd64 with Ruby2.6.6 installed and configure via [RBEnv](https://github.com/rbenv/rbenv). Your debian should have installed at least:
```shell
sudo apt-get install curl make gcc g++ ruby-dev git
# required by rbenv/ruby
sudo apt-get install -y libssl-dev libreadline-dev
```

You must have a sane Ruby 2.6.6+ environment with Bundler installed. Ensure all
the required gems are installed:

```shell
$ bundle install --binstubs
```

Usage
-----
### Build

You create a platform-specific package using the `build project` command:

```shell
$ bin/omnibus build resque
```

NOTE: The `resque` is project name. Omnibus will use `config/projects/resque.rb` in
such case.

> For development only:
>
> To just copy configuration files into `/opt/resque_shortcut` use this phony
> command/project: `bin/omnibus build resque_shortcut`. It is used for speedy
> testing of stuff only - please ignore build .deb package.


The platform/architecture type of the package created will match the platform
where the `build project` command is invoked. For example, running this command
on a MacBook Pro will generate a Mac OS X package. After the build completes
packages will be available in the `pkg/` folder.

### Clean

You can clean up all temporary files generated during the build process with
the `clean` command:

```shell
$ bin/omnibus clean resque
```

Adding the `--purge` purge option removes __ALL__ files generated during the
build including the project install directory (`/opt/resque`) and
the package cache directory (`/var/cache/omnibus/pkg`):

```shell
$ bin/omnibus clean resque --purge
```

>
> Following actions were not yet tested:
>

### Publish

Omnibus has a built-in mechanism for releasing to a variety of "backends", such
as Amazon S3. You must set the proper credentials in your
[`omnibus.rb`](omnibus.rb) config file or specify them via the command line.

```shell
$ bin/omnibus publish path/to/*.deb --backend s3
```

### Help

Full help for the Omnibus command line interface can be accessed with the
`help` command:

```shell
$ bin/omnibus help
```

Version Manifest
----------------

Git-based software definitions may specify branches as their
default_version. In this case, the exact git revision to use will be
determined at build-time unless a project override (see below) or
external version manifest is used.  To generate a version manifest use
the `omnibus manifest` command:

```
omnibus manifest PROJECT -l warn
```

This will output a JSON-formatted manifest containing the resolved
version of every software definition.


Kitchen-based Build Environment
-------------------------------
Every Omnibus project ships with a project-specific
[Berksfile](https://docs.chef.io/berkshelf.html) that will allow you to build
your omnibus projects on all of the platforms listed in the
[`.kitchen.yml`](.kitchen.yml). You can add/remove additional platforms as
needed by changing the list found in the [`.kitchen.yml`](.kitchen.yml)
`platforms` YAML stanza.

This build environment is designed to get you up-and-running quickly. However,
there is nothing that restricts you from building on other platforms. Simply use
the [omnibus cookbook](https://github.com/chef-cookbooks/omnibus) to setup your
desired platform and execute the build steps listed above.

The default build environment requires Test Kitchen and VirtualBox for local
development. Test Kitchen also exposes the ability to provision instances using
various cloud providers like AWS, DigitalOcean, or OpenStack. For more
information, please see the [Test Kitchen documentation](https://kitchen.ci/).

Once you have tweaked your [`.kitchen.yml`](.kitchen.yml) (or
[`.kitchen.local.yml`](.kitchen.local.yml)) to your liking, you can bring up an
individual build environment using the `kitchen` command.


```shell
$ bin/kitchen converge ubuntu-1804
```

Then login to the instance and build the project as described in the Usage
section:

```shell
$ bin/kitchen login ubuntu-1804
[vagrant@ubuntu...] $ .  load-omnibus-toolchain.sh
[vagrant@ubuntu...] $ cd resque
[vagrant@ubuntu...] $ bundle install
[vagrant@ubuntu...] $ bin/omnibus build resque
```

For a complete list of all commands and platforms, run `kitchen list` or
`kitchen help`.
