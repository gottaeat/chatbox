# chatbox
chatbox sets up an alpine-based docker container that starts irssi in a tmux
session and exposes it rootlessly via dropbear.

## installation
### 1. clone the repo
```sh
git clone --depth=1 https://github.com/gottaeat/chatbox
cd chatbox/
```

### 2. configure
edit the `docker-compose.yml` to add your private key.

### 3. bring it up
```sh
docker compose up -d
```

## customization
users can supply their own files for software running inside the container in
the following paths. if none supplied, the defaults provided by alpine will be
used. do note that the entrypoint will `chown` and `chmod` them automatically.

| configuration | path                    |
|---------------|-------------------------|
| SSH banner    | `$DATA_DIR/sshd/banner` |
| tmux          | `$DATA_DIR/.tmux.conf`  |
| irssi         | `$DATA_DIR/.irssi/`     |
| busybox ash   | `$DATA_DIR/.profile/`   |

**warning**: make sure to define at least `LANG` and `LC_ALL` as `en_US.UTF-8`
if using a custom `.profile`.
