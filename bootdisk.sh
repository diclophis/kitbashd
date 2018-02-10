#!/bin/sh

#TODO: add dialog and make safety net for formatting disks

set -e
set -x

# working fat32 ufi hybrid!

        BOOTDISK_DEV=${1}

        cd /var/tmp

        sudo umount ${BOOTDISK_DEV}1 || true
        sudo umount /var/tmp/ubuntu-16.04.2-server-amd64.iso server-iso || true
        sudo umount /var/tmp/mini.iso || true

        sudo sgdisk --zap-all ${BOOTDISK_DEV}
        sudo sgdisk --new=1:0:0 --typecode=1:ef00 ${BOOTDISK_DEV}
        sudo umount ${BOOTDISK_DEV}1 || true
        sudo mkfs.vfat -v -F32 -n GRUB2EFI ${BOOTDISK_DEV}1
        mkdir -p /var/tmp/new-iso && sudo mount -t vfat ${BOOTDISK_DEV}1 /var/tmp/new-iso -o uid=1000,gid=1000,umask=022

# rebake via re-layering from other isos
        
        #sh ~/sidecar/wgets.sh

        #mkdir -p /var/tmp/extras
        #dpkg -x /var/tmp/linux-image-extra-4.8.0-36-generic_4.8.0-36.36~16.04.1_amd64.deb /var/tmp/extras
        #cd /var/tmp/extras
        #find . | cpio --quiet --dereference -o -H newc | gzip -9 > ~/extras.gz

        mkdir -p /var/tmp/kickseeds
        cp ~/sidecar/workstation-install.cfg /var/tmp/kickseeds/
        cd /var/tmp/kickseeds
        find . | cpio --quiet --dereference -o -H newc | gzip -9 > ~/kickseeds.gz

        mkdir -p /var/tmp/server-iso && sudo mount -o loop /var/tmp/ubuntu-16.04.2-server-amd64.iso /var/tmp/server-iso
        sudo cp -R /var/tmp/server-iso/boot /var/tmp/new-iso/
        sudo cp -R /var/tmp/server-iso/EFI /var/tmp/new-iso/

        mkdir -p /var/tmp/mini-iso && sudo mount -o loop /var/tmp/mini.iso /var/tmp/mini-iso
        sudo cp -R /var/tmp/mini-iso/* /var/tmp/new-iso/

        cd ~/sidecar/rootfs-overlay
        shar . > /var/tmp/new-iso/rootfs-overlay.sh

# install extra initrds

        cat /var/tmp/mini-iso/initrd.gz ~/extras.gz ~/kickseeds.gz > /var/tmp/new-iso/initrd-2.0.gz

# install boot loader

        #TODO: figure out bootstrap rootfs better
        cp ~/sidecar/grub.cfg /var/tmp/new-iso/boot/grub/grub.cfg
        #sudo parted ${BOOTDISK_DEV} set 1 bios_grub on
        #sudo grub-install --removable --boot-directory=/var/tmp/new-iso/boot --efi-directory=/var/tmp/new-iso/EFI/BOOT ${BOOTDISK_DEV} || true
        sudo umount ${BOOTDISK_DEV}1
