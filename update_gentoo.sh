#!/usr/bin/env bash
set -euo pipefail

OPTIONS=('--ask' '--keep-going')
JOBS='--jobs=2'


if [[ $(id -u) -ne 0 ]]; then
    printf "Script must be run as root!\n"
    exit 1
fi

eix-sync

emerge "${OPTIONS[@]}" ${JOBS} --quiet-build --update --deep --with-bdeps=y --newuse @world
emerge "${OPTIONS[@]}" ${JOBS} --oneshot @preserved-rebuild
emerge "${OPTIONS[@]}" ${JOBS} --depclean

revdep-rebuild
emaint all --fix
emaint logs --clean
wait

