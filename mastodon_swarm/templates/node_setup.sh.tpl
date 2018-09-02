#!/bin/sh

# Run droplan every five minutes
echo '*/5 * * * * root PATH=/sbin:/usr/bin:/bin DO_KEY=${do_droplan_token} DO_TAG=${do_tag} /opt/droplan/refresh.sh > /var/log/droplan.log 2>&1' > /etc/cron.d/droplan

