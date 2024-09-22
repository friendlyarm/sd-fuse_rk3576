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
wget --no-proxy http://${HTTP_SERVER}/dvdfiles/RK3576/images-for-eflasher/ubuntu-jammy-minimal-arm64-images.tgz
tar xzf ubuntu-jammy-minimal-arm64-images.tgz
wget --no-proxy http://${HTTP_SERVER}/dvdfiles/RK3576/images-for-eflasher/emmc-flasher-images.tgz
tar xzf emmc-flasher-images.tgz
wget --no-proxy http://${HTTP_SERVER}/dvdfiles/RK3576/rootfs/rootfs-ubuntu-jammy-minimal-arm64.tgz

sudo tar xzfp rootfs-ubuntu-jammy-minimal-arm64.tgz --numeric-owner --same-owner
echo hello > ubuntu-jammy-minimal-arm64/rootfs/home/pi/welcome.txt
sudo ./build-rootfs-img.sh ubuntu-jammy-minimal-arm64/rootfs ubuntu-jammy-minimal-arm64

./mk-sd-image.sh ubuntu-jammy-minimal-arm64
./mk-emmc-image.sh ubuntu-jammy-minimal-arm64
