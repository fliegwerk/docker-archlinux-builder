# docker-archlinux-builder

Management tool to build arch packages on docker

## Prerequisites

You need a working docker installation and some core utilities.

## Install

Clone this repository:

```shell
git clone https://github.com/fliegwerk/docker-archlinux-builder.git
cd docker-archlinux-builder
```

Add binaries to your path:

```shell
export PATH="$(pwd)/.bin:$PATH"
```

## Usage

First, prepare the makepkg image:

```shell
docker-makepkg update
```

Then, get the build files for the package you want to build:

```shell
git clone --depth 1 --branch "packages/${package_name}" --single-branch 'https://github.com/archlinux/svntogit-packages.git' "$package_name"
# or
git clone --depth 1 --single-branch "https://aur.archlinux.org/${package_name}.git"
```

Finally, build the package with the helper script:

```shell
docker-makepkg build "${package_name}/trunk"
# or
docker-makepkg build "${package_name}"
```

> Tip: You can enable headless mode by passing `headless` as build argument to makepkg.

Finished!

## Update

Because Archlinux is a rolling-release distribution,
it's important that you keep the makepkg image up-to-date.

Run regularly:

```shell
docker-makepkg update
```

And update monthly the base image:

```shell
docker-makepkg base-update
```

## Remove

Remove the makepkg image:

```shell
docker-makepkg remove
```

Delete the git repository:

```shell
cd ..
rm -rf docker-archlinux-builder
```

## Issues and Contributing

If you have any issues or suggestions, feel free to open an [issue](https://github.com/fliegwerk/docker-archlinux-builder/issues)
or write us: <https://www.fliegwerk.com/contact>

## Project Information

This is a project by fliegwerk: <https://www.fliegwerk.com/>
