# Deploys the stacks to the cluster once it is provisioned

locals {
  acme_prod_caserver = "https://acme-v02.api.letsencrypt.org/directory"
  acme_staging_caserver = "https://acme-staging-v02.api.letsencrypt.org/directory"
  acme_caserver = "${(var.traefik_debug == "true" ? local.acme_staging_caserver : local.acme_prod_caserver)}"
  traefik_debug_flag = "${(var.traefik_debug == "true" ? "--debug" : "")}"
}


resource "random_string" "redis_pw" {
  length = 16
  special = false
}

resource "random_string" "postgres_pw" {
  length = 16
  special = false
}

resource "random_id" "secret_key_base" {
  byte_length = 64
}

resource "random_id" "otp_secret" {
  byte_length = 64
}

data "template_file" "mastodon_assets" {
  template = "${file("${path.module}/templates/precompile_assets.sh.tpl")}"

  vars {
    mastodon_image         = "${var.mastodon_image}"
    first_manager_hostname = "${var.manager_name}-01"
  }
}

data "template_file" "mastodon_yml" {
  template = "${file("${path.module}/templates/mastodon.yml.tpl")}"

  vars {
    acme_email         = "${var.acme_email}"
    acme_caserver      = "${local.acme_caserver}"
    mastodon_image     = "${var.mastodon_image}"
    swarm_hostname     = "${local.swarm_hostname}"
    s3_backup_bucket   = "${var.s3_backup_bucket}"
    s3_hostname        = "${var.s3_hostname}"
    redis_pw           = "${random_string.redis_pw.result}"
    traefik_debug_flag = "${local.traefik_debug_flag}"
    traefik_send_anonymous_usage = "${var.traefik_send_anonymous_usage}"
  }
}

data "template_file" "mastodon_env" {
  template = "${file("${path.module}/templates/mastodon.env.tpl")}"

  vars {
    redis_pw           = "${random_string.redis_pw.result}"
    postgres_pw        = "${random_string.postgres_pw.result}"
    swarm_hostname     = "${local.swarm_hostname}"
    secret_key_base    = "${random_id.secret_key_base.hex}"
    otp_secret         = "${random_id.otp_secret.hex}"
    smtp_from_address  = "${var.smtp_from_address}"
    smtp_login         = "${var.smtp_login}"
    smtp_password      = "${var.smtp_password}"
    smtp_server        = "${var.smtp_server}"
    smtp_port          = "${var.smtp_port}"
    vapid_private_key  = "${var.vapid_private_key}"
    vapid_public_key   = "${var.vapid_public_key}"
    s3_bucket          = "${var.s3_bucket}"
    aws_access_key_id   = "${var.aws_access_key_id}"
    aws_secret_access_key = "${var.aws_secret_access_key}"
    s3_region          = "${var.s3_region}"
    s3_protocol        = "https"
    s3_hostname        = "${var.s3_hostname}"
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

# Compile the assets in a volume on each node in the swarm.
# Note that this will copy the environment file but it 
# will not be triggered if the environment file changes.  
# This will be triggered if the image changes
resource "null_resource" "deploy_mastodon_assets" {
  depends_on = ["module.swarm-cluster"]
  count  = "${var.swarm_manager_count + var.swarm_worker_count}"

  triggers = {
    mastodon_image     = "${var.mastodon_image}"
    all_swarm_ips      = "${local.all_swarm_ips[count.index]}"
  }
  
  connection {
    host        = "${local.all_swarm_ips[count.index]}"
    type        = "ssh"
    user        = "mastodon"
    private_key = "${file("${var.provision_ssh_key}")}"
  }

  provisioner "file" {
    content     = "${data.template_file.mastodon_assets.rendered}"
    destination = "/home/mastodon/precompile_assets.sh"
  }
  
  provisioner "file" {
    content     = "${data.template_file.mastodon_env.rendered}"
    destination = "/home/mastodon/mastodon.env"
  }
  
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/mastodon/precompile_assets.sh",
      "/home/mastodon/precompile_assets.sh",
      "rm /home/mastodon/precompile_assets.sh"
    ]
  }
}

resource "null_resource" "deploy_mastodon" {
  depends_on = ["module.swarm-cluster", "null_resource.deploy_mastodon_assets"]
  
  triggers = {
    mastodon_yml_sha1  = "${sha1(file("${path.module}/templates/mastodon.yml.tpl"))}"
    mastodon_env_sha1  = "${sha1(file("${path.module}/templates/mastodon.env.tpl"))}"
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
      "docker node update --label-add db=true ${var.manager_name}-01",
      "docker node update --label-add redis=true ${var.manager_name}-02",
      "docker node update --label-add traefik=true ${var.manager_name}-02",
      "docker node update --label-add web=true --label-add streaming=true --label-add sidekiq=true ${var.manager_name}01",
      "docker node update --label-add web=true --label-add streaming=true --label-add sidekiq=true ${var.manager_name}-02",
      "docker node update --label-add web=true --label-add streaming=true --label-add sidekiq=true ${var.manager_name}-03",
      "docker stack deploy --compose-file=mastodon.yml mastodon"
    ]
  }
}