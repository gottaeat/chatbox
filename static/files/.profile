#!/bin/sh
HOME="/data"
LANG="en_US.UTF-8"
LC_ALL="en_US.UTF-8"

export HOME LANG LC_ALL

if [ -n "${PS1}" ] && [ -n "${SSH_CONNECTION}" ] && [ -z "${TMUX}" ]; then
    tmux attach
fi
