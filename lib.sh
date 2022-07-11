#!/bin/sh

#
# Some library functions used by the Docker Archlinux Builder
#

script_dir="$(dirname "$(realpath "$0")")"
builder_dir="${script_dir}/.builder"

# prints a section
# $@ - titles of the section
section() {
  printf '\n'
  printf '\e[1;34m::\e[0m \e[1m%s\e[0m \e[1;34m::\e[0m\n' "$@"
  printf '\n'
}

# prints an errored section
# $@ - titles of the section
section_error() {
  printf '\n'
  printf '\e[1;31m:: ERROR:\e[0m \e[1m%s\e[0m \e[1;31m::\e[0m\n' "$@"
  printf '\n'
}

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

# assert that the current user has not elevated permissions
assert_no_root() {
  if [ "$(id -u)" = "0" ]; then
    section_error 'You cannot use this tool with root permissions' \
          'Please switch to a normal user and try again'
    exit 1
  fi
}

# detect docker rootless
if echo "$DOCKER_HOST" | grep "/run/user/$(id -u)" > /dev/null; then
  DOCKER_SUDO=""
else
  DOCKER_SUDO="sudo"
fi

# Creates a new builder image
create_builder_image() {
  subsection 'Create builder image'
  
  if ! $DOCKER_SUDO docker pull archlinux:base-devel; then
    exit_code="$?"
    subsection_error 'Cannot create builder image'
    return "$exit_code"
  fi

  if ! $DOCKER_SUDO docker build \
    --tag "arch-builder:latest" \
    --build-arg "BUILD_USER_ID=$(id -u)" \
    --build-arg "BUILD_GROUP_ID=$(id -g)" \
    "$builder_dir"; then
    exit_code="$?"
    subsection_error 'Cannot create builder image'
    return "$exit_code"
  fi
}

# Removes a created builder image
remove_builder_image() {
  subsection 'Remove builder image'
  $DOCKER_SUDO docker image remove --force "arch-builder" || true
}

# Gets the repository for an official package.
# $1 - the name of the package
get_official_package_repo() {
  package="$1"
  repo_path="${script_dir}/${package}"

  subsection 'Get Official package repository'
  if [ -d "$repo_path" ] && [ -d "${repo_path}/trunk" ]; then
    old_cwd="$(pwd)"
    cd "$repo_path" || return $?
    git pull --prune
    cd "$old_cwd" || return $?
  else
    rm --recursive --force "$repo_path"
    git clone \
      --depth 1 \
      --branch "packages/${package}" \
      --single-branch \
      'https://github.com/archlinux/svntogit-packages.git' "$repo_path"
  fi
}

# Gets the repository for an AUR package.
# $1 - the name of the package
get_aur_package_repo() {
  package="$1"
  parent_dir="${script_dir}/${package}"
  repo_path="${parent_dir}/trunk"

  subsection 'Get AUR package repository'
  if [ -d "$parent_dir" ] && [ -d "$repo_path" ]; then
    old_cwd="$(pwd)"
    cd "$repo_path" || return $?
    git pull --prune
    cd "$old_cwd" || return $?
  else
    mkdir --parents "$parent_dir"
    old_cwd="$(pwd)"
    cd "$parent_dir" || return $?
    git clone --depth 1 "https://aur.archlinux.org/${package}.git" "$(basename "$repo_path")"
    cd "$old_cwd" || return $?
  fi
}

# Returns the path to the package repository
# $1 - the name of the package
get_repo_path() {
  package="$1"
  printf '%s\n' "${script_dir}/${package}/trunk"
}

# Builds a package with the previously created build image
# $1 - the name of the package
build_package() {
  package="$1"
  repo_path="$(get_repo_path "$package")"

  subsection "Build package ${package}"
  if ! $DOCKER_SUDO docker run --interactive --tty --rm \
      --mount "type=bind,source=${repo_path},destination=/package" \
      "arch-builder:latest"; then
    exit_code="$?"
    subsection_error "Cannot build package ${package}"
    return "$exit_code"
  fi
}

# Adds a trustes third party key to the specified package
# $1 - the name of the package
# $2 - the trusted third party GPG key
add_trusted_key() {
  package="$1"
  gpg_public_key="$2"
  repo_path="$(get_repo_path "$package")"

  echo "$gpg_public_key" >> "${repo_path}/trusted-keys"
  # filter out duplicates
  printf 'Currently trusted keys:\n'
  sort "${repo_path}/trusted-keys" | uniq | tee "${repo_path}/trusted-keys.new"
  mv --force "${repo_path}/trusted-keys.new" "${repo_path}/trusted-keys"
}
