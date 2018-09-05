# These should be set in secrets.auto.tfvars
variable "do_token" {}
variable "do_droplan_token" {}
variable "aws_access_key" { default = "" }
variable "aws_secret_key" { default = "" }
variable "aws_profile" { }
variable "vapid_public_key" { }
variable "vapid_private_key" { }
variable "smtp_login" { }
variable "smtp_password" { }
variable "aws_access_key_id" { }
variable "aws_secret_access_key" { }
variable "backup_aws_access_key_id" { }
variable "backup_aws_secret_access_key" { }

variable "aws_region" { default = "us-east-2" }

# The name of the mastodon project, this will be used for tagging resources and in
# droplet names
variable "project_name" { default = "kcmo-social-staging"}

# The site domain
variable "domain_name" { default = "kcmo.social"}
variable "subdomain" { default = "staging" }

#
# Mastodon configs
#
# Set this to "true" to use the staging ca server and turn on debugging in traefic
variable "traefik_debug" { default = "true" }
variable "s3_bucket" { default = "kcmo-social-staging" }

#
# backup configs
#
variable "s3_backup_bucket" { default = "kcmo-social-staging-backups" }

#
# Swarm machine configs
#
# The image below was set up using custom_image/setup.sh and found from the list with
# curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer SOME_TOKEN_HERE" "https://api.digitalocean.com/v2/images?page=1&private=true"
# It's known in my account as ubuntu-18.04.1-docker-18.06.1ce-B
variable "swarm_image" { default = "37868963" }

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
