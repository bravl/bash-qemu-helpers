#!/bin/bash

DEBUG=""
KERNEL="prebuild"
BZIMAGE="./bzImage"
KERNPATH=""
ARCH="x86_64"
CMD="qemu-system-$ARCH"

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
				echo "Setting image path $2"
				shift
			else
				echo "Invalid image path $2"
				exit 1
			fi
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

FULLCMD="$CMD -kernel $BZIMAGE --nographic --enable-kvm -append \"console=ttyS0\""
echo "$FULLCMD"
#$FULLCMD
