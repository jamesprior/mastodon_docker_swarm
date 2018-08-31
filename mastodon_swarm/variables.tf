# These should be passed in
variable "do_token" {}
variable "do_droplan_token" {}
variable "vapid_public_key" { }
variable "vapid_private_key" { }
variable "smtp_login" { }
variable "smtp_password" { }
variable "s3_access_key_id" { }
variable "s3_secret_access_key" { }

# The name of the mastodon project, this will be used for tagging resources and in
# droplet names
variable "project_name" { }


# These are defaults that apply to staging and production:

#
# digital ocean configs
#
# This should be your current IP address, used to lock down SSH access
variable "allowed_ssh_ips" { default = ["136.33.32.150"] }


# The site domain
variable "domain_name" { default = "kcmo.social"}
# Optionally include all resources in a subdomain, eg staging
variable "subdomain" { default = "" }

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

#
# Mastodon configs
#
# Your email address used for Lets Encrypt
variable "acme_email" { default = "acme@kcmo.social" }
# Set this to "true" to use the staging ca server and turn on debugging in traefic
variable "traefik_debug" { default = "true" }

variable "smtp_server" { default = "email-smtp.us-east-1.amazonaws.com" }
variable "smtp_port" { default="587" }
variable "smtp_from_address" { default = "notifications@kcmo.social" }


variable "s3_bucket" { default = "kcmo-social" }
variable "s3_region" { default = "nyc3" }
variable "s3_protocol" { default = "https" }
variable "s3_hostname" { default = "nyc3.digitaloceanspaces.com" }


#
# Swarm machine configs
#
# The image below was set up using custom_image/setup.sh and found from the list with
# curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer SOME_TOKEN_HERE" "https://api.digitalocean.com/v2/images?page=1&per_page=1&private=true"
# It's known in my account as ubuntu-18.04.1-docker-18.06.1ce
variable "swarm_image" { default = "37743425" }

# The number of manager nodes to create in the docker swarm, manager
# nodes will be assigned work
variable "swarm_manager_count" { 
  default = 3 # so we can tolerate the failure of any one node and still do work
  # don't decrease this.  If you want to add capacity add workers.  Beware that
  # postgresql is assigned to manager-01 and redis is assigned to manager-02
} 
# The size of the manager node, to fetch a list see
# https://developers.digitalocean.com/documentation/v2/#list-all-sizes
# specify the size by using the id or the slug
variable "swarm_manager_size" { default = "s-1vcpu-2gb" }

# The number of worker nodes to create in the docker swarm
variable "swarm_worker_count" { default = 0 }
# The size of the worker nodes, see above for how to fetch a list
variable "swarm_worker_size" { default = "s-1vcpu-1gb" }
