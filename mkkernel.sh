#!/bin/bash
## Configure and compile kernel
set -euo pipefail

if [[ $(id -u) -ne 0 ]]; then
    if hash sudo 2>/dev/null; then
        printf "Restarting with root permissions using sudo.\n"
        sudo bash "$0" "$@"
        exit $?
    else
        printf "Script must be run as root!\n"
        exit 1
    fi
fi

MAKEOPTS="-j4"
CWD=$(pwd)

BOOT=
mountpoint /boot || BOOT=1

back() {
    cd "$CWD"
}
trap back EXIT

cd /usr/src/linux || exit
make $MAKEOPTS nconfig
make $MAKEOPTS
make $MAKEOPTS modules_prepare

if [ -z ${BOOT+x} ]; then mount /boot; fi
make $MAKEOPTS install
make $MAKEOPTS modules_install
genkernel --lvm initramfs
grub-mkconfig -o /boot/grub/grub.cfg
if [ -z ${BOOT+x} ]; then umount /boot; fi

