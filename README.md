# docker-spotify-vnc

Run spotify inside a docker container, with VNC, for use with snapcast.

# Why?

Projects like `librespot` are wonderful, but they are playing a constant game of
cat and mouse as spotify does not officially support 3rd party libraries.
Spotify continues to change their API, and 3rd party projects must reverse
engineer

This project allows you to run an official spotify client inside a docker container,
and use VNC to configure it.  This allows you to use the client as a "spotify connect"
player, similar to what `librespot` provides. The audio is piped to a FIFO which you can then
consume with snapcast.

# How?

Build the container:
```shell
$ docker build -t docker-spotify-vnc .
```

Create a volume for spotify config:
```shell
$ docker volume create spotify-config
```

Run the container!
```shell
$ docker run -it --rm \
    -p <VNC_PORT>:5900 \
    -h <HOST_NAME> \
    -u $(id -u):$(id -g) \
    -v spotify-config:/home/docker/.config/spotify \
    -v <SNAPCAST_FIFO>:/tmp/snapfifo \
    docker-spotify-vnc
```

You can change the following options:
 - `<VNC_PORT>` is the VNC port to connect to (`5900` works fine)
 - `<HOST_NAME>` can be whatever you want, it's the name you'll see in spotify connect.
 - `<SNAPCAST_FIFO>` should point to your snapcast pipe, such as `/tmp/snapfifo`.

If successful, you should see something like:
```
$ docker run -it --rm \
    -p 5900:5900 \
    -h snapcast \
    -u $(id -u):$(id -g) \
    -v spotify-config:/home/docker/.config/spotify \
    -v /tmp/snapfifo:/tmp/snapfifo \
    docker-spotify-vnc

+ fixuid
fixuid: fixuid should only ever be used on development systems. DO NOT USE IN PRODUCTION
fixuid: runtime UID '1000' already matches container user 'docker' UID
fixuid: runtime GID '1000' already matches container group 'docker' GID
+ eval
+ sudo chown -R docker:docker /home/docker/.config/spotify
+ sudo mkdir -p /var/run/dbus
+ sleep 1
+ sudo dbus-daemon --system --fork
+ export DISPLAY=:99
+ Xvfb :99 -screen 0 1024x768x16
+ [ -e /tmp/snapfifo_pa ]
+ + echo waiting
x11vncwaiting
 -display+  :99sleep -nopw 1 -forever
 -quiet
+ pulseaudio
_XSERVTransmkdir: ERROR: euid != 0,directory /tmp/.X11-unix will not be created.
W: [pulseaudio] authkey.c: Failed to open cookie file '/home/docker/.config/pulse/cookie': No such file or directory
W: [pulseaudio] authkey.c: Failed to load authentication key '/home/docker/.config/pulse/cookie': No such file or directory
W: [pulseaudio] authkey.c: Failed to open cookie file '/home/docker/.pulse-cookie': No such file or directory
W: [pulseaudio] authkey.c: Failed to load authentication key '/home/docker/.pulse-cookie': No such file or directory
W: [pulseaudio] sink.c: Default and alternate sample rates are the same.
W: [pulseaudio] server-lookup.c: Unable to contact D-Bus: org.freedesktop.DBus.Error.Spawn.ExecFailed: /usr/bin/dbus-launch terminated abnormally without any error message
W: [pulseaudio] main.c: Unable to contact D-Bus: org.freedesktop.DBus.Error.Spawn.ExecFailed: /usr/bin/dbus-launch terminated abnormally without any error message

The VNC desktop is:      snapcast:0
PORT=5900
+ [ -e /tmp/snapfifo_pa ]
+ spotify
+ cat /tmp/snapfifo_pa
```

You may now connect via VNC to port 5900 and log-in to spotify.
I recommend you set a high bit rate and other audio preferences you may have.

Spotify settings will persist inside the `spotify-config` docker volume.
