# Deploys the stacks to the cluster once it is provisioned

terraform {
  required_version = ">= 0.11.6"
}

locals {
  acme_caserver         = "${(var.traefik_debug == "true" ? local.acme_staging_caserver : local.acme_prod_caserver)}"
  acme_prod_caserver    = "https://acme-v02.api.letsencrypt.org/directory"
  acme_staging_caserver = "https://acme-staging-v02.api.letsencrypt.org/directory"
  # Postgres always goes on the first manager
  postgres_node_name    = "${var.manager_name}-01"
  # Redis will go on the second manager if there is one.
  #   If there is only one manager and no workers it goes on the first manager.
  #   Otherwise, it goes on the first worker
  redis_node_name       = "${(var.swarm_manager_count > 1 ? "${var.manager_name}-02" : (var.swarm_worker_count > 0 ? "${var.worker_name}-01" : "${var.manager_name}-01") )} "
  traefik_debug_flag    = "${(var.traefik_debug == "true" ? "--debug" : "")}"
  # Traefik goes on the second manager if there are more than one, otherwise it goes on the first manager
  traefik_node_name     = "${(var.swarm_manager_count > 1 ? "${var.manager_name}-02" : "${var.manager_name}-01")}"
}


resource "random_string" "redis_pw" {
  length  = 16
  special = false
}

resource "random_string" "postgres_pw" {
  length  = 16
  special = false
}

resource "random_id" "secret_key_base" {
  byte_length = 64
}

resource "random_id" "otp_secret" {
  byte_length = 64
}

data "template_file" "mastodon_yml" {
  template = "${file("${path.module}/templates/mastodon.yml.tpl")}"

  vars {
    acme_email                   = "${var.acme_email}"
    acme_caserver                = "${local.acme_caserver}"
    mastodon_image               = "${var.mastodon_image}"
    redis_pw                     = "${random_string.redis_pw.result}"
    swarm_hostname               = "${local.swarm_hostname}"
    s3_backup_bucket             = "${var.s3_backup_bucket}"
    s3_hostname                  = "${var.s3_hostname}"
    traefik_debug_flag           = "${local.traefik_debug_flag}"
    traefik_send_anonymous_usage = "${var.traefik_send_anonymous_usage}"
  }
}

data "template_file" "mastodon_env" {
  template = "${file("${path.module}/templates/mastodon.env.tpl")}"

  vars {
    redis_pw              = "${random_string.redis_pw.result}"
    postgres_pw           = "${random_string.postgres_pw.result}"
    swarm_hostname        = "${local.swarm_hostname}"
    secret_key_base       = "${random_id.secret_key_base.hex}"
    otp_secret            = "${random_id.otp_secret.hex}"
    smtp_from_address     = "${var.smtp_from_address}"
    smtp_login            = "${var.smtp_login}"
    smtp_password         = "${var.smtp_password}"
    smtp_server           = "${var.smtp_server}"
    smtp_port             = "${var.smtp_port}"
    vapid_private_key     = "${var.vapid_private_key}"
    vapid_public_key      = "${var.vapid_public_key}"
    s3_bucket             = "${var.s3_bucket}"
    aws_access_key_id     = "${var.aws_access_key_id}"
    aws_secret_access_key = "${var.aws_secret_access_key}"
    s3_region             = "${var.s3_region}"
    s3_protocol           = "https"
    s3_hostname           = "${var.s3_hostname}"
    s3_alias_host         = "${var.s3_alias_host}"
  }
}

resource "null_resource" "deploy_portainer" {
  depends_on = ["module.swarm-cluster"]

  triggers = {
    portainer_yml_sha1 = "${sha1(file("${path.module}/provisioning/portainer.yml"))}"
  }

  connection {
    host        = "${module.swarm-cluster.manager_ips[0]}"
    type        = "ssh"
    user        = "mastodon"
    private_key = "${file("${var.provision_ssh_key}")}"
  }

  provisioner "file" {
    content     = "${file("${path.module}/provisioning/portainer.yml")}"
    destination = "/home/mastodon/portainer.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "docker stack deploy --compose-file=portainer.yml portainer",
    ]
  }
}

resource "null_resource" "deploy_mastodon" {
  depends_on = ["module.swarm-cluster"]

  triggers = {
    mastodon_env_sha1  = "${sha1(file("${path.module}/templates/mastodon.env.tpl"))}"
    mastodon_yml_sha1  = "${sha1(file("${path.module}/templates/mastodon.yml.tpl"))}"
    mastodon_version   = "${var.mastodon_image}"
  }

  connection {
    host        = "${module.swarm-cluster.manager_ips[0]}"
    type        = "ssh"
    user        = "mastodon"
    private_key = "${file("${var.provision_ssh_key}")}"
  }

  provisioner "file" {
    content     = "${data.template_file.mastodon_yml.rendered}"
    destination = "/home/mastodon/mastodon.yml"
  }

  provisioner "file" {
    content     = "${data.template_file.mastodon_env.rendered}"
    destination = "/home/mastodon/mastodon.env"
  }

  provisioner "file" {
    content     = "${file("${path.module}/provisioning/portainer.yml")}"
    destination = "/home/mastodon/portainer.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "docker node update --label-add db=true ${local.postgres_node_name}",
      "docker node update --label-add redis=true ${local.redis_node_name}",
      "docker node update --label-add traefik=true ${local.traefik_node_name}",
      "docker stack deploy --compose-file=mastodon.yml mastodon"
    ]
  }
}