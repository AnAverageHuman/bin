#!/usr/bin/env bash
## Configure and compile kernel
set -euo pipefail

if [[ $(id -u) -ne 0 ]]; then
    printf "Script must be run as root!\n"
    exit 1
fi

MAKEOPTS=("-j4")
CWD=$(pwd)

BOOT=
mountpoint /boot || BOOT=1

back() {
    cd "$CWD"
}
trap back EXIT

cd /usr/src/linux || exit
make "${MAKEOPTS[@]}" nconfig
make "${MAKEOPTS[@]}"
make "${MAKEOPTS[@]}" modules_prepare

if [ $BOOT -eq 1 ]; then mount /boot; fi
make "${MAKEOPTS[@]}" install
make "${MAKEOPTS[@]}" modules_install
genkernel --lvm initramfs
grub-mkconfig -o /boot/grub/grub.cfg
if [ $BOOT -eq 1 ]; then umount /boot; fi

