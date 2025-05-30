#!/bin/bash
set -eu

HTTP_SERVER=112.124.9.243

# hack for me
[ -f /etc/friendlyarm ] && source /etc/friendlyarm $(basename $(builtin cd ..; pwd))

# clean
mkdir -p tmp
sudo rm -rf tmp/*

cd tmp
git clone ../../.git sd-fuse_rk3576
cd sd-fuse_rk3576


wget --no-proxy http://${HTTP_SERVER}/dvdfiles/RK3576/images-for-eflasher/friendlycore-focal-arm64-images.tgz
tar xzf friendlycore-focal-arm64-images.tgz

wget --no-proxy http://${HTTP_SERVER}/dvdfiles/RK3576/images-for-eflasher/openmediavault-arm64-images.tgz
tar xzf openmediavault-arm64-images.tgz

wget --no-proxy http://${HTTP_SERVER}/dvdfiles/RK3576/images-for-eflasher/friendlywrt23-images.tgz
tar xzf friendlywrt23-images.tgz

wget --no-proxy http://${HTTP_SERVER}/dvdfiles/RK3576/images-for-eflasher/friendlywrt23-docker-images.tgz
tar xzf friendlywrt23-docker-images.tgz

wget --no-proxy http://${HTTP_SERVER}/dvdfiles/RK3576/images-for-eflasher/friendlywrt21-images.tgz
tar xzf friendlywrt21-images.tgz

wget --no-proxy http://${HTTP_SERVER}/dvdfiles/RK3576/images-for-eflasher/friendlywrt21-docker-images.tgz
tar xzf friendlywrt21-docker-images.tgz

wget --no-proxy http://${HTTP_SERVER}/dvdfiles/RK3576/images-for-eflasher/emmc-flasher-images.tgz
tar xzf emmc-flasher-images.tgz

wget --no-proxy http://${HTTP_SERVER}/dvdfiles/RK3576/images-for-eflasher/debian-buster-desktop-arm64-images.tgz
tar xzf debian-buster-desktop-arm64-images.tgz

wget --no-proxy http://${HTTP_SERVER}/dvdfiles/RK3576/images-for-eflasher/debian-bullseye-desktop-arm64-images.tgz
tar xzf debian-bullseye-desktop-arm64-images.tgz

wget --no-proxy http://${HTTP_SERVER}/dvdfiles/RK3576/images-for-eflasher/debian-bookworm-core-arm64-images.tgz
tar xzf debian-bookworm-core-arm64-images.tgz

wget --no-proxy http://${HTTP_SERVER}/dvdfiles/RK3576/images-for-eflasher/debian-bullseye-minimal-arm64-images.tgz
tar xzf debian-bullseye-minimal-arm64-images.tgz

wget --no-proxy http://${HTTP_SERVER}/dvdfiles/RK3576/images-for-eflasher/ubuntu-jammy-desktop-arm64-images.tgz
tar xzf ubuntu-jammy-desktop-arm64-images.tgz

wget --no-proxy http://${HTTP_SERVER}/dvdfiles/RK3576/images-for-eflasher/ubuntu-jammy-minimal-arm64-images.tgz
tar xzf ubuntu-jammy-minimal-arm64-images.tgz

./mk-sd-image.sh debian-buster-desktop-arm64
./mk-emmc-image.sh debian-buster-desktop-arm64

./mk-sd-image.sh debian-bullseye-desktop-arm64
./mk-emmc-image.sh debian-bullseye-desktop-arm64

./mk-sd-image.sh debian-bookworm-core-arm64
./mk-emmc-image.sh debian-bookworm-core-arm64

./mk-sd-image.sh debian-bullseye-minimal-arm64
./mk-emmc-image.sh debian-bullseye-minimal-arm64

./mk-sd-image.sh ubuntu-jammy-desktop-arm64
./mk-emmc-image.sh ubuntu-jammy-desktop-arm64

./mk-sd-image.sh ubuntu-jammy-minimal-arm64
./mk-emmc-image.sh ubuntu-jammy-minimal-arm64

./mk-sd-image.sh friendlywrt23
./mk-emmc-image.sh friendlywrt23

./mk-sd-image.sh friendlywrt23-docker
./mk-emmc-image.sh friendlywrt23-docker

./mk-sd-image.sh friendlywrt21
./mk-emmc-image.sh friendlywrt21

./mk-sd-image.sh friendlywrt21-docker
./mk-emmc-image.sh friendlywrt21-docker

./mk-sd-image.sh friendlycore-focal-arm64
./mk-emmc-image.sh friendlycore-focal-arm64

./mk-sd-image.sh openmediavault-arm64
./mk-emmc-image.sh openmediavault-arm64

./mk-emmc-image.sh ubuntu-jammy-desktop-arm64 filename=ubuntu-jammy-desktop-arm64-auto-eflasher.img autostart=yes

echo "done."
