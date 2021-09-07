#!/usr/bin/env bash

set -o errexit

cat <(echo -e '#@data/values\n---') <(gyr ./config/values.yaml) |
	ytt -f- -f ./config/images.yaml | 
	kbld --images-annotation=false --build-concurrency=1 -f- > ./images.yaml
