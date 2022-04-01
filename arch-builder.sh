#!/bin/sh

set -eu

script_dir="$(dirname "$(realpath "$0")")"
script_name="$(basename "$(realpath "$0")")"

# parse action
if [ "$#" -lt "1" ]; then
  printf 'Usage: %s <prepare|clean|update|init>\n' "$script_name"
  exit 1
fi
action="$1"

case "$action" in
  prepare)
    "$script_dir/arch-base-builder/manage.sh" build
    "$script_dir/yay/manage.sh" build
    "$script_dir/arch-aur-builder/manage.sh" build
    printf 'Created builders\n'
    ;;
  clean)
    "$script_dir/arch-aur-builder/manage.sh" clean
    "$script_dir/yay/manage.sh" clean
    "$script_dir/arch-base-builder/manage.sh" clean
    printf 'Cleaned builders\n'
    ;;
  update)
    "$script_dir/arch-base-builder/manage.sh" update
    "$script_dir/yay/manage.sh" update
    "$script_dir/arch-aur-builder/manage.sh" update
    printf 'Updated builders\n'
    ;;
  init)
    if [ "$#" -lt "2" ]; then
      printf 'Git URL required that points to the git repository which contains the PKGBUILD\n'
      exit 1
    fi
    git_url="$2"
    package_name="$(echo "$git_url" | rev | awk -F 'tig.' '{print $2;}' | awk -F '/' '{print $1;}' | rev)"
    printf 'Initialize build environment for package: %s (%s)\n' "$package_name" "$git_url"

    # generate folder structure
    package_dir="$script_dir/$package_name"
    mkdir --parents "$package_dir"
    for file in "$script_dir/.template"/*; do
      filename="$(basename "$file")"
      dest_path="$package_dir/$filename"

      printf 'Copy %s...\n' "$filename"
      cp --force "$file" "$dest_path"
      sed -i "s|##PACKAGE_NAME##|${package_name}|g" "$dest_path"
      sed -i "s|##GIT_URL##|${git_url}|g" "$dest_path"
    done
    printf 'Initalized build environment.\n'
    ;;
  *)
    printf 'Unknown action: %s\n' "$1"
    exit 1
    ;;
esac
