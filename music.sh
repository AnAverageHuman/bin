#!/usr/bin/env bash
set -euo pipefail

TMUX_SESSION=music

read -rd '' process << 'EOF' || true
cleanup() {
    killall ncmpcpp
    killall mopidy
    sleep 2
    tmux kill-session -t "${TMUX_SESSION}"
}
trap cleanup TERM
trap '' INT

clear
mpc random on
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
        "")
            # noop
            printf '\n'
            ;;
        *)
            mpc $cmd
            ;;
    esac
done
EOF


tmux new-session -d -t "${TMUX_SESSION}"
tmux send-keys "mopidy" C-m
sleep 10
tmux split-window -v -p 75 "ncmpcpp"
tmux select-pane -t 1
tmux split-window -h -p 60 "$process"
tmux select-pane -t 2
tmux attach-session -t "${TMUX_SESSION}"

