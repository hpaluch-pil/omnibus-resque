resque Omnibus project
======================
This project creates (someday in future) full-stack platform-specific packages for
`resque` using [Chef-Omnibus](https://github.com/chef/omnibus)!

It is simple demo that contains:
- service `redis` server that listens on unix (file) socket
- service `resque-web` Resque frontend available on `http://IP:9292` URL
- service `worker-url_title` (this worker accepts URL as input parameter and fetches
  and extracts `<title/>` from that site and logs result
- example task creation command `/opt/resque/etc/workers/url_title/put_task.rb` that will put specified URL into worker
  queue


Build setup
-----------

Tested under Debian10/amd64 with Ruby2.6.6 installed and configure via [RBEnv](https://github.com/rbenv/rbenv). Your debian should have installed at least:
```shell
# we use ruby-dev to install typical ruby dependencies, even when we use custom ruby runtime
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

On successfull build there should be created file like:

```
pkg/resque_0.0.0-1_amd64.deb
```

You can then install it on target Debian10 - *must be different from build system* using:
```
sudo dpkg -i resque-shortcut_0.0.0-1_amd64.deb
```

After install you can run manually all services (Redis and Web frontend works
so far) using:

```
sudo /opt/resque/bin/start-all-services.sh
```

Try this command (or suitable `netstat`) to see if Redis is running on Unix socket:

```bash
ss -x -o state listening | grep redis.socket

u_str 0      128    /var/opt/resque/redis/redis.socket 22874             * 0
```
Look into file `/var/log/resque/redis/current` in case of problems with Redis

Use this command to verify that web-server is running:
```
ss -t -o state listening  | grep :9292

0          128                   0.0.0.0:9292                  0.0.0.0:*
```
If it is there point your browser to `http://YOUR_SERVER_IP:9292` to see Resque admin interface.

In case of problems look into file `/var/log/resque/resque-web/current`

Now there is even example job using `url_title`. You can enqueue new task using command like:

```bash
/opt/resque/etc/workers/url_title/put_task.rb https://slashdot.org/
```

If everything works properly then Resque will call worker for `url_title` queue and fetch specified URL
and extract `<title/>` element and logs results to `/var/log/resque/workers/url_title/current`

Here is example output in `/var/log/resque/workers/url_title/current`:

```
2020-10-08_12:20:57.78029 Fetching 'https://slashdot.org/'...
2020-10-08_12:21:06.26359 Title of url 'https://slashdot.org/' is: 'Slashdot: News for nerds, stuff that matters'
```



You can stop all services using:

```
sudo /opt/resque/bin/stop-all-services.sh
```

Debug: Logs are under `/var/log/resque/SERVICE/*`.


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


