#!/bin/sh

# TODO anything here should get moved to the image when it is next created

# TF was getting rate limited, so use this until I can build a new image
ufw allow 22/tcp 
ufw reload

# Mastodon user has some perms and secrets, so dont leave things readable.
sudo chfn -o umask=0027 mastodon
chmod  750 /home/mastodon
