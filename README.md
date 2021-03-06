# Resque Omnibus project

This project creates full-stack platform-specific packages for
[Resque](https://github.com/resque/resque) using
[Chef-Omnibus](https://github.com/chef/omnibus)!

The [Resque](https://github.com/resque/resque) is ideal candidate
for this demo because it is Ruby app (embedded Ruby is pretty well supported by
Omnibus) it uses also [Redis](https://redis.io/) key-value store for Queue and
[Sinatra](http://sinatrarb.com/) framework for Web admin frontend.

This simple demo create single package with:

- service `redis` server that listens on unix (file) socket
- service `resque-web` Resque Web frontend available on `http://IP:9292` URL
  using portable [Rack](https://github.com/rack/rack) web-server interface
- service `worker-url_title` (this worker accepts URL as input parameter and
  fetches and extracts `<title/>` from that site and logs result
- example task creation command `/opt/resque/etc/workers/url_title/put_task.rb`
  that will put specified URL into worker queue

Build was tested on these hosts:

- `Debian10` (`.deb` package created)
- `openSUSE LEAP 15.2` (`.rpm` package created)

Also under `Debian10` Host it is now possible to build CentOS7 package using Kitchen with Docker.
Please see Kitchen section below.

## Build setup

We must install requirements for [RBEnv](https://github.com/rbenv/rbenv) with
Ruby 2.6.6 (Omnibus requirement).

On `Debian 10` build Host install these packages:

```shell
# we use ruby-dev to install typical ruby dependencies,
#  even when we use custom ruby runtime
sudo apt-get install curl make gcc g++ ruby-dev git fakeroot
# required by rbenv/ruby
sudo apt-get install -y libssl-dev libreadline-dev
```

On `openSUSE LEAP 15.2` install these packages:

```shell
# probably overkill but easy to setup...
sudo zypper in -t pattern devel_C_C++
sudo zypper in -t pattern devel_rpm_build
# additional Ruby build dependencies
sudo zypper in libopenssl-devel readline-devel
```

### Installing RBEnv

NOTE: All actions done as non-privileged user.

At first checkout RBEnv into `~/.rbenv` using:

```bash
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
```

Then add to your `~/.bashrc`:

```bash
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
```

Now source this new `~/.bashrc`:

```bash
source ~/.bashrc
```

Install `ruby-build` plugin:

```bash
mkdir -p "$(rbenv root)"/plugins
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
```

To see available ruby version use this command:

```bash
rbenv install --list
```

Now install 2.6.6:

```bash
rbenv install 2.6.6
# it may take some time
```

Set this new ruby version as RBEnv global default:

```bash
rbenv global 2.6.6
rbenv global
   2.6.6
```

Verify that default ruby is really 2.6.6:

```bash
ruby --version
   ruby 2.6.6p146 (2020-03-31 revision 67876) [x86_64-linux
```

Now you are ready to proceed to next section...

### When you have Ruby 2.6.6 installed

Once you finished Ruby 2.6.6 installation under RBEnv (from above
section) you can now proceed with project checkout and build.

Now checkout this project:

```bash
mkdir -p ~/projects
cd ~/projects
git clone  https://github.com/hpaluch-pil/omnibus-resque.git
cd omnibus-resque
```

You must have a sane Ruby 2.6.6+ environment with Bundler installed. Ensure all
the required gems are installed:

```shell
bundle install --binstubs
```

### Building Host package

Here we will show how to build package for Host system (it means, that on
Debian it will .deb, on SUSE it will build .rpm). Other possibility is using
Kitchen, but it was not tested yet.

Ensure that there exist directories required for this build:

```bash
sudo mkdir -p /var/cache/omnibus  /opt/resque
sudo chown $USER /var/cache/omnibus /opt/resque
```

Then you can create a platform-specific (=for host OS)  package
using the `build project` command:

```shell
cd ~/projects/omnibus-resque
bin/omnibus build resque
```

NOTE: The `resque` is project name. Omnibus will use
`config/projects/resque.rb` in such case.

> For development only:
>
> To just copy configuration files into `/opt/resque_shortcut` use this phony
> command/project: `bin/omnibus build resque_shortcut`. It is used for speedy
> testing of stuff only - please ignore build .deb package.

On successful build there should be created file like:

```
# Debian10
pkg/resque_0.0.0-1_amd64.deb
# openSUSE LEAP 15.2
pkg/resque-0.0.0-1.sles15.x86_64.rpm
```

## Installation and usage of package

You can then install provided package from previous section on **target**
Debian10 - **must be different from build system** using:

```bash
sudo dpkg -i resque_0.0.0-1_amd64.deb
```

Or in case of `openSUSE LEAP 15.2` install RPM using:

```bash
rpm -ivh resque-0.0.0-1.sles15.x86_64.rpm
```

After install you can run manually all services using:

```bash
sudo /opt/resque/bin/start-all-services.sh
```

Try this command (or suitable `netstat`) to see if Redis is running on Unix
socket:

```bash
ss -x -o state listening | grep redis.socket

u_str 0      128    /var/opt/resque/redis/redis.socket 22874             * 0
```

Look into file `/var/log/resque/redis/current` in case of problems with Redis

Use this command to verify that web-server is running:

```bash
ss -t -o state listening  | grep :9292

0          128                   0.0.0.0:9292                  0.0.0.0:*
```

If it is there you can now point your browser to `http://YOUR_SERVER_IP:9292`
to see Resque admin interface.

In case of problems look into file `/var/log/resque/resque-web/current`

Now you can try to schedule example job item using `url_title`. You can enqueue
new task using command like:

```bash
# use sudo to guarantee access to Redis Unix socket
sudo -u omniresq /opt/resque/etc/workers/url_title/put_task.rb https://slashdot.org/
```

If everything works properly then Resque will call worker for `url_title` queue
to fetch specified URL and extract `<title/>` element and logs results to
`/var/log/resque/workers/url_title/current`

Here is example output in `/var/log/resque/workers/url_title/current`:

```
2020-10-08_12:20:57.78029 Fetching 'https://slashdot.org/'...
2020-10-08_12:21:06.26359 Title of url 'https://slashdot.org/'
                          is: 'Slashdot: News for nerds, stuff that matters'
```

You can stop all services using:

```bash
sudo /opt/resque/bin/stop-all-services.sh
```

Debug: Logs are under `/var/log/resque/SERVICE/*`.

## Using Kitchen for container builds

Kitchen is Chef component originally used for Integration tests of Chef Recipes. There is
also basic support for Omnibus. Kitchen allows to quickly setup containers (or VMs) with
different operating systems so we can create packages for them.

In our example we will:

- use our existing Host OS: `Debian 10`
- we will build CentOS 7 packages using Docker container prepared by Kitchen

Tested on Debian 10 HOST:

- install Docker following: https://docs.docker.com/engine/install/debian/
- add your user to `docker` group using `sudo /usr/sbin/usermod -G docker -a $USER`

Install these additional GEMs to your local RBEnv using:

```shell
gem install test-kitchen kitchen-dokken
```

WARNING! Must use recent enough Kitchen - version 2.7.2 seems to work well...

Once kitchen is setup you can:

Prepare running container (in our case CentOS 7 using:

```shell
kitchen converge
```

Once is converge ready we can login to container using:
```shell
kitchen login
# following should appear
[root@dokken /]#
```

Inside container we can do this to build RPM package (instead of .deb in Host's Debian):
```shell
mkdir -p /var/cache/omnibus  /opt/resque
chown kitchen /var/cache/omnibus /opt/resque
# bundler has weird permission issues...
chown -R kitchen:kitchen /opt/omnibus-toolchain/embedded
su - kitchen
# correct 'ansible' to your username if needed
cd /host-home/ansible/projects/
find omnibus-resque/ | cpio -pvdm ~/
cd ~/omnibus-resque/
rm -rf  .kitchen .bundle
. ~/load-omnibus-toolchain.sh
bundle install --binstubs
bin/omnibus build resque
# copy-back created RPM
exit # exit back from 'kitchen' user to 'root' user
cp /home/kitchen/omnibus-resque/pkg/resque-0.0.0-1.el7.x86_64.rpm \
   /host-home/ansible/projects/omnibus-resque/pkg/
# exit from Kitchen container
exit
```

Notes:
- you can again enter running container using `kitchen login`
- once you are done with this container you should destroy it using `kitchen destroy`

## Notes

### Rebuild failing

Sometimes on rebuild there are confusing errors, like that
`/opt/resque/embedded/bin/gem` not found.  In such case drastic cleanup
may help before rebuild:

```bash
sudo rm -rf /opt/resque/ /var/cache/omnibus/
sudo mkdir -p /var/cache/omnibus  /opt/resque
sudo chown $USER /var/cache/omnibus /opt/resque
```

Then `bin/omnibus build resque` should work again, however it will fetch and
build and reinstall everything.

## Bugs

The `url_title` worker does not handle/log `utf-8` (or any other) encoding - so
some characters could be lost or logged with unpredictable encoding.

## Resources

* Chef-Omnibus project:
  - https://github.com/chef/omnibus
* Omnibus-Software - default `software` components (specified by `dependency`)
  if not overridden by custom file under `config/software/`
  - https://github.com/chef/omnibus-software

## Copyright

This project is based on contribution from many other users especially on
[GitLab-Omnibus](https://gitlab.com/gitlab-org/omnibus-gitlab) project.


