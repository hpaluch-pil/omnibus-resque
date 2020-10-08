#!/bin/sh

# HUP is special - runsvdir will terminate all children "runsv SERVICE"
# and finally terminate itself - see: http://smarden.org/runit/runsvdir.8.html
pkill -HUP 'runsvdir$' || {
	echo "ERROR: pkill of runsvdir failed with code $?"
	exit 1
}
exit 0

