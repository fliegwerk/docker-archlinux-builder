#!/bin/sh

set -eu

IMAGE_NAME="##PACKAGE_NAME##-builder:latest"

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
  "$script_dir/git.sh" update
  cp --force "$script_dir/Dockerfile.template" "$script_dir/Dockerfile"
  echo "RUN yay --sync --noconfirm --noprogressbar --quiet $("$script_dir/get-dependencies.sh")" >> "$script_dir/Dockerfile"
  $SUDO docker build --tag "$IMAGE_NAME" "$script_dir"
  $SUDO docker run --interactive --tty --rm --volume "$script_dir/package:/package" "$IMAGE_NAME"
}

clean() {
  "$script_dir/git.sh" clean
  $SUDO docker image remove "$IMAGE_NAME" || true
  $SUDO docker image prune --force || true
}

case "$action" in
  build) build;;
  clean) clean;;
  update) clean && build;;
esac
