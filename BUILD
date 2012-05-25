#!/bin/sh

set -e
start=$PWD

for path in `find . -name Makefile`
do
  dir=`dirname $path`
  echo "Building in $dir"
  cd "$dir"
  make $@
  cd "$start"
done
