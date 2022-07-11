#!/bin/sh

set -eu

. ./lib.sh

script_dir="$(dirname "$(realpath "$0")")"
script_name="$(basename "$(realpath "$0")")"

help="Usage: ${script_name} [OPTION]... <COMMAND>

Options:
  -h, --help   print this help

Commands:
  create                            Creates the arch-builder if it does not exist
  rebuild                           Rebuilds the arch-builder image
  remove                            Removes the arch-builder image
  get-official <package>            Gets/Updates the build instructions for an official package
  get-aur <package>                 Gets/Updates the build instructions for an AUR package
  build <package>                   Builds the package with the arch-builder
  add-trusted-key <package> <key>   Adds a trusted third party key to the package build process
"

usage="Usage: ${script_name} <create|rebuild|remove|get-official|get-aur>"

if [ "$#" -lt "1" ]; then
  printf '%s\n' "$usage"
  exit 1
fi
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  printf '%s\n' "$help"
  exit 0
fi

case "$1" in
  create)
    create_builder_image
    ;;
  rebuild)
    remove_builder_image
    create_builder_image
    ;;
  remove)
    remove_builder_image
    ;;
  get-official)
    if [ "$#" -lt 2 ]; then
      printf 'Package name required\n'
      exit 1
    fi
    package="$2"
    get_official_package_repo "$package"
    ;;
  get-aur)
    if [ "$#" -lt 2 ]; then
      printf 'Package name required\n'
      exit 1
    fi
    package="$2"
    get_aur_package_repo "$package"
    ;;
  build)
    if [ "$#" -lt 2 ]; then
      printf 'Package name required\n'
      exit 1
    fi
    package="$2"
    build_package "$package"
    ;;
  add-trusted-key)
    if [ "$#" -lt 2 ]; then
      printf 'Package name required\n'
      exit 1
    fi
    package="$2"
    if [ "$#" -lt 3 ]; then
      printf 'Trusted key required\n'
      exit 1
    fi
    key="$3"
    add_trusted_key "$package" "$key"
    ;;
  *)
    printf 'Unknown command: %s\n' "$1"
    exit 1
    ;;
esac
