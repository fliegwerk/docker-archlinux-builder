#!/usr/bin/env bash

script_dir="$(dirname "$(realpath "$0")")"

source "$script_dir/package/PKGBUILD"

printf '%s ' "${depends[*]}"
printf '%s' "${makedepends[*]}"
