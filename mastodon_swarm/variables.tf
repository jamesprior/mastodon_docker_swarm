# These are secrets
variable "do_droplan_token" {
  description = "A digital ocean api token with read only access for setting up droplan"
}
variable "vapid_public_key" {
  description = "The public key used for web push notifications.  Check the mastodon docs for more info."
}
variable "vapid_private_key" {
  description = "The private key used for web push notifications.  Check the mastodon docs for more info."
}
variable "smtp_login" {
  description = "Username used to log into the SMTP server"
}
variable "smtp_password" {
  description = "Password for logging into the SMTP server"
}
variable "aws_access_key_id" {
  description = "S3 and workalikes access key for user uploaded assets"
}
variable "aws_secret_access_key" {
  description = "S3 and workalikes secret key for user uploaded assets"
}
variable "backup_aws_access_key_id" {
  description = "S3 and workalikes access key for docker volume backups"
}
variable "backup_aws_secret_access_key" {
  description = "S3 and workalikes secret key for docker volume backups"
}
variable "allowed_ssh_ips" {
  type        = "list"
  description = "Your current IP or CIDR block, this will be used to lock down SSH access via DO firewall"
}
variable "ssh_key_ids" {
  type        = "list"
  description = "an array with ssh key IDs, these will be unique to your account.  See https://developers.digitalocean.com/documentation/v2/#list-all-keys"
}
variable "swarm_image" {
  description = "You should build your own image. Use custom_image/setup.sh to build it.  See https://developers.digitalocean.com/documentation/v2/#list-a-user-s-images for how to fetch the image ID."
}


#
# digital ocean configs
#

variable "project_name" {
  description = "The name of the mastodon project, this will be used for tagging resources and in droplet names"
}
variable "domain_name" {
  description = "The top level site domain eg mastodon.social"
}
# Optionally include all resources in a subdomain, eg staging
variable "subdomain" {
  default     = ""
  description = "An optional subdomain to be used in hostnames and DNS names, for example 'staging'"
}
variable "digitalocean_region" {
  default     = "nyc1"
  description = "Resources will be created in this region"
}
variable "provision_ssh_key" {
  default     = "~/.ssh/id_rsa"
  description = "File path to SSH private key used to access the provisioned nodes. Ensure this key corresponds to an SSH key in ssh_key_ids"
}

#
# Mastodon configs
#
variable "mastodon_image" {
  description = "The docker image to deploy, eg tootsuite/mastodon:latest"
}
variable "acme_email" {
  description = "The email address submitted to lets encrypt with acme challenges"
}
#
variable "traefik_debug" {
  default     = "true"
  description = "Set this to false to use the production lets encrypt ca server and turn off debugging in traefik"
}
variable "traefik_send_anonymous_usage" {
  default     = "true"
  description = "See https://docs.traefik.io/basics/#collected-data for more info"
}

variable "smtp_server" {
  description = "SMTP server address for outbound email"
}
variable "smtp_port" {
  description = "SMTP server port for outbound email"
}
variable "smtp_from_address" {
  description = "Sever generated email will be sent from this email address"
}


variable "s3_bucket" {
  description = "Used for user uploaded assets.  It must be publicly available and configured with CORS."
}
variable "s3_region" {
  default = "nyc3"
}
variable "s3_protocol" { default = "https" }
variable "s3_hostname" { default = "nyc3.digitaloceanspaces.com" }
variable "s3_alias_host" {
  description = "The CDN edge endpoint for the space, passed to paperclip as s3_host_alias"
  default = "nyc3.digitaloceanspaces.com"
}

#
# backup configs
#
variable "s3_backup_bucket" {
  description = "Used for docker volume backups.  It should not be publically accessible"
}


#
# Swarm machine configs
#
variable "swarm_manager_count" {
  default     = 3
  description = "The number of manager nodes to create in the docker swarm.  Manager nodes will be assigned work."
}
variable "swarm_manager_size" {
  default = "s-1vcpu-2gb"
  description = "The droplet size of the manager nodes, use the id or the slug.  To fetch a list see https://developers.digitalocean.com/documentation/v2/#list-all-sizes"
}
variable "swarm_worker_count" {
  default     = 0
  description = "The number of worker nodes to create in the docker swarm."
}
variable "swarm_worker_size" {
  default = "s-1vcpu-2gb"
  description = "The droplet size of the worker nodes, use the id or the slug.  To fetch a list see https://developers.digitalocean.com/documentation/v2/#list-all-sizes"
}
variable "manager_name" {
  default     = "manager"
  description = "Prefix for name of manager nodes. Any subdomain will be appended."
}

variable "worker_name" {
  default     = "worker"
  description = "Prefix for name of worker nodes.  Any subdomain will be appended."
}
