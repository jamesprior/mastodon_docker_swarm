For creating a mastodon instance on digital ocean using docker swarm

Setup:

cp secrets.auto.tfvars.example  secrets.auto.tfvars

Fill in your digital ocean token and an aws profile or key and secret

Take a moment to review variables.tf and update any that don't fit your needs

Review backend.tf and update the terraform state.

run terraform init

