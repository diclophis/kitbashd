#!/bin/sh

set -e
set -x

KERNEL=tmp/vmlinuz-4.13.0-43-generic
INITRD=tmp/initrd.img-4.13.0-43-generic

IMPORTANT_ARGS="console=tty0 console=ttyS0,115200n8 noipv6 rw ip=dhcp root=/dev/vda1"
#root=/dev/mapper/vg_hostname-lv_root"
CMDLINE="linux ${IMPORTANT_ARGS}"

MEM="-m 1G"
PCI_DEV="-s 0:0,hostbridge -s 31,lpc"
LPC_DEV="-l com1,stdio"
NET="-s 2:0,virtio-net,en0"
IMG_HDD="-s 4:0,virtio-blk,tmp/disk.img"

UUID="-U 8888badf-970e-4577-a6fa-6dd16c9d7795"

sudo hyperkit/build/hyperkit -A -H -P $MEM $PCI_DEV $LPC_DEV $NET $IMG_CD $IMG_HDD $UUID -f kexec,$KERNEL,$INITRD,"$CMDLINE"
