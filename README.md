resque Omnibus project
======================
This project creates full-stack platform-specific packages for
`resque` using [Chef-Omnibus](https://github.com/chef/omnibus)!

It is simple demo that contains:
- service `redis` server that listens on unix (file) socket
- service `resque-web` Resque Web frontend available on `http://IP:9292` URL
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

Building Debian package
-----------------------
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


On successfull build there should be created file like:

```
pkg/resque_0.0.0-1_amd64.deb
```

Installation and usage of Debian package
----------------------------------------

You can then install `.deb` package from previous section on target Debian10 - *must be different from build system* using:
```bash
sudo dpkg -i resque-shortcut_0.0.0-1_amd64.deb
```

After install you can run manually all services using:

```bash
sudo /opt/resque/bin/start-all-services.sh
```

Try this command (or suitable `netstat`) to see if Redis is running on Unix socket:

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

```bash
sudo /opt/resque/bin/stop-all-services.sh
```

Debug: Logs are under `/var/log/resque/SERVICE/*`.

Notes
-----

## Rebuild failing

Sometimes on rebuild there are confusing errors, like that `/opt/resque/embedded/bin/gem` not found.
In such case drastic cleanup help before build:

```bash
sudo rm -rf /opt/resque/ /var/cache/omnibus/
sudo mkdir -p /var/cache/omnibus  /opt/resque
sudo chown $USER /var/cache/omnibus /opt/resque
```

Then `bin/omnibus build resque` should work again, however it will fetch and build and reinstall everything.

Bugs
----

The `url_title` worker does not handle/log `utf-8` (or any other) encoding - so some characters could be lost
or logged with unpredictable encoding.

Resources
---------

* Chef-Omnibus project:
  - https://github.com/chef/omnibus
* Omnibus-Software - default `software` components (specified by `dependency`)
  if not overridden by custom file under `config/software/`
  - https://github.com/chef/omnibus-software

