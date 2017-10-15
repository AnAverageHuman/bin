#!/usr/bin/env bash
set -euo pipefail

TMUX_SESSION=music

if tmux has-session -t music; then
    tmux attach-session -t music
    exit
fi

read -rd '' process << 'EOF' || true
cleanup() {
    killall ncmpcpp
    killall mopidy
    sleep 2
    tmux kill-session -t "${TMUX_SESSION}"
}
trap cleanup TERM
trap '' INT

until mpc random on > /dev/null 2>&1; do
    sleep 1
done

clear
mpc consume on
while true; do
    read -rp 'mpc> ' cmd
    case "$cmd" in
        exit)
            cleanup
            ;;
        pauseafter)
            sleep "$(mpc | awk -F"[ /:]" '/playing/ {print 60*($8-$6)+$9-$7}')"
            mpc pause
            ;;
        *)
            mpc $cmd
            ;;
    esac
done
EOF


tmux new-session -d -s "${TMUX_SESSION}" 'mopidy'
tmux split-window -t "${TMUX_SESSION}:1.1" -v -p 75 "while true; do ncmpcpp; done"
tmux split-window -t "${TMUX_SESSION}:1.1" -h -p 60 "$process"
tmux attach-session -t "${TMUX_SESSION}:1.2"

