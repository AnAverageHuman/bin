#!/bin/bash
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

emerge --sync

if hash eix-update 2>/dev/null; then
    eix-update
fi

emerge --ask --quiet-build --update --deep --with-bdeps=y --newuse @world
emerge --ask --depclean
revdep-rebuild

