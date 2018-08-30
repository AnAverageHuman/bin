#!/usr/bin/env bash
set -euo pipefail

renice +10 $$

OPTIONS=('--alert' '--ask' '--backtrack=10000' '--binpkg-changed-deps' '--binpkg-respect-use' '--keep-going' '--quiet' '--verbose-conflicts')
JOBS=1


if [[ $(id -u) -ne 0 ]]; then
    printf "Script must be run as root!\n"
    exit 1
fi

eix-sync -q

emerge "${OPTIONS[@]}" --jobs=${JOBS:-1} "$@" --complete-graph --deep --newuse --update --usepkg --with-bdeps=y @world
emerge "${OPTIONS[@]}" --jobs=${JOBS:-1} --depclean
emerge "${OPTIONS[@]}" --jobs=${JOBS:-1} --oneshot @preserved-rebuild

revdep-rebuild --quiet
emaint all --fix
emaint logs --clean
eclean-dist --deep --time-limit=1m --quiet
eclean-pkg --deep --time-limit=1m --quiet

prelink -amR

