#!/bin/bash

DEBUG=""
KERNEL="prebuild"
BZIMAGE="./bzImage-x86"
KERNPATH=""
IMAGEPATH=""
INITRDPATH=""
ARCH="x86_64"
CMD="qemu-system-$ARCH"
GRAPHICS="--nographic"
ROOTAPPEND=""

while [[ $# -gt 0 ]]
do
	key="$1"

	case $key in
		-d|--debug)
			echo "Enabling debugging"
			DEBUG="true"
			;;
		-k|--kernel)
			case $2 in
				prebuild)
					echo "Using default prebuild"
					;;
				git|local)
					KERNEL=$2
					KERNPATH=$3
					echo "Setting kernel param $2 $3";
					shift
					;;
				*)
					echo "Invalid kernel parameter";
					exit 1
					;;
			esac		
			shift
			;;
		-i|--image)
			if [ -f $2 ]; then
				IMAGEPATH="-hda "$2
				ROOTAPPEND="root=/dev/sda"
				echo "Setting image path $2"
				shift
			else
				echo "Invalid image path $2"
				exit 1
			fi
			;;
		-ir|--initram)
			if [ -f $2 ]; then
				INITRDPATH="-initrd "$2
				echo "Setting image path $2"
				shift
			else
				echo "Invalid image path $2"
				exit 1
			fi
			;;	
		-g|--graphics)
			GRAPHICS=""
			shift
			;;
		-a|--arch)
			ARCH=$2
			if [ $ARCH == "x86" ]; then
				CMD="qemu-system-"$ARCH"_64"
			else
				CMD="qemu-system-$ARCH"
			fi
			shift
			;;		
		*)
			echo "Invalid parameter $key"
			# unknown option
			;;
	esac
	shift # past argument or value
done

if [ $KERNEL != prebuild ]; then
	echo "Creating command $KERNEL"
	case $KERNEL in
		git)
			echo "Cloning git repo"
			;;
		local)
			echo "Setting local path"
			BZIMAGE="$KERNPATH/arch/$ARCH/boot/bzImage"
			if [ ! -f $BZIMAGE ]; then
				echo "Invalid boot image"
				exit 1
			fi
			;;
		*)
			;;
	esac
fi

FULLCMD="$CMD -kernel $BZIMAGE $IMAGEPATH $INITRDPATH $GRAPHICS -device e1000,netdev=enp2s0 -netdev user,id=enp2s0,hostfwd=tcp::2222-:22 --enable-kvm -append \"$ROOTAPPEND console=ttyS0 vga=0x0343\""
echo "$FULLCMD"
eval $FULLCMD
