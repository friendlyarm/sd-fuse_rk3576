#!/bin/bash
set -eu

[ -f ${PWD}/mk-emmc-image.sh ] || {
	echo "Error: please run at the script's home dir"
	exit 1
}

# Automatically re-run script under sudo if not root
if [ $(id -u) -ne 0 ]; then
    echo "Re-running script under sudo..."
    sudo --preserve-env "$0" "$@"
    exit
fi

TOP=$PWD
HOST_ARCH=
if uname -mpi | grep aarch64 >/dev/null; then
    HOST_ARCH="aarch64/"
fi

export MKE2FS_CONFIG="${TOP}/tools/mke2fs.conf"
if [ ! -f ${MKE2FS_CONFIG} ]; then
    echo "error: ${MKE2FS_CONFIG} not found."
    exit 1
fi
true ${MKFS:="${TOP}/tools/${HOST_ARCH}mke2fs"}

true ${SOC:=rk3576}
ARCH=arm64
KIMG=kernel.img
KDTB=resource.img
CROSS_COMPILE=aarch64-linux-gnu-
# ${OUT} ${KERNEL_SRC} ${TOPPATH}/${TARGET_OS} ${TOPPATH}/prebuilt
if [ $# -ne 4 ]; then
        echo "bug: missing arg, $0 needs four args"
        exit
fi
OUT=$1
KERNEL_BUILD_DIR=$2
TARGET_OS=$(echo ${3,,}|sed 's/\///g')
PREBUILT=$4
KMODULES_OUTDIR="${OUT}/output_${SOC}_kmodules"

(cd ${KERNEL_BUILD_DIR} && {
	cp ${KIMG} ${KDTB} ${TOP}/${TARGET_OS}/
})

# copy kernel modules to rootfs.img
if [ -f ${TARGET_OS}/rootfs.img ]; then
    echo "copying kernel module and firmware to rootfs ..."

    # Extract rootfs from img
    simg2img ${TARGET_OS}/rootfs.img ${TARGET_OS}/r.img
    mkdir -p ${OUT}/rootfs_mnt
    mkdir -p ${OUT}/rootfs_new
    mount -t ext4 -o loop ${TARGET_OS}/r.img ${OUT}/rootfs_mnt
    if [ $? -ne 0 ]; then
        echo "failed to mount ${TARGET_OS}/r.img."
        exit 1
    fi
    rm -rf ${OUT}/rootfs_new/*
    cp -af ${OUT}/rootfs_mnt/* ${OUT}/rootfs_new/
    umount ${OUT}/rootfs_mnt
    rm -rf ${OUT}/rootfs_mnt
    rm -f ${TARGET_OS}/r.img
	
    [ -d ${KMODULES_OUTDIR}/lib/firmware ] && cp -af ${KMODULES_OUTDIR}/lib/firmware/* ${OUT}/rootfs_new/lib/firmware/
    rm -rf ${OUT}/rootfs_new/lib/modules/*
    cp -af ${KMODULES_OUTDIR}/lib/modules/* ${OUT}/rootfs_new/lib/modules/

    MKFS_OPTS="-E android_sparse -t ext4 -L rootfs -M /root -b 4096"
    case ${TARGET_OS} in
    friendlywrt* | buildroot*)
        # set default uid/gid to 0
        MKFS_OPTS="-0 ${MKFS_OPTS}"
        ;;
    *)
        ;;
    esac

    # Make rootfs.img
    ROOTFS_DIR=${OUT}/rootfs_new

    case ${TARGET_OS} in
    friendlywrt*)
        echo "prepare kernel modules for friendlywrt ..."
        ${TOP}/tools/prepare_friendlywrt_kernelmodules.sh ${ROOTFS_DIR}
        ;;
    *)
        ;;
    esac

    # clean device files
    (cd ${ROOTFS_DIR}/dev && find . ! -type d -exec rm {} \;)
    # calc image size
    IMG_SIZE=$(((`du -s -B64M ${ROOTFS_DIR} | cut -f1` + 3) * 1024 * 1024 * 64))
    IMG_BLK=$((${IMG_SIZE} / 4096))
    INODE_SIZE=$((`find ${ROOTFS_DIR} | wc -l` + 128))
    # make fs
    [ -f ${TARGET_OS}/rootfs.img ] && rm -f ${TARGET_OS}/rootfs.img
    ${MKFS} -N ${INODE_SIZE} ${MKFS_OPTS} -d ${ROOTFS_DIR} ${TARGET_OS}/rootfs.img ${IMG_BLK}

    if [ ${TARGET_OS} != "eflasher" ]; then
        case ${TARGET_OS} in
        openmediavault-*)
            # disable overlayfs for openmediavault
            cp ${TOP}/prebuilt/parameter-plain.txt ${TOP}/${TARGET_OS}/parameter.txt
            ;;
        friendlywrt*docker)
            PARAMETER_TPL="${TOP}/prebuilt/parameter-opt.template" \
                ${TOP}/tools/generate-partmap-txt.sh ${IMG_SIZE} ${TARGET_OS}
            ;;
        *)
            PARAMETER_TPL="${TOP}/prebuilt/parameter.template" \
                ${TOP}/tools/generate-partmap-txt.sh ${IMG_SIZE} ${TARGET_OS}
            ;;
        esac
    fi
else 
    echo "not found ${TARGET_OS}/rootfs.img"
    exit 1
fi
