#!/bin/sh

########################################################################
# Mastodon user account and setup
########################################################################
adduser --disabled-password --gecos "" mastodon
usermod -aG sudo mastodon
usermod -a -G docker mastodon
echo 'mastodon ALL=(ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo

mkdir -p /home/mastodon/.ssh
chown mastodon:mastodon /home/mastodon/.ssh
cp /root/.ssh/authorized_keys /home/mastodon/.ssh/authorized_keys
chown mastodon:mastodon /home/mastodon/.ssh/authorized_keys

########################################################################
# Digital ocean specific setup - monitoring and droplan
########################################################################
curl -sSL https://agent.digitalocean.com/install.sh | sh
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

########################################################################
# Redis setup
########################################################################
echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
sysctl vm.overcommit_memory=1

echo never > /sys/kernel/mm/transparent_hugepage/enabled
cat <<EOF > /etc/rc.local
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.

echo never > /sys/kernel/mm/transparent_hugepage/enabled
exit 0
EOF
