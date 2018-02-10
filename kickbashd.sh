#!/bin/sh

set -e
set -x

mkdir -p tmp

if [ ! -e tmp/got-wgets ];
then
  cd tmp
  wget http://archive.ubuntu.com/ubuntu/dists/xenial-updates/main/installer-amd64/current/images/hwe-netboot/mini.iso
  wget http://releases.ubuntu.com/xenial/ubuntu-16.04.3-server-amd64.iso
  wget http://security.ubuntu.com/ubuntu/pool/main/l/linux-hwe/linux-image-extra-4.13.0-33-generic_4.13.0-33.36~16.04.1_amd64.deb
  touch got-wgets
fi

# working fat32 ufi hybrid!

        #BOOTDISK_DEV=${1}

        cd tmp

        #sudo umount ${BOOTDISK_DEV}1 || true
        sudo umount ubuntu-16.04.3-server-amd64.iso server-iso || true
        sudo umount mini.iso || true

        #sudo sgdisk --zap-all ${BOOTDISK_DEV}
        #sudo sgdisk --new=1:0:0 --typecode=1:ef00 ${BOOTDISK_DEV}
        #sudo umount ${BOOTDISK_DEV}1 || true
        #sudo mkfs.vfat -v -F32 -n GRUB2EFI ${BOOTDISK_DEV}1
        #mkdir -p /var/tmp/new-iso && sudo mount -t vfat ${BOOTDISK_DEV}1 /var/tmp/new-iso -o uid=1000,gid=1000,umask=022
        #rebake via re-layering from other isos
        #sh ~/sidecar/wgets.sh

        #mkdir -p extras
        #dpkg -x /var/tmp/linux-image-extra-4.8.0-36-generic_4.8.0-36.36~16.04.1_amd64.deb /var/tmp/extras
        #cd /var/tmp/extras
        #find . | cpio --quiet --dereference -o -H newc | gzip -9 > ~/extras.gz

        mkdir -p kickseeds
        cp seed.cfg kickseeds/
        cd kickseeds
        find . | cpio --quiet --dereference -o -H newc | gzip -9 > ../kickseeds.gz
        cd -

        mkdir -p server-iso
        mkdir -p new-iso
        sudo mount -o loop ubuntu-16.04.3-server-amd64.iso server-iso
        sudo cp -R server-iso/boot new-iso/
        sudo cp -R server-iso/EFI new-iso/

        mkdir -p mini-iso && sudo mount -o loop mini.iso mini-iso
        sudo cp -R mini-iso/* new-iso/

        cd ../rootfs-overlay
        shar . > ../tmp/new-iso/rootfs-overlay.sh
        cd -

# install extra initrds

        #cat tmp/mini-iso/initrd.gz ~/extras.gz ~/kickseeds.gz > /var/tmp/new-iso/initrd-2.0.gz
        cat tmp/mini-iso/initrd.gz tmp/kickseeds.gz > tmp/new-iso/initrd-2.0.gz

# install boot loader

        #TODO: figure out bootstrap rootfs better
        cp grub.cfg tmp/new-iso/boot/grub/grub.cfg

        #sudo parted ${BOOTDISK_DEV} set 1 bios_grub on
        #sudo grub-install --removable --boot-directory=/var/tmp/new-iso/boot --efi-directory=/var/tmp/new-iso/EFI/BOOT ${BOOTDISK_DEV} || true
        #sudo umount ${BOOTDISK_DEV}1
