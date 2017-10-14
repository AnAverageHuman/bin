#!/usr/bin/env bash
set -euo pipefail

OPTIONS=('--ask' '--alert' '--keep-going' '--backtrack=10000' '--verbose-conflicts' '--binpkg-respect-use' '--binpkg-changed-deps')
JOBS=1


if [[ $(id -u) -ne 0 ]]; then
    printf "Script must be run as root!\n"
    exit 1
fi

eix-sync -q

emerge "${OPTIONS[@]}" --jobs=${JOBS:-1} "$@" --complete-graph --deep --newuse --quiet-build --quiet-fail --update --usepkg --with-bdeps=y @world
emerge "${OPTIONS[@]}" --jobs=${JOBS:-1} --depclean
emerge "${OPTIONS[@]}" --jobs=${JOBS:-1} --quiet-build --oneshot @preserved-rebuild

revdep-rebuild
emaint all --fix
emaint logs --clean
eclean-dist --deep --time-limit=1m --quiet
eclean-pkg --deep --time-limit=1m --quiet

prelink -amR
