# These should be set in secrets.auto.tfvars
variable "do_token" {}
variable "do_droplan_token" {}
variable "aws_access_key" { default = "" }
variable "aws_secret_key" { default = "" }
variable "aws_region" {
  default = "us-east-2"
}
variable "aws_profile" { }

# The name of the mastodon project, this will be used for tagging resources and in
# droplet names
variable "project_name" { default = "kcmo-social-mastodon"}

# The site domain
variable "domain_name" { default = "kcmo.social"}

# The region to deploy in
variable "digitalocean_region" { default = "nyc1" }

# an array with ssh key IDs, these will be unique to your account.  You should set them
# in secrets.auto.tfvars
# See https://developers.digitalocean.com/documentation/v2/#list-all-keys
variable "ssh_key_ids" { default = [ "23516" ] }
variable "provision_ssh_key" {
  default     = "~/.ssh/id_rsa"
  description = "File path to SSH private key used to access the provisioned nodes. Ensure this key is listed in the manager and work ssh keys list"
}

# The number of manager nodes to create in the docker swarm, manager
# nodes will be assigned work
variable "swarm_manager_count" { 
  default = 3 # so we can tolerate the failure of any one node and still do work
} 
# The size of the manager node, to fetch a list see
# https://developers.digitalocean.com/documentation/v2/#list-all-sizes
# specify the size by using the id or the slug
variable "swarm_manager_size" { default = "s-1vcpu-1gb" }

# The number of worker nodes to create in the docker swarm
variable "swarm_worker_count" { default = 0 }
# The size of the worker nodes, see above for how to fetch a list
variable "swarm_worker_size" { default = "s-1vcpu-1gb" }