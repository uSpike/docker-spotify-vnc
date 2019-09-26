FROM ubuntu:18.04

RUN export DEBIAN_FRONTEND=noninteractive TZ=America/Chicago \
 && sed 's;http://archive.;http://us.archive.;g' -i /etc/apt/sources.list \
 && apt-get update && apt-get install -y --no-install-recommends \
    add-apt-key ca-certificates curl pulseaudio pulseaudio-utils xvfb x11vnc dbus sudo \
 && rm -rf /var/lib/apt/lists/*

RUN curl -sS https://download.spotify.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb http://repository.spotify.com stable non-free" | tee /etc/apt/sources.list.d/spotify.list \
 && apt-get update && apt-get install -y spotify-client

RUN USER=docker GROUP=docker HOME=/home/$USER \
 && useradd -u 1000 -m -d $HOME -s /bin/bash $USER \
 && usermod -aG audio $USER \
 && echo "$USER ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USER && chmod 0440 /etc/sudoers.d/$USER \
 && mkdir -p $HOME/.config/pulse && chown -R $USER:$GROUP $HOME \
 && curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.4/fixuid-0.4-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - \
 && chown root:root /usr/local/bin/fixuid \
 && chmod 4755 /usr/local/bin/fixuid \
 && mkdir -p /etc/fixuid \
 && printf "user: $USER\ngroup: $GROUP\n" > /etc/fixuid/config.yml

ADD entrypoint.sh /entrypoint.sh
COPY ["default.pa", "/etc/pulse/"]

USER docker:docker

ENTRYPOINT ["/entrypoint.sh"]
