#!/usr/bin/env bash
set -euo pipefail

OPTIONS=('--ask' '--keep-going' '--backtrack=10000' '--verbose-conflicts')
JOBS=1


if [[ $(id -u) -ne 0 ]]; then
    printf "Script must be run as root!\n"
    exit 1
fi

eix-sync -q

emerge "${OPTIONS[@]}" --jobs=${JOBS:-1} "$@" --complete-graph --deep --newuse --quiet-build --quiet-fail --tree --unordered-display --update --usepkg --with-bdeps=y @world
emerge "${OPTIONS[@]}" --jobs=${JOBS:-1} --depclean
emerge "${OPTIONS[@]}" --jobs=${JOBS:-1} --quiet-build --oneshot @preserved-rebuild

revdep-rebuild
emaint all --fix
emaint logs --clean
eclean-dist --deep --time-limit=1m --quiet
eclean-pkg --deep --time-limit=1m --quiet

prelink -amR
