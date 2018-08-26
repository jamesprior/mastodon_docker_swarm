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