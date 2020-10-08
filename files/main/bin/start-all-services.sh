#!/bin/sh

set -e

PATH=/opt/resque/bin:/opt/resque/embedded/bin:/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin
export PATH
ulimit -c 0
umask 022
# the 'log: ....' is padding so runsvdir may report errors visible with ps command
# NOTE: nohup is essential, because runsvdir just aborts on SIGINT, without cleaning services...
nohup /opt/resque/embedded/bin/runsvdir -P /opt/resque/sv \
      	'log: ............................................' > /var/log/resque/runsvdir.log 2>&1 &
echo "runsvdir daemonized - see /var/log/resque/runsvdir.log for errors"
sleep 1
cat /var/log/resque/runsvdir.log
exit 0

