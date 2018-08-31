For creating a mastodon instance on digital ocean using docker swarm
## Setup

On the machine running terraform

terraform init

brew install jq # or don't use brew, whatevs, just get jq installed

cp secrets.auto.tfvars.example  secrets.auto.tfvars

Fill the missing secrets in your new file.  Keep in mind that these are 'secret' as in they won't be checked into source control, but they may be visible in the terraform state files.

To generate a set of keys for vapid to enable web push run the `generate_vapid_keys.rb` 

Take a moment to review variables.tf and update any that don't fit your needs.  While you're at it, take a look at mastodon_env.prodction.tpl and make sure the mastodon settings are to your taste.

Review backend.tf and update the terraform state.

run terraform init
## Droplet Images
This uses a private image provisioned with the `custom_image/setup.sh` script.  The pre-built `docker-16-04` images from DO were using docker 17 and seemed to have stability issues

## About the result

This is designed to be an easily scalable setup, it is not designed to be a wholly fault tolerant automatic scaling setup.  Postgres, Redis, and Traefik all run a single container on a single labeled instance to avoid having to share data.  If one of those instances goes down you'll still need to restore the data.

Postgres and redis are constrained to run on a single labeled host.  They will create volumes for persistence.  If you want to move those sevices you must move those volumes too.

## Security

This terraform will store sensitive information in the tfstate.  You should not check this into source control.  If you do choose to store it, make sure that it is in a secure location.  If you are storing it in S3 that means the bucket IS NOT PUBLIC, ideally encrypted at rest with access logs.

See https://tosbourn.com/hiding-secrets-terraform/ for more information.

## Administration and Monitoring

Once the terraform has run successfully it will output the first manager node, for example manager-01.nyc1.kcmo.social

Start an SSH tunnel to the node with:

    ssh -N -L 9000:manager-02.nyc1.kcmo.social:9000 -L 8080:manager-02.nyc1.kcmo.social:8080 mastodon@manager-01.nyc1.kcmo.social

Then visit http://localhost:9000/#/home for docker swarm management.  Visit http://localhost:8080 for external HTTP traffic monitoring

To run rake commands ssh to manager-02 and invoke the command with:

    docker run --rm \
    --net mastodon_internal-net \
    --env-file mastodon_env.production \
    -e RAILS_ENV=production \
    tootsuite/mastodon:v2.4.4 \
    COMMAND_TO_RUN_HERE
    
    
For example, to make alice an admin ( See https://github.com/tootsuite/documentation/blob/master/Running-Mastodon/Administration-guide.md for more info)

    docker run --rm \
    --net mastodon_internal-net \
    --env-file mastodon_env.production \
    -e RAILS_ENV=production \
    -e USERNAME=alice \
    tootsuite/mastodon:v2.4.4 \
    rails mastodon:make_admin


# First time startup

When starting up a cluster for the first time the scripts should install some helpful software for monitoring and security and then try to join the swarm.  If a step fails, it is safe to re-run `terraform apply` until it completes.

If you did receive any errors, once it is complete you should ssh to a manager node and check to see that the swarm is listing the expected number of active serviers.  Run `docker node ls` to see what is in the cluster and `docker node rm NODE_ID` to remove any managers listed as down.  You may also need to re-apply the labels from the `deploy_stack` provisioner in main.tf

The first time you start a swarm (or update the image) it will compile the assets into a volume on each host.  This process takes a while and the mastodon web apps must be restarted when it is complete. When it's done you need to restart the web services.

How do you know it is complete?  Well, you can just wait ten minutes and it should be pretty safe.  Or ssh to a server and run `docker service ls` and look for `mastodon_web_assets` to say 0/0 replicas.  Or use the portainer interface to see when they've completed.

While you wait for the assets to compile you can setup the database too.  SSH to a manager and run:

    docker run --rm \
    --net mastodon_internal-net \
    --env-file mastodon_env.production \
    -e RAILS_ENV=production \
    -e SAFETY_ASSURED=1 \
    tootsuite/mastodon:v2.4.4 \
    rails db:setup

Once asset compliation has completed restart the web service AND the sidekiq service.  You can use portainer or run

    docker service scale mastodon_web=0
    docker service scale mastodon_sidekiq=0
    docker service scale mastodon_web=2
    docker service scale mastodon_sidekiq=1
    
to force a restart.  You can also use the portainer interface if you have an ssh tunnel up by visiting http://localhost:9000/#/services, checking off the two services, and restarting them.
    

# Troubleshotting

Someimes docker fails to start containers.  Try `sudo service docker restart` on the machine with the issues