#!/bin/sh

set -e
set -x

rm -Rf tmp/disk.img

dd if=/dev/zero of=tmp/disk.img bs=1024k seek=4096 count=0

KERNEL=tmp/linux
INITRD=tmp/initrd-2.0.gz

IMPORTANT_ARGS="console=tty0 console=ttyS0,115200n8 noipv6 ramdisk_size=16432 rw ip=dhcp"
CMDLINE="linux ${IMPORTANT_ARGS} ks=file:/workstation-install.cfg"

MEM="-m 1G"
PCI_DEV="-s 0:0,hostbridge -s 31,lpc"
LPC_DEV="-l com1,stdio"
NET="-s 2:0,virtio-net,en0"
IMG_HDD="-s 4:0,virtio-blk,tmp/disk.img"
UUID="-U 8888badf-970e-4577-a6fa-6dd16c9d7795"

sudo hyperkit/build/hyperkit -A -H -P $MEM $PCI_DEV $LPC_DEV $NET $IMG_CD $IMG_HDD $UUID -f kexec,$KERNEL,$INITRD,"$CMDLINE"
