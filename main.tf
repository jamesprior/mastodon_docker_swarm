# Deploys the stacks to the cluster once it is provisioned

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

data "template_file" "mastodon_yml" {
  template = "${file("templates/mastodon.yml.tpl")}"

  vars {
    acme_email    = "${var.acme_email}"
    acme_caserver = "${var.acme_caserver}"
    domain_name   = "${var.domain_name}"
    redis_pw      = "${random_string.redis_pw.result}"
  }
}

data "template_file" "mastodon_env" {
  template = "${file("templates/mastodon_env.production.tpl")}"

  vars {
    redis_pw          = "${random_string.redis_pw.result}"
    postgres_pw       = "${random_string.postgres_pw.result}"
    domain_name       = "${var.domain_name}"
    secret_key_base   = "${random_id.secret_key_base.hex}"
    otp_secret        = "${random_id.otp_secret.hex}"
    vapid_private_key = "${var.vapid_private_key}"
    vapid_public_key  = "${var.vapid_public_key}"
  }
}

resource "null_resource" "deploy_stack" {
  depends_on = ["module.swarm-cluster"]
  
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
    destination = "/home/mastodon/mastodon_env.production"
  }
  
  provisioner "file" {
    content     = "${file("provisioning/portainer.yml")}"
    destination = "/home/mastodon/portainer.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "docker node update --label-add db=true manager-01",
      "docker node update --label-add redis=true manager-02",
      "docker node update --label-add traefik=true manager-02",
      "docker stack deploy --compose-file=portainer.yml portainer",
      "docker stack deploy --compose-file=mastodon.yml mastodon"
    ]
  }
}