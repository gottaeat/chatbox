FROM alpine:3.21.3 AS irc

# add irc user and install packages
RUN \
    addgroup -g 1337 irc && \
    adduser -D -h /data -G irc -u 1337 irc && \
    apk update && apk upgrade --no-cache && apk add --no-cache \
        dumb-init irssi dropbear tmux

# copy over conf
COPY ./static/files/.profile /static/.profile
COPY ./static/files/banner   /static/banner

# entrypoint
COPY ./static/docker /docker
RUN chmod +x /docker/entrypoint.sh

# sshd
EXPOSE 2222

WORKDIR /data
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/docker/entrypoint.sh"]
