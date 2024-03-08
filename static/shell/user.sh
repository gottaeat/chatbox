#!/bin/sh
. /static/shell/common

pinfo "setting up the tmux session"
tmux \
    new-session -d -t "irssi-docker" \; \
    send-keys 'irssi' C-m \; \
    split-window -v \; \
    send-keys 'irssi' C-m \;
evalret

pinfo "starting sshd on local port 3132"
/usr/sbin/sshd -f sshd/sshd_config -D
