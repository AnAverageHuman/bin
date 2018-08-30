#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n' tex=( $(find . -iname "*.tex" 2> /dev/null -exec dirname {} \; || true) )
readarray -t unique < <(printf '%s\n' "${tex[@]}" | sort -u)

function clean {
    printf "%s\n" "$i"
    pushd "$i" > /dev/null
    latexmk -C -silent
    popd > /dev/null
}

for i in "${unique[@]}"; do
    clean "$i" &
done

wait
