#!/bin/sh

# WARNING changing this file will make terraform try to destroy and re-create your assets.

# Docker swarm networking
ufw allow 2377
ufw allow 7946
ufw allow 7946/udp
ufw allow 4789/udp

# Mastodon user account and setup
adduser --disabled-password --gecos "" mastodon
usermod -aG sudo mastodon
usermod -a -G docker mastodon
echo 'mastodon ALL=(ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo

mkdir -p /home/mastodon/.ssh
chown mastodon:mastodon /home/mastodon/.ssh
cp /root/.ssh/authorized_keys /home/mastodon/.ssh/authorized_keys
chown mastodon:mastodon /home/mastodon/.ssh/authorized_keys

# Droplan setup for more private private networking
apt-get install -yy netfilter-persistent
mkdir -p /opt/droplan
curl -O -L https://github.com/tam7t/droplan/releases/download/v1.3.1/droplan_1.3.1_linux_amd64.tar.gz
tar -zxf droplan_1.3.1_linux_amd64.tar.gz -C /opt/droplan/
rm droplan_1.3.1_linux_amd64.tar.gz

cat <<EOF > /opt/droplan/refresh.sh
#!/usr/bin/env bash

/opt/droplan/droplan
netfilter-persistent save
EOF

chmod +x /opt/droplan/refresh.sh
echo '*/5 * * * * root PATH=/sbin:/usr/bin:/bin DO_KEY=${do_droplan_token} DO_TAG=${do_tag} /opt/droplan/refresh.sh > /var/log/droplan.log 2>&1' > /etc/cron.d/droplan

