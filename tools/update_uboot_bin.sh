#!/bin/bash
set -eu

[ -f ${PWD}/mk-emmc-image.sh ] || {
	echo "Error: please run at the script's home dir"
	exit 1
}

if [ $# -ne 2 ]; then
	echo "number of args must be 2"
	exit 1
fi

LOADER_DOT_BIN=`ls $1/rk3576_spl_loader_*.bin 2>/dev/null | sort -n | tail -1`
if [ -f ${LOADER_DOT_BIN} ]; then
    cp -f ${LOADER_DOT_BIN} $2/MiniLoaderAll.bin
else
    echo "not found $1/rk3576_spl_loader_*.bin, pls build u-boot first."
    exit 1
fi
cp -f $1/uboot.img $2/

exit $?
