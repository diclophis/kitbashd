#!/bin/sh

set -e
set -x

DISK=$1
KERNEL=tmp/vmlinuz-4.13.0-43-generic
INITRD=tmp/initrd.img-4.13.0-43-generic

if [ -z "$DISK" ];
then
  echo please specify disk
  exit 1
fi

IMPORTANT_ARGS="rw root=/dev/vda1"
CMDLINE="linux ${IMPORTANT_ARGS}"

MEM="-m 3G"
CPU="-c 3"
PCI_DEV="-s 0:0,hostbridge -s 31,lpc"
LPC_DEV=""
NET="-s 2:0,virtio-net,en0"
IMG_HDD="-s 4:0,virtio-blk,$DISK"

UUID="-U 8888badf-970e-4577-a6fa-6dd16c9d7795"

sudo hyperkit/build/hyperkit -A -H -P $CPU $MEM $PCI_DEV $LPC_DEV $NET $IMG_CD $IMG_HDD $UUID -f kexec,$KERNEL,$INITRD,"$CMDLINE"
