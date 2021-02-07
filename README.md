# About

A set of terraform scripts and shell scripts used by kcmo.social to create a docker swarm running mastodon.
It supports one production environment and one staging environment as a subdomain.

Currently it is fixed on three manager nodes and requires setting up a custom image in digital ocean.
If you're thinking of using this to start your own instance you should have some basic familiarity with
or desire to learn:

* Digital ocean
* Terraform
* Docker
* Linux

This is designed to be an easily scalable setup, it is not designed to be a wholly fault tolerant
automatic scaling setup.  Postgres, Redis, and [Traefik](https://traefik.io/) all run single instances
on a labeled node to avoid having to share data between nodes.  If one of those
droplets goes down you'll still need to restore the data (but there are backups!).  If you want to
move those sevices you must move those volumes too.

Droplent creation and swarm management is done with the terraform module from
https://github.com/thojkooi/terraform-digitalocean-docker-swarm-mode


# Setup the prerequisites

Fork this repo so you can make changes for your environment.

The host computer will need a copy of `terraform` and `jq` installed.  On OS X `jq` can be installed via Homebrew.

Update `staging/backend.tf` and `production/backend.tf`.  They are currently configured to use
AWS's S3 and DynamoDB for remote state storage, but you could change this to use local storage if you'd like.
Just be sure not to check the statefile into a public repository because it will contain sensitive information.

You should now be able to run `terraform init` in `production` and in `staging`.

Copy the sample secrets file into each staging and production environment.

    cp secrets.auto.tfvars.example  production/secrets.auto.tfvars
    cp secrets.auto.tfvars.example  staging/secrets.auto.tfvars

Keep in mind that these are 'secret' as in they won't be checked into source control, but they may be
visible in the terraform state files.  `do_token` and `aws_profile` are used by the default backend but
look in `mastodon_swarm/variables.tf` for a description of the others.

Edit `staging/main.tf` and `production/main.tf` becuse it's littered with environment specific information.
Fill in what you can fix offhand and be prepared to return as you populate the images, keys, and buckets in
Digital Ocean.

Here's a list of things you'll need to create once or configure outside of terraform before setting in
a `secrets.auto.tfvars` or a `main.tf` file for an environment:

- [ ] Digital ocean API token with write access
- [ ] Digital ocean API token with read access for droplan
- [ ] An AWS profile for the terraform backend
- [ ] A public and private key for vapid to enable web push. (See the `generate_vapid_keys.rb` script)
- [ ] An SMTP username, password, port, and hostname
- [ ] A set of credentials, bucket and enpoint in an AWS S3 workalike for user assets
- [ ] A set of credentials, bucket and enpoint in an AWS S3 workalike for backups
- [ ] An SSH key in Digital Ocean
- [ ] A domain name registered and added as a domain to Digital Ocean
- [ ] A droplet image (see next section)


# Droplet Images
This uses a private image provisioned with the `custom_image/setup.sh` script.  The pre-built `docker-16-04`
images from DO were using docker 17 and seemed to have stability issues.

To build your own, start up the smallest droplet available and run the setup script on the server.
After everything has installed power down the server with `shutdown -h now` and use the digital ocean
console to take a snapshot of the droplet.  When it's complete get a list of your custom images from the
Digital Ocean API with something like:

    curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer SOME_TOKEN_HERE" "https://api.digitalocean.com/v2/images?page=1&private=true"

Find the image ID corresponding to your new image and set it in the `swarm_image` variable in each environment.


# Administration and Monitoring

Once the terraform has run successfully it will output the first manager node, for example
manager-01.nyc1.kcmo.social.  It will leave a few files in the mastodon user's home account
for administering the mastodon stack.

It also runs Portainer for container monitoring and management and Traefik for SSL termination
directing traffic to services in the cluster.  They both have management interfaces available
via SSH tunnels.

Start an SSH tunnel to a node with:

    ssh -N -L 9000:manager-02.nyc1.kcmo.social:9000 -L 8080:manager-02.nyc1.kcmo.social:8080 mastodon@manager-01.nyc1.kcmo.social

Then visit http://localhost:9000/#/home for docker swarm management with [Portainer](https://portainer.io).
Visit http://localhost:8080 for external HTTP traffic monitoring with [Traefik](https://traefik.io/).

To run rake commands ssh to manager-01 and invoke the command with:

    docker run --rm \
    --net mastodon_internal-net \
    --env-file mastodon.env \
    -e RAILS_ENV=production \
    tootsuite/mastodon:v3.3.0 \
    COMMAND_TO_RUN_HERE

For example, to make alice an admin ( See https://github.com/tootsuite/documentation/blob/master/Running-Mastodon/Administration-guide.md for more info)

    docker run --rm \
    --net mastodon_internal-net \
    --env-file mastodon.env \
    -e RAILS_ENV=production \
    -e USERNAME=alice \
    tootsuite/mastodon:v3.3.0 \
    rails mastodon:make_admin

You can also use the portainer interface to open a console on one of the containers running
mastodon image and run the same rails commands.

# Service placement

Postgres, Redis, and Traefik depend on state stored in docker volumes which are unique per-node, which means
that they should always be started on the same nodes.  If they need to be moved, it requires admin intervention
to move the docker volume to a new host, or to restore from a backup.  The web, streaming, and sidekiq services
are more portable and can run on any node.

Because of that, Postgres, Redis, and Traefik will only run on nodes with labels matching the service name set
to true, eg postgres will only run on a node with `postgres=true`.

The more portable workers will run on any available node.  If you want to prevent them from running on a node
you must add a label to the node with the service name set to false.  For example,
`docker node update --label-add streaming=false manager-01` will prevent docker swarm from placing
a streaming container on the `manager-01` node.

# Security

This terraform will store sensitive information in the tfstate.  You should not check this into source control.
If you do choose to store it, make sure that it is in a secure location.  If you are storing it in S3 that
means the bucket IS NOT PUBLIC, ideally encrypted at rest with access logs.  See https://tosbourn.com/hiding-secrets-terraform/
for more information.

Access to the droplets is controlled by SSH keys and inbound SSH IP address filters.  Only the mastodon web
services are exposed externally.  Portainer is a powerful container management interface and it is not
pre-configured with a password, but it is only available via ssh tunneling.

# First time startup

When starting up a cluster for the first time the scripts have a lot to do.  If a step fails, it is
safe to re-run `terraform apply` until it completes.

When the terraform apply is complete you will need to set up the database.  SSH to a manager and run:

    docker run --rm \
    --net mastodon_internal-net \
    --env-file mastodon.env \
    -e RAILS_ENV=production \
    -e SAFETY_ASSURED=1 \
    tootsuite/mastodon:v3.3.0 \
    rails db:setup


# Making changes

If you change the mastodon environment, variables used in the environment, or the mastodon stack just re-run
`terraform apply`.

You can also ssh to a server and do it manually, use portainer, or force a redeploy by tainting the
terraform resource with `terraform taint -module=mastodon_swarm null_resource.deploy_mastodon` and
running `terraform apply`.

If you just want to start over with all new machines you can remove them with `terraform destroy -target=module.mastodon_swarm.module.swarm-cluster`

# Backups

Backups of named docker volumes are scheduled to occur nightly.  This includes postgres, redis, traefik,
and any user data that was uploaded locally insted of to remote object storage (like Digital Ocean Spaces).
Backups are kept for 21 days, full backups every 7 days.  Postgres is backed up as a full sql dump.  The
backup engine is Duplicity, and while it is possible to restore manually it's recommended to use the duplicity
tool for restores.


# Upgrading

Change the `mastodon_image` variable in `main.tf` to use the new docker image.  In the example below we'll be upgrading to 3.3.0.

SSH to the machine running the docker container (manager-01), then find the postgres container id with `docker ps`

Then take a backup, eg: `docker exec 1613703aa9bf pg_dump -Fc -U postgres mastodon_production > mastodon_production.dump`

If the upgrade notes require it run the DB migrations with:

    docker run --rm \
    --net mastodon_internal-net \
    --env-file mastodon.env \
    -e RAILS_ENV=production \
    -e SKIP_POST_DEPLOYMENT_MIGRATIONS=true \
    tootsuite/mastodon:v3.3.0 \
    rails db:migrate

Once the migration is complete you can use terraform to deploy the changes, eg `terraform apply`.  After it's been applied run the post deployment migrations with

    docker run --rm \
    --net mastodon_internal-net \
    --env-file mastodon.env \
    -e RAILS_ENV=production \
    tootsuite/mastodon:v3.3.0 \
    rails db:migrate

You can run tootctl cache clear with:

    docker run --rm \
    --net mastodon_internal-net \
    --env-file mastodon.env \
    -e RAILS_ENV=production \
    tootsuite/mastodon:v3.3.0 \
    bin/tootctl cache clear