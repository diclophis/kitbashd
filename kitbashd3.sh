#!/bin/sh

set -e
set -x

DISK=$1
UUID=$2
BUSYBOX=$3

KERNEL=tmp/vmlinuz-4.13.0-43-generic
INITRD=tmp/initrd.img-4.13.0-43-generic

#NOTE: broken
#KERNEL=tmp/vmlinuz-4.13.0-36-generic
#INITRD=tmp/extras.img

if [ -n "${BUSYBOX}" ];
then
  #NOTE: busybox
  KERNEL=tmp/linux
  INITRD=tmp/rootfs-empty.gz
fi

#tmp/extras/boot/vmlinuz-4.13.0-36-generic
#INITRD=tmp/initrd-2.0b.gz

#if [ test -z "${DISK}" || ! test -e "${DISK}" ];
#then
#  echo please specify existing disk file
#  exit 1
#fi

if [ -z "$UUID" ];
then
  echo please specify UUID
  exit 1
fi

#IMPORTANT_ARGS="rw root=/dev/vda1 console=ttyS0,1152000n8 systemd.journald.forward_to_console=1"
#IMPORTANT_ARGS="rw root=/dev/vda1 console=tty0 console=ttyS0,115200n8 net.ifnames=0 biosdevname=0 modules=virtio_blk,af_socket,loop,squashfs,sd-mod,usb-storage,sr-mod,ext4 debug_init"
IMPORTANT_ARGS="rw root=/dev/vda1 console=tty0 console=ttyS0,115200n8 net.ifnames=0 biosdevname=0"
CMDLINE="linux ${IMPORTANT_ARGS} init=/bin/init"

MEM="-m 3G"
CPU="-c 6"
PCI_DEV="-s 0:0,hostbridge -s 31,lpc"
LPC_DEV="-l com1,stdio"
NET="-s 2:0,virtio-net,en0"
IMG_HDD="-s 4:0,virtio-blk,$DISK"

UUID="-U $UUID"

sudo hyperkit/build/hyperkit -A -H -P $CPU $MEM $PCI_DEV $LPC_DEV $NET $IMG_CD $IMG_HDD $UUID -f kexec,$KERNEL,$INITRD,"$CMDLINE"
