#!/bin/bash
set -eu

[ -f ${PWD}/mk-emmc-image.sh ] || {
	echo "Error: please run at the script's home dir"
	exit 1
}

TOP=$PWD
true ${SOC:=rk3576}
KIMG=kernel.img
KDTB=resource.img
OUT=${PWD}/out

UBOOT_DIR=$1
KERNEL_DIR=$2
BOOT_DIR=$3
ROOTFS_DIR=$(readlink -f $4)
PREBUILT=$5
TARGET_OS=$(echo ${6,,}|sed 's/\///g')

# kernel bin
KMODULES_OUTDIR="${OUT}/output_${SOC}_kmodules"
(cd ${KERNEL_DIR} && {
	cp ${KIMG} ${KDTB} ${TOP}/${TARGET_OS}/
})

# rootfs
rm -rf ${ROOTFS_DIR}/lib/modules/*
(cd ${KMODULES_OUTDIR}/lib/ && {
        tar -cf - * | tar -xf - -p --same-owner --numeric-owner -C `readlink -f ${ROOTFS_DIR}/lib`
})

# firmware
(cd ${PREBUILT}/firmware && {
	./install.sh ${ROOTFS_DIR}
})

exit 0
