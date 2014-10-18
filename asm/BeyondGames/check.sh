#!/bin/sh
#
# Look for any obvious errors in the BASIC listings.

cat E*.bas | egrep -v  '^ [0-9][0-9][0-9][0-9] DATA  [0-9][0-9][0-9][02468], [0-9]+, [0-9]+, [0-9]+, [0-9]+, [0-9]+, [0-9]+, [0-9]+, [0-9]+, [0-9][0-9][0-9][0-9]$' | grep -v END | grep -v FOLLOW | grep -v CONTAIN | grep -v CHECKSUMS | grep -v SUITABLE | grep -v BASIC | egrep -v '^$'
