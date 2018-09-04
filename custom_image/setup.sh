#!/bin/sh

# Below is what created the current image.  Before creating a new image
# port anything in user_data.sh into here

########################################################################
# Docker setup
########################################################################
sudo apt update
sudo apt install -yy apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
sudo apt install -yy docker-ce


########################################################################
# UFW setup
########################################################################
ufw allow 22/tcp 
ufw allow 2376/tcp
ufw allow 2377/tcp
ufw allow 7946/tcp
ufw allow 7946/udp
ufw allow 4789/udp
ufw reload
ufw enable

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

sudo chfn -o umask=0027 mastodon
chmod  750 /home/mastodon


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

########################################################################
# Install bivac for backups
# See https://github.com/camptocamp/bivac
########################################################################
sudo apt install -yy golang-go
go get github.com/camptocamp/bivac # installs to /home/mastodon/go/bin
cp go/bin/bivac /usr/local/bin/
chmod 755 /usr/local/bin/bivac
rm -rf /root/go