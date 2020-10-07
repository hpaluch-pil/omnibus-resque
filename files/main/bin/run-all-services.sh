#!/bin/sh

set -e

PATH=/opt/resque/embedded/bin:$PATH /opt/resque/embedded/bin/runsvdir -P /opt/resque/sv
exit 0
