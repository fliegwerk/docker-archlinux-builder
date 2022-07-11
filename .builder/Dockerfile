FROM archlinux:base-devel

# the uid of the user
ARG BUILD_USER_ID
# the uid of the users group
ARG BUILD_GROUP_ID

# path to the build directory for the package you want to build
ENV BUILD_DIR /package
# the name of the build user
ENV BUILD_USERNAME build

# update image to latest available base packages
RUN pacman --sync --refresh --sysupgrade --noconfirm --noprogressbar --quiet
RUN pacman --sync --noconfirm --noprogressbar --quiet --needed git namcap go
RUN yes | pacman --sync --clean --clean

# add build user with sudo privileges
RUN groupadd --gid "$BUILD_GROUP_ID" --force "$BUILD_USERNAME" && \
  useradd --uid "$BUILD_USER_ID" --gid "$BUILD_GROUP_ID" --groups wheel --create-home --comment "Arch Build User" "$BUILD_USERNAME"
RUN echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers

# create placeholder folder for the package that you want to build
RUN mkdir "$BUILD_DIR" && chown "$BUILD_USERNAME:$BUILD_USERNAME" "$BUILD_DIR"

# copy build script
COPY package.sh /usr/local/bin/package 
RUN chmod +x /usr/local/bin/package

ENV LANG en_US.UTF-8
ENV HOME /home/build

# build and install yay
WORKDIR "$BUILD_DIR"
USER "$BUILD_USERNAME"
RUN git clone 'https://aur.archlinux.org/yay.git' yay && cd yay && makepkg
USER root
RUN pacman --upgrade --noconfirm --noprogressbar yay/*.pkg.tar.zst
USER "$BUILD_USERNAME"
RUN rm -rf yay

CMD ["package", "--force", "--clean", "--cleanbuild"]