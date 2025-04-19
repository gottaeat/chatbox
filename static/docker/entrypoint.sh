#!/bin/sh
. /docker/common

set -e
# - - graceful shutdown - - #
stop() {
    pinfo "stopping irc-docker"

    pinfo "stopping irssi"
    pkill -15 irssi

    while pidof irssi >/dev/null 2>&1; do
        sleep 1
    done

    pinfo "stopping dropbear"
    pkill -15 dropbear

    while pidof dropbear >/dev/null 2>&1; do
        sleep 1
    done

    pinfo "going down"
    exit 0
}

trap stop SIGTERM SIGINT

# - - sanity checks -- #
if [ -z "${PUBKEY}" ]; then
    perr "PUBKEY env var was not defined, exiting."
fi

if ! mountpoint /data >/dev/null 2>&1; then
    perr "/data is not bind mounted, exiting."
fi

# dropbear
mkdir -p /data/sshd >/dev/null 2>&1

if [ ! -f "/data/sshd/dropbear_ecdsa_host_key" ]; then
    pinfo "generating dropbear host key"
    dropbearkey -t ed25519 -f /data/sshd/dropbear_ecdsa_host_key >/dev/null 2>&1
fi

if [ ! -f "/data/sshd/banner" ]; then
    pinfo "using default banner"
    cp /static/banner /data/sshd/banner
fi

pinfo "setting authorized_keys"
mkdir -p /data/.ssh/ >/dev/null 2>&1
echo "${PUBKEY}" > /data/.ssh/authorized_keys

# shell
if [ ! -f "/data/.profile" ]; then
    pinfo "using default shell profile"
    cp /static/.profile /data/.profile
fi

# perms
pinfo "setting permissions"
chown -Rh irc:irc /data
find /data/sshd /data/.ssh -type d -exec chmod 0700 {} ';'
find /data/sshd /data/.ssh -type f -exec chmod 0600 {} ';'

# - - action - - #
pinfo "starting syslogd"
syslogd -O - -n &

pinfo "starting tmux session"
su irc -c 'tmux new-session -d -t "irssi-docker" \; send-keys "irssi" C-m'

pinfo "starting dropbear"
su irc -c 'dropbear -p2222 -m -w -s -g -G irc -T 5 -j -k -K 120 \
    -b /data/sshd/banner \
    -r /data/sshd/dropbear_ecdsa_host_key'

pinfo "entered final wait"
wait
