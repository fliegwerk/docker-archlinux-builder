#!/usr/bin/env bash

set -eu

exit_code='0'

# prints a subsection
# $@ - titles of the subsection
subsection() {
  printf '\n'
  printf '  \e[1;36m++\e[0m \e[1m%s\e[0m\n' "$@"
  printf '\n'
}

# prints an errored subsection
# $@ - titles of the subsection
subsection_error() {
  printf '\n'
  printf '  \e[1;31m++ ERROR:\e[0m \e[1m%s\e[0m\n' "$@"
  printf '\n'
}

cleanup() {
  # change back cwd access rights
  subsection 'Change back access rights'
  if ! sudo chown -R "${old_uid}:${old_gid}" .; then
    exit_code="$?"
    subsection_error 'Cannot change back access rights'
  fi

  if [ "$exit_code" -gt "0" ]; then
    subsection_error 'Finished with errors'
  else
    subsection 'Finished build'
  fi
  exit "$exit_code"
}

trap cleanup EXIT HUP INT QUIT TERM

# update installed packages
# Note: This doesn't fix an outdated builder image
# Please rebuild the builder image regularly
subsection 'Update system'
if ! yay --sync --refresh --sysupgrade --noconfirm --noprogressbar --quiet; then
  exit_code="$?"
  subsection_error 'Cannot update system'
  exit "$exit_code"
fi

# install missing dependencies
subsection 'Install build and running dependencies'
source "PKGBUILD"
if ! yay --sync --noconfirm --noprogressbar --quiet --needed "${depends[@]}" "${makedepends[@]}"; then
  exit_code="$?"
  subsection_error 'Cannot install build and running dependencies'
  exit "$exit_code"
fi

# make cwd writable for makepkg
subsection 'Make working directory writable for makepkg'
old_uid="$(stat -c '%u' .)"
old_gid="$(stat -c '%g' .)"
sudo chown -R "$(id -u):$(id -g)" .

subsection 'Add trusted keys to gpg keychain'
if [ -r "trusted-keys" ]; then
  grep -v '^ *#' < trusted-keys | while IFS= read -r key; do
    gpg --recv-key "$key"
  done
fi

# run makepkg
subsection 'Build package via makepkg'
if ! makepkg "$@"; then
  exit_code="$?"
  subsection_error 'Cannot build package via makepkg'
fi

exit "$exit_code"
