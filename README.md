For creating a mastodon instance on digital ocean using docker swarm

Setup:

On the machine running terraform

terraform init

brew install jq # or don't use brew, whatevs, just get jq installed

cp secrets.auto.tfvars.example  secrets.auto.tfvars

Fill in your digital ocean token and an aws profile or key and secret

Take a moment to review variables.tf and update any that don't fit your needs

Review backend.tf and update the terraform state.

run terraform init

