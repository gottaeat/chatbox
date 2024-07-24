FROM alpine:latest AS irc

COPY ./static /static

RUN \
    apk update && apk upgrade && \
    apk --no-cache add openssh tmux irssi && \
    addgroup -g 1337 irc && \
    adduser -D -h /data -G irc -u 1337 irc

WORKDIR /data

ENV HOME="/data"
ENV LANG="en_US.UTF-8"
ENV LC_ALL="en_US.UTF-8"

EXPOSE 3132
CMD /static/shell/entrypoint.sh
