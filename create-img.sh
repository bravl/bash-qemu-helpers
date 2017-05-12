#!/bin/bash
TYPE="invalid"

while [[  $# -gt 0 ]]
do
	key="$1"
	case $key in
		-d|--debug)
			echo "Enable debugging"
			;;
		-t|--type)
			echo "Setting type $2"
			TYPE=$2
			shift
			;;
	esac
	shift
done

if [ $TYPE == "invalid" ]; then
	echo "Usage: ./create-img.sh -t <debian or busybox>"
	exit 1
fi

if [ $TYPE == "busybox" ]; then
	echo "Creating busybox image"
	TOP="$(pwd)/busybox"
	mkdir busybox
	cd busybox
	curl https://busybox.net/downloads/busybox-1.26.2.tar.bz2 | tar xjf -
	cd busybox-1.26.2
	mkdir -pv ../obj/busybox-x86
	make O=../obj/busybox-x86 defconfig
	cd ../obj/busybox-x86/
	cp ../../../.config ./
	make -j8
	make install
	mkdir -pv $TOP/initramfs/x86-busybox
	cd $TOP/initramfs/x86-busybox
	mkdir -pv {bin,sbin,etc,proc,sys,usr/{bin,sbin}}
	cp -av $TOP/obj/busybox-x86/_install/* .
	cp $TOP/../init ./
	chmod +x ./init
	find . -print0 | cpio --null -ov --format=newc | gzip -9 > $TOP/../initramfs-busybox-x86.cpio.gz

elif [ $TYPE == "debian" ]; then
	echo "Creating debian image"
	IMG=qemu-image.img
	DIR=mount-point.dir
	qemu-img create debian.img 1g
	mkfs.ext2 debian.img
	mkdir debian-img
	sudo mount -o loop debian.img debian-img
	sudo debootstrap --arch amd64 jessie debian-img
	sudo umount debian-img
	# Keeping the directory is not necessary. However it's usefull to move files to the image
	rmdir debian-img
fi
