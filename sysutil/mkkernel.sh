#!/usr/bin/env bash
## Configure and compile kernel
set -euo pipefail

if [[ $(id -u) -ne 0 ]]; then
    printf "Script must be run as root!\n"
    exit 1
fi

MAKEOPTS=("-j4")

mountpoint /boot && BOOT=0 || BOOT=1

pushd /usr/src/linux > /dev/null || exit

function cleanup {
    popd > /dev/null
    [ $BOOT -eq 1 ] && umount /boot
}

trap cleanup INT TERM

make "${MAKEOPTS[@]}" silentoldconfig
make "${MAKEOPTS[@]}" nconfig
make "${MAKEOPTS[@]}"
#make "${MAKEOPTS[@]}" modules_prepare

[ $BOOT -eq 1 ] && mount /boot
make "${MAKEOPTS[@]}" install
#make "${MAKEOPTS[@]}" modules_install
genkernel --lvm initramfs
grub-mkconfig -o /boot/grub/grub.cfg

cleanup

