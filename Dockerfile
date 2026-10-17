FROM alpine:3.24.2 AS chatbox

# add chatbox user and install packages
# # apk-tools has a bug that breaks on emulated armv7
RUN \
    apk update && \
    apk upgrade --scripts=no apk-tools && \
    apk upgrade && \
    apk --no-cache add dumb-init irssi dropbear tmux && \
\
    addgroup -g 1337 chatbox && \
    adduser -D -h /data -G chatbox -u 1337 chatbox

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
