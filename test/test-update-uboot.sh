#!/bin/bash
set -eux

HTTP_SERVER=112.124.9.243
UBOOT_REPO=https://github.com/friendlyarm/uboot-rockchip
UBOOT_BRANCH=nanopi5-v2017.09

# hack for me
[ -f /etc/friendlyarm ] && source /etc/friendlyarm $(basename $(builtin cd ..; pwd))

# clean
mkdir -p tmp
sudo rm -rf tmp/*

cd tmp
git clone ../../.git sd-fuse_rk3576
cd sd-fuse_rk3576
if [ -f ../../ubuntu-jammy-minimal-arm64-images.tgz ]; then
	tar xvzf ../../ubuntu-jammy-minimal-arm64-images.tgz
else
	wget --no-proxy http://${HTTP_SERVER}/dvdfiles/RK3576/images-for-eflasher/ubuntu-jammy-minimal-arm64-images.tgz
    tar xvzf ubuntu-jammy-minimal-arm64-images.tgz
fi

git clone ${UBOOT_REPO} --depth 1 -b ${UBOOT_BRANCH} uboot-rk3576
[ -d rkbin ] || git clone https://github.com/friendlyarm/rkbin --depth 1 -b nanopi6
UBOOT_SRC=$PWD/uboot-rk3576 ./build-uboot.sh ubuntu-jammy-minimal-arm64
sudo ./mk-sd-image.sh ubuntu-jammy-minimal-arm64
