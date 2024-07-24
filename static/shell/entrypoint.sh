#!/bin/sh
. /static/shell/common

trap shutdown SIGTERM SIGINT

# -- sanity checks -- #
if [ -z "${PUBKEY}" ]; then
    perr "PUBKEY envvar was not defined, exiting."
fi

if ! mountpoint /data >/dev/null 2>&1; then
    perr "/data is not bind mounted, exiting."
fi

# -- /data/sshd -- #
if [ ! -d "/data/sshd" ]; then
    pinfo "creating /data/sshd"
    mkdir /data/sshd >/dev/null 2>&1
    evalret

fi

if [ ! -f "/data/sshd/ssh_host_ecdsa_key" ]; then
    pinfo "generating sshd host keys for user \"irc\""
    ssh-keygen -f /data/sshd/ssh_host_ecdsa_key -N '' -t ed25519 >/dev/null 2>&1 
    evalret
fi

if [ ! -d "/data/sshd/banner" ]; then
    pwarn "no sshd banner was provided in the /data bind mount!"

    if [ -f "/static/files/sshd/banner" ]; then
        pinfo "static files sshd will be used"
        cp /static/files/sshd/banner /data/sshd/banner
        evalret
    fi
fi

if [ ! -d "/data/sshd/sshd_config" ]; then
    pwarn "no sshd_config was provided in the /data bind mount!"

    if [ -f "/static/files/sshd/sshd_config" ]
        then
            pinfo "static files sshd_config will be used"
            cp /static/files/sshd/sshd_config /data/sshd/sshd_config
            evalret
        else
            perr "no sshd_config in static files, user didn't provide any either"
    fi
fi

# -- /data/.ssh -- #
if [ ! -d "/data/.ssh" ]; then
    pinfo "/data/.ssh does not exist, creating"
    mkdir /data/.ssh/
    evalret
fi

if [ ! -f "/data/.ssh/authorized_keys" ]; then
    pinfo "setting authorized_keys"
    echo "${PUBKEY}" > /data/.ssh/authorized_keys
    evalret
fi

# -- /data/profile -- #
if [ ! -f "/data/.profile" ]; then
    pwarn "no .profile was provided in the /data bind mount!"

    if [ -f "/static/files/.profile" ]; then
        pinfo "static files .profile will be used"
        cp /static/files/.profile /data/.profile
    fi
fi

# -- .tmux -- #
if [ ! -f "/data/.tmux.conf" ];
    then
        pwarn ".tmux.conf was not provided in the /data bind mount!"
    else
        pinfo "setting the permissions on user provided .tmux.conf"
        chown -Rh irc:irc /data/.tmux.conf && \
        evalret
fi

# -- .irssi -- #
if [ ! -d "/data/.irssi" ];
    then
        pwarn ".irssi was not provided in the /data bind mount!"
    else
        pinfo "setting the permissions on user provided .irssi/"
        chown -Rh irc:irc /data/.irssi/ && \
        evalret
fi

# -- hand over -- #
pinfo "setting permissions"
chown -Rh irc:irc /data && \
chmod 0700 /data/sshd/ /data/.ssh/ && \
chmod 0600 /data/sshd/* /data/.ssh/*
evalret

pinfo "handing over to user \"irc\""
su irc -c '/static/shell/user.sh' &

wait $!
