#!/bin/sh

set -e
set -x

KERNEL=tmp/linux
INITRD=tmp/initrd-2.0.gz

#linux /linux --- ks=file:/workstation-install.cfg net.ifnames=0 biosdevname=0
#initrd /initrd-2.0.gz
#CMDLINE="earlyprintk=earlyser console=ttyS0 acpi=off selinux=0 root=/dev/nfs rw ip=dhcp nfsroot=${NFS_ROOT} -- ks=nfs:${NFS_ROOT}/seed.cfg"
#CMDLINE="modules=virtio_blk,af_socket,loop,squashfs,sd-mod,usb-storage,sr-mod,ext4 debug_init earlyprintk=earlyser console=ttyS0 acpi=off selinux=0 root=/dev/nfs rw nfsroot=${NFS_ROOT} -- ks=nfs:${NFS_ROOT}/seed.cfg"
#CMDLINE="linux noipv6 console=tty0 console=lp0 console=ttyS0 loglevel=0 vga=normal initrd=initrd.gz ramdisk_size=16432 root=/dev/nfs rw DEBIAN_FRONTEND=text TERM=xterm-256color --" # ks=nfs:${NFS_ROOT}/seed.cfg"
#CMDLINE="linux noipv6 console=tty0 console=lp0 console=ttyS0 loglevel=0 vga=normal initrd=initrd.gz ramdisk_size=16432 root=/dev/nfs rw ip=dhcp nfsroot=${NFS_ROOT} TERM=xterm-256color -- ks=nfs:${NFS_ROOT}/seed.cfg"
#IMPORTANT_ARGS="noipv6 console=tty0 console=lp0 console=ttyS0 loglevel=0 vga=normal ramdisk_size=16432 rw ip=dhcp"
#IMPORTANT_ARGS="console=ttyS0 console=tty0 console=lp0 console=tty1 console=ttyS0 noipv6 ramdisk_size=16432 rw ip=dhcp"

IMPORTANT_ARGS="console=tty0 console=ttyS0,115200n8 noipv6 ramdisk_size=16432 rw ip=dhcp"
CMDLINE="linux ${IMPORTANT_ARGS} ks=file:/workstation-install.cfg"

# TERM=xterm-256color init=/bin/bash"
#IMPORTANT_ARGS="console=tty0 console=ttyS0,115200n8 noipv6 ramdisk_size=16432 rw ip=dhcp"
#CMDLINE="linux ${IMPORTANT_ARGS} root=/dev/nfs nfsroot=${NFS_ROOT} initrd=initrd.gz TERM=xterm-256color init=/bin/bash"
#noipv6 console=tty0 console=lp0 console=ttyS0 loglevel=0 vga=normal initrd=initrd.gz ramdisk_size=16432 root=/dev/nfs rw ip=dhcp nfsroot=${NFS_ROOT} TERM=xterm-256color -- ks=nfs:${NFS_ROOT}/seed.cfg"
#BOOTIF=eth0
#net.ifnames=0 biosdevname=0"

MEM="-m 1G"
PCI_DEV="-s 0:0,hostbridge -s 31,lpc"
LPC_DEV="-l com1,stdio"
NET="-s 2:0,virtio-net,en0"
#IMG_HDD="-s 4,virtio-blk,tmp/disk.img"
#IMG_HDD="-s 4,virtio-blk,tmp/disk.raw"
IMG_HDD="-s 4:0,virtio-blk,tmp/disk.img"
#?sync=&buffered=1,qcow-config=discard=false;compact_after_unmaps=0;keep_erased=0;runtime_asserts=false"
#NET="-s 2:0,virtio-vpnkit,path=/tmp/ethernet"
#NET="-s 2:0,virtio-vpnkit,path=/tmp/ethernet"
UUID="-U 8888badf-970e-4577-a6fa-6dd16c9d7795"

sudo hyperkit/build/hyperkit -A -H -P $MEM $PCI_DEV $LPC_DEV $NET $IMG_CD $IMG_HDD $UUID -f kexec,$KERNEL,$INITRD,"$CMDLINE"

## working fat32 ufi hybrid!
#
#        #BOOTDISK_DEV=${1}
#
#        cd tmp
#
#        #sudo umount ${BOOTDISK_DEV}1 || true
#        sudo umount ubuntu-16.04.3-server-amd64.iso server-iso || true
#        sudo umount mini.iso || true
#
#        #sudo sgdisk --zap-all ${BOOTDISK_DEV}
#        #sudo sgdisk --new=1:0:0 --typecode=1:ef00 ${BOOTDISK_DEV}
#        #sudo umount ${BOOTDISK_DEV}1 || true
#        #sudo mkfs.vfat -v -F32 -n GRUB2EFI ${BOOTDISK_DEV}1
#        #mkdir -p /var/tmp/new-iso && sudo mount -t vfat ${BOOTDISK_DEV}1 /var/tmp/new-iso -o uid=1000,gid=1000,umask=022
#        #rebake via re-layering from other isos
#        #sh ~/sidecar/wgets.sh
#
#        #mkdir -p extras
#        #dpkg -x /var/tmp/linux-image-extra-4.8.0-36-generic_4.8.0-36.36~16.04.1_amd64.deb /var/tmp/extras
#        #cd /var/tmp/extras
#        #find . | cpio --quiet --dereference -o -H newc | gzip -9 > ~/extras.gz
#
#        mkdir -p kickseeds
#        cp seed.cfg kickseeds/
#        cd kickseeds
#        find . | cpio --quiet --dereference -o -H newc | gzip -9 > ../kickseeds.gz
#        cd -
#
#        mkdir -p server-iso
#        mkdir -p new-iso
#        sudo mount -o loop ubuntu-16.04.3-server-amd64.iso server-iso
#        sudo cp -R server-iso/boot new-iso/
#        sudo cp -R server-iso/EFI new-iso/
#
#        mkdir -p mini-iso && sudo mount -o loop mini.iso mini-iso
#        sudo cp -R mini-iso/* new-iso/
#
#        cd ../rootfs-overlay
#        shar . > ../tmp/new-iso/rootfs-overlay.sh
#        cd -
#
## install extra initrds
#
#        #cat tmp/mini-iso/initrd.gz ~/extras.gz ~/kickseeds.gz > /var/tmp/new-iso/initrd-2.0.gz
#        cat tmp/mini-iso/initrd.gz tmp/kickseeds.gz > tmp/new-iso/initrd-2.0.gz
#
## install boot loader
#
#        #TODO: figure out bootstrap rootfs better
#        cp grub.cfg tmp/new-iso/boot/grub/grub.cfg
#
#        #sudo parted ${BOOTDISK_DEV} set 1 bios_grub on
#        #sudo grub-install --removable --boot-directory=/var/tmp/new-iso/boot --efi-directory=/var/tmp/new-iso/EFI/BOOT ${BOOTDISK_DEV} || true
#        #sudo umount ${BOOTDISK_DEV}1

# /opt/root//lib/systemd/system/getty\@.service
#
#    root@kickseed:~# cat /opt/root/etc/fstab 
#    # UNCONFIGURED FSTAB FOR BASE SYSTEM
#    #192.168.84.10:/opt/root / nfs (rw,relatime,vers=3,rsize=524288,wsize=524288,namlen=255,hard,nolock,proto=tcp,port=2049,timeo=7,retrans=10,sec=sys,local_lock=all,addr=192.168.84.10) 0 0
#    #/dev/nfs    /        nfs     defaults    1    1
#    tmpfs   /tmp         tmpfs   rw,nodev,nosuid,size=2G          0  0
#    /proc    /proc    proc    defaults   0 0
#    /sys     /sys     sysfs   defaults   0 0
 
#   #
#   source /etc/network/interfaces.d/*
#   
#   # The loopback network interface
#   auto lo
#   iface lo inet loopback
#   
#   # The primary network interface
#   auto enp0s2
#   iface enp0s2 inet dhcp

# sudo debootstrap --variant=minbase artful /opt/root
# /opt/root *(rw,insecure,async,no_root_squash,no_subtree_check,no_all_squash) 
