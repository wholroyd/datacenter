#!/bin/bash

function do_install() {

	# Create required locations
	mkdir /var/lib/$_program &> /dev/null #Data Directory
	mkdir /var/log/$_program &> /dev/null #Logging
	mkdir /etc/$_program     &> /dev/null #Configuration

	# Create group and user accounts
	getent group $_program >/dev/null || groupadd -r $_program
	getent passwd $_program >/dev/null || \
	    useradd -r -g $_program -d /var/lib/$_program -s /sbin/nologin \
	    -c "$_program user" $_program

	# Determine bitness of operating system and download latest version
	local _bitness=$(uname -m)
	local _versionlist
	local _versionpage=$(curl -L https://dl.bintray.com/mitchellh/$_program/)

	if [ ${_bitness} == 'x86_64' ]; then
		_versionlist=$(echo $_versionpage | grep -o '[a-z0-9._]*linux_amd64\.zip' | uniq)
	else
		_versionlist=$(echo $_versionpage | grep -o '[a-z0-9._]*linux_386\.zip' | uniq)
	fi

	curl -L https://dl.bintray.com/mitchellh/$_program/$_versionlist[-1] /tmp/$_program_$_versionlist[-1].zip

	# Expand and cleanup archive
	unzip /tmp/$_program_${_versionlist[-1]}.zip
	rm /tmp/$_program_${_versionlist[-1]}.zip

	# Install binary
	mv /tmp/$_program /usr/bin
	chmod 755 /usr/bin/$_program

	# Install configuration files
	cp $_program/$_program.service /usr/lib/systemd/system
    cp $_program/$_program.sysconfig-$_configuration /etc/sysconfig/$_program

	# Setup service
	systemctl preset $_program.service
	systemctl enable $_program.service
	systemctl start $_program.service
}

function do_uninstall {

	# Teardown service
	systemctl disable $_program.service

	# Delete configuration
	rm /etc/sysconfig/$_program
	rm /usr/lib/systemd/system/$_program

	# Delete binary
	rm /usr/bin/$_program

	# Delete required locations
	rm -rf /var/lib/$_program &> /dev/null #Data Directory
	rm -rf /var/log/$_program &> /dev/null #Logging
	rm -rf /etc/$_program     &> /dev/null #Configuration
}

case "$1" in
    install)
		# We need to check the value of these
		_program=$2
		_configuration=$3

        do_install
        ;;
    uninstall)
		# We need to check the value of this
		_program=$2

        do_uninstall
        ;;
    *)
        echo $"Usage: $0 install {service} {config}"
        echo $"       $0 uninstall {service}"
        echo $""
        echo $"       "

        exit 2
esac

exit $?