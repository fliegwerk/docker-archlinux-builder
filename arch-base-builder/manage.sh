#!/bin/sh

set -eu

IMAGE_NAME="arch-base-builder:latest"

script_dir="$(dirname "$(realpath "$0")")"
script_name="$(basename "$(realpath "$0")")"

# root check
if [ "$(id -u)" = "0" ]; then
  SUDO=""
else
  SUDO="sudo"
fi

# parse input
if [ "$#" -lt 1 ]; then
  printf 'Usage: %s <build|clean|update>\n' "$script_name"
  exit 1
fi
action="$1"

build() {
  $SUDO docker build --tag "$IMAGE_NAME" "$script_dir"
}

clean() {
  $SUDO docker image remove "$IMAGE_NAME" || true
  $SUDO docker image prune --force || true
}

case "$action" in
  build) build;;
  clean) clean;;
  update) clean && build;;
esac
