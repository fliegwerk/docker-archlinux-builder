#!/bin/sh

set -eu

GIT_URL="https://aur.archlinux.org/yay.git"
GIT_ROOT_NAME="package"

script_dir="$(dirname "$(realpath "$0")")"
script_name="$(basename "$(realpath "$0")")"

package_path="$script_dir/$GIT_ROOT_NAME"

# parse input
if [ "$#" -lt 1 ]; then
  printf 'Usage: %s <update|clean>\n' "$script_name"
  exit 1
fi
action="$1"

update() {
  if [ -d "$package_path" ]; then
    cd "$package_path"
    git pull --prune
  else
    cd "$script_dir"
    git clone "$GIT_URL" "$GIT_ROOT_NAME"
  fi
  # allow user in docker container write access inside this folder
  chmod 777 "$package_path"
}

clean() {
  rm --recursive --force "$package_path"
}

case "$action" in
  update) update;;
  clean) clean;;
esac
