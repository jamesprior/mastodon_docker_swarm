module "mastodon_swarm" {
  source  = "../mastodon_swarm"
  do_droplan_token = "${var.do_droplan_token}"
  vapid_public_key = "${var.vapid_public_key}"
  vapid_private_key = "${var.vapid_private_key}"
  smtp_login = "${var.smtp_login}"
  smtp_password = "${var.smtp_password}"
  aws_access_key_id = "${var.aws_access_key_id}"
  aws_secret_access_key = "${var.aws_secret_access_key}"
  backup_aws_access_key_id = "${var.backup_aws_access_key_id}"
  backup_aws_secret_access_key = "${var.backup_aws_secret_access_key}"
 
  # Common configs for production and staging
  allowed_ssh_ips = "${var.allowed_ssh_ips}"
  domain_name = "kcmo.social"
  ssh_key_ids = "${var.ssh_key_ids}"
  acme_email = "acme@kcmo.social"
  smtp_server = "email-smtp.us-east-1.amazonaws.com"
  smtp_port = "587"
  smtp_from_address = "notifications@kcmo.social"
  
  # Production specific configs
  mastodon_image = "tootsuite/mastodon:v2.5.2"
  project_name = "kcmo-social-production"
  domain_name = "kcmo.social"
  traefik_debug = "false"
  s3_bucket = "kcmo-social"
  s3_backup_bucket = "kcmo-social-backups"
  swarm_image = "${var.swarm_image}"
  swarm_manager_count = 3
  swarm_manager_size = "s-1vcpu-2gb"
  swarm_worker_count = 0
  swarm_worker_size = "s-1vcpu-1gb"
}
