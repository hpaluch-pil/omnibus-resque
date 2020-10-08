#!/bin/sh

set -e

for exe in runsvdir runsv
do
	echo "Stopping $exe ..."
	pkill -e "$exe"  || {
		echo "ERROR: 'pkill -e  $exe' failed with code $?" >&2
	}
done
exit 0

