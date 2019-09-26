#!/bin/sh -x

eval $(fixuid)

sudo chown -R docker:docker /home/docker/.config/spotify

sudo mkdir -p /var/run/dbus
sudo dbus-daemon --system --fork &
sleep 1

Xvfb :99 -screen 0 1024x768x16 &
export DISPLAY=:99
x11vnc -display $DISPLAY -nopw -forever -quiet &

pulseaudio &
while ! [ -e /tmp/snapfifo_pa ]; do sleep 1; done
cat /tmp/snapfifo_pa >> /tmp/snapfifo &
spotify
