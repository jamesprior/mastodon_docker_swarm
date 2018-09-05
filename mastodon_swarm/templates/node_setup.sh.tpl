#!/bin/sh

# node_setup.sh should be run as the root user

cd /root
cat <<EOF > /root/bivac_backup.sh
#!/bin/bash

/usr/local/bin/bivac \\
  -u s3://${s3_hostname}/${s3_backup_bucket} \\
  --engine=duplicity \\
  --remove-older-than=21D \\
  --full-if-older-than=7D \\
  --blacklist=mastodon_public-assets \\
  --blacklist=mastodon_public-packs \\
  --aws-access-key-id=${backup_aws_access_key_id} \\
  --aws-secret-key-id=${backup_aws_secret_access_key}
EOF
chmod 755 /root/bivac_backup.sh


# Run droplan every five minutes
echo '*/5 * * * * root PATH=/sbin:/usr/bin:/bin DO_KEY=${do_droplan_token} DO_TAG=${do_tag} /opt/droplan/refresh.sh > /var/log/droplan.log 2>&1' > /etc/cron.d/droplan

# Backup docker volumes every day at 3am
echo '0 3 * * * root PATH=/sbin:/usr/bin:/bin:/usr/local/bin /root/bivac_backup.sh' > /etc/cron.d/bivac_backup

