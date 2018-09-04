#!/bin/bash

# precompile assets on each host to a known volume
# to be run before first deploy and each time the mastodon image changes.
# these volumes must match what the mastodon stack uses.
# Docker should terminate it if it runs for more than six minutes

docker run --rm \
  --env-file mastodon_env.production \
  --stop-timeout 360 \
  -e RAILS_ENV=production \
  -v mastodon_public-assets:/mastodon/public/assets \
  -v mastodon_public-packs:/mastodon/public/packs \
  ${mastodon_image} \
  rails assets:precompile

compile_success=$?
# After it completes, remove the env file unless we're on the first manager node
[ `hostname` != 'manager-01' ] && rm /home/mastodon/mastodon_env.production

exit $compile_success
