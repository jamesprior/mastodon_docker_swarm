For creating a mastodon instance on digital ocean using docker swarm

Setup:

On the machine running terraform

terraform init

brew install jq # or don't use brew, whatevs, just get jq installed

cp secrets.auto.tfvars.example  secrets.auto.tfvars

Fill in your digital ocean token and an aws profile or key and secret.  Keep in mind that these are 'secret' as in they won't be checked into source control, but they may be visible in the terraform state files.

Take a moment to review variables.tf and update any that don't fit your needs

Review backend.tf and update the terraform state.

run terraform init

## About this setup

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

Once asset compliation has completed restart the web services.  You can use portainer or run

    docker service scale mastodon_web=0
    docker service scale mastodon_web=2
    
to force a restart
    

