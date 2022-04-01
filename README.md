# docker-archlinux-builder

Management tool to build arch packages on docker

## Prerequisites

You need a working docker installation and some core utilities.

## Install

Clone this repository:

```shell
git clone https://github.com/fussel178/docker-archlinux-builder.git
cd docker-archlinux-builder
```

Prepare the build environment:

```shell
./arch-builder.sh prepare
```

Initialize a new build setup for your package.
Get git url if your package is an AUR package.

```shell
./arch-builder.sh init https://aur.archlinux.org/ungoogled-chromium.git
```

Run the build step for your initialized package:

```shell
./ungoogled-chromium/manage.sh build
```

## Remove

First, clean up built docker images:

```shell
./ungoogled-chromium/manage.sh clean
```

Then, clean up the base system:

```shell
./arch-builder.sh clean
```

Finally, remove the git repository:

```shell
cd ..
rm -rf docker-archlinux-builder
```

## Acknowledgements

Many thanks to [Spencer Rinehart](https://github.com/nubs)
for his awesome project [docker-arch-build](https://github.com/nubs/docker-arch-build).
