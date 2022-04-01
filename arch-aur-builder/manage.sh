#!/bin/sh

set -eu

IMAGE_NAME="arch-aur-builder:latest"

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
  # copy built aur package
  for file in "$script_dir"/../yay/package/yay-*-x86_64.pkg.tar.zst; do
    cp --force "$file" "$script_dir/yay.tar.zst"
  done

  # install and generate new image
  $SUDO docker build --tag "$IMAGE_NAME" "$script_dir"
}

clean() {
  $SUDO docker image remove "$IMAGE_NAME" || true
  $SUDO docker image prune --force || true
  # remove copied aur package
  rm --force "$script_dir/yay.tar.zst"
}

case "$action" in
  build) build;;
  clean) clean;;
  update) clean && build;;
esac
