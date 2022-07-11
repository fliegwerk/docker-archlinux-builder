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
./arch-builder.sh create
```

Initialize a new build setup for your package.
Enter the package name of the AUR package you want to build:

```shell
./arch-builder.sh get-aur ungoogled-chromium
```

Or if you want to build an official package, use:

```shell
./arch-builder.sh get-official linux
```

Build your initialized package:

```shell
./arch-builder.sh build ungoogled-chromium
```

That's it!

## Update

Because Archlinux is a rolling-release distribution,
it's important that you keep the arch-builder image up-to-date.
The build step updates the system before building the specified package.
Some dependencies can only be updated, if you rebuild the arch-builder image.

### Update build instructions

Simply get the package again.
The arch-builder script detects an existing repository and only pulls in the latest changes:

```shell
./arch-builder.sh get-aur ungoogled-chromium
```

And build your package with the new instruction set:

```shell
./arch-builder.sh build ungoogled-chromium
```

### Update arch-builder image

Simply call:

```shell
./arch-builder.sh rebuild
```

## Remove

Remove the arch-builder image:

```shell
./arch-builder.sh remove
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
