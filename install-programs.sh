#!/bin/bash

OS="Invalid"
DEBUG="false"

function install_docker {
	if [ $OS == "Fedora" ]; then
		dnf install -y docker
	elif [ $OS == "Arch" ]; then
		pacman -S docker --noconfirm --needed
	elif [ $OS == "Ubuntu" ]; then
		apt-get install -y docker
	else
		echo "Invalid OS"
	fi
	echo "Running docker"
	systemctl start docker
}

function check_root {
	if [ $(id -u) != "0" ]; then
		echo "This script must be run as root"
		exit 1
	fi
}

function get_os {
	echo "Checking OS"
	dnf > /dev/null 2>&1
	if [ $? -eq 1 ] 
	then
		echo "Fedora detected";
		OS="Fedora"
	fi

	apt-get > /dev/null 2>&1
	if [ $? -eq 1 ] 
	then
		echo "Ubuntu detected";
		OS="Ubuntu"
	fi

	pacman > /dev/null 2>&1
	if [ $? -eq 1 ]
	then
		echo "Arch Linux detected";
		OS="Arch"
	fi

	if [ $OS == "Invalid" ]
	then
		echo "Couldn't detect OS"
		exit
	fi
}

function install_programs {
	echo "Install Programs"
	if [ $OS == "Arch" ]
	then
		pacman -S --noconfirm --needed qemu qemu-arch-extra libvirt git make cmake curl
	fi

	if [ $OS == "Fedora" ]
	then
		dnf install -y qemu qemu-system-* make cmake curl
	fi

	if [ $OS == "Ubuntu" ]
	then
		apt-get install -y qemu qemu-system-* make cmake curl
	fi
}

check_root
while [[ $# -gt 0 ]]
do
	key="$1"

	case $key in
		-d|--debug)
			echo "Enabling debugging"
			DEBUG="true"
			;;
		--nfs)
			echo "Enabling nfs"
			if [ ! -d $2 ]; then
				echo "Invalid path"
				exit 1
			else
				echo "Path found"
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
get_os
install_programs
if [ $DEBUG == "true" ]; then
	install_docker
fi
