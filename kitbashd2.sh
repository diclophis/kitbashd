#!/bin/sh

set -e
set -x

DISK=$1
#TODO: figure out re-bootstrap initrd from installer
#KERNEL=tmp/vmlinuz-4.13.0-43-generic
#INITRD=tmp/initrd.img-4.13.0-43-generic
KERNEL=tmp/linux
INITRD=tmp/initrd-2.0.gz

if [ -z "$DISK" ];
then
  echo please specify disk
  exit 1
fi

if [[ $DISK != tmp/* ]];
then
  echo please only use files in local tmp dir
  exit 1
fi

dd if=/dev/zero of=$DISK bs=1024k seek=8192 count=0

IMPORTANT_ARGS="console=tty0 console=ttyS0,115200n8 rw"
CMDLINE="linux ${IMPORTANT_ARGS} ks=file:/workstation-install.cfg"

MEM="-m 1G"
PCI_DEV="-s 0:0,hostbridge -s 31,lpc"
LPC_DEV="-l com1,stdio"
NET="-s 2:0,virtio-net,en0"
IMG_HDD="-s 4:0,virtio-blk,$DISK"
UUID="-U 8888badf-970e-4577-a6fa-6dd16c9d7795"

sudo hyperkit/build/hyperkit -A -H -P $MEM $PCI_DEV $LPC_DEV $NET $IMG_CD $IMG_HDD $UUID -f kexec,$KERNEL,$INITRD,"$CMDLINE"
