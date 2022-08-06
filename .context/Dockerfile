FROM archlinux:base-devel

##
## everything below this comment is invalidated
## once the archlinux image updates
##

# the uid of the user
ARG BUILD_USER_ID
# the uid of the users group
ARG BUILD_GROUP_ID

# path to the build directory for the package you want to build
ENV BUILD_DIR /package
# the name of the build user
ENV BUILD_USERNAME build

# copy makepkg wrapper
COPY entrypoint makepkg* /usr/local/bin/
RUN chmod +x /usr/local/bin/*

# add build user with sudo privileges
RUN groupadd --gid "$BUILD_GROUP_ID" --force "$BUILD_USERNAME" && \
  useradd \
    --uid "$BUILD_USER_ID" \
    --gid "$BUILD_GROUP_ID" \
    --groups wheel \
    --create-home \
    --comment "Arch Build User" \
    "$BUILD_USERNAME" && \
  echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers

# create placeholder folder for the package that you want to build
RUN mkdir "$BUILD_DIR" && chown "$BUILD_USERNAME:$BUILD_USERNAME" "$BUILD_DIR"

# switch to build user
USER "$BUILD_USERNAME"
WORKDIR "$BUILD_DIR"

##
## everything below this comment is invalidated
## on every build call
##
ARG CACHEBUST

# update system packages and install needed base packages
RUN --mount=type=cache,target=/var/cache/pacman/pkg \
  sudo pacman --sync --refresh --sysupgrade --noconfirm --noprogressbar --quiet && \
  sudo pacman --sync --noconfirm --noprogressbar --quiet --needed git namcap go

# clone and build yay
RUN --mount=type=tmpfs,target=/build \
  cd /build && \
  git clone 'https://aur.archlinux.org/yay.git' yay && \
  cd yay && /usr/bin/makepkg --install --noconfirm --needed --noprogressbar

ENV LANG en_US.UTF-8
ENV HOME /home/build

ENTRYPOINT ["/usr/local/bin/entrypoint"]
CMD ["makepkg", "--syncdeps", "--clean", "--cleanbuild"]