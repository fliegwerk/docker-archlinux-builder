FROM arch-base-builder:latest

COPY yay.tar.zst /

USER root

RUN pacman --upgrade --noconfirm --noprogressbar /yay.tar.zst

RUN usermod -aG wheel build
RUN echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers

USER build