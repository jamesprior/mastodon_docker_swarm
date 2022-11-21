data "template_file" "node_setup" {
  template = file("${path.module}/templates/node_setup.sh.tpl")

  vars = {
    backup_aws_access_key_id     = var.backup_aws_access_key_id
    backup_aws_secret_access_key = var.backup_aws_secret_access_key
    do_droplan_token             = var.do_droplan_token
    do_tag                       = digitalocean_tag.project_name.name
    s3_backup_bucket             = var.s3_backup_bucket
    s3_hostname                  = var.s3_hostname
  }
}

# See https://registry.terraform.io/modules/thojkooi/docker-swarm-mode/digitalocean/0.2.0
module "swarm-cluster" {
  source = "github.com/jamesprior/terraform-digitalocean-docker-swarm-mode?ref=96c67edbebf2a86b03bc57e73a5f9905c96c4f9d"

  /*version           = "0.2.0"*/

  total_managers    = var.swarm_manager_count
  total_workers     = var.swarm_worker_count
  domain            = var.domain_name
  provision_ssh_key = var.provision_ssh_key
  provision_user    = "root"
  region            = var.digitalocean_region

  manager_ssh_keys  = var.ssh_key_ids
  manager_image     = var.swarm_image
  manager_name      = var.manager_name
  manager_size      = var.swarm_manager_size
  manager_user_data = file("${path.module}/provisioning/user_data.sh")
  manager_tags      = [digitalocean_tag.project_name.id, digitalocean_tag.manager.id]

  worker_ssh_keys  = var.ssh_key_ids
  worker_image     = var.swarm_image
  worker_name      = var.worker_name
  worker_size      = var.swarm_worker_size
  worker_user_data = file("${path.module}/provisioning/user_data.sh")
  worker_tags      = [digitalocean_tag.project_name.id, digitalocean_tag.worker.id]
}

# Using a custom image, the only thing the provisioner needs to do is to set up a cronjob
resource "null_resource" "manager_provisioner" {
  depends_on = [module.swarm-cluster]
  count      = var.swarm_manager_count

  triggers = {
    manager_ips = module.swarm-cluster.manager_ips[count.index]
  }

  connection {
    host        = module.swarm-cluster.manager_ips[count.index]
    type        = "ssh"
    user        = "root"
    private_key = file(var.provision_ssh_key)
  }

  provisioner "file" {
    content     = data.template_file.node_setup.rendered
    destination = "/tmp/node_setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/node_setup.sh && /tmp/node_setup.sh && rm /tmp/node_setup.sh",
    ]
  }
}

resource "null_resource" "worker_provisioner" {
  depends_on = [module.swarm-cluster]
  count      = var.swarm_worker_count

  triggers = {
    worker_ips = module.swarm-cluster.worker_ips[count.index]
  }

  connection {
    host        = module.swarm-cluster.worker_ips[count.index]
    type        = "ssh"
    user        = "root"
    private_key = file(var.provision_ssh_key)
  }

  provisioner "file" {
    content     = data.template_file.node_setup.rendered
    destination = "/tmp/node_setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/node_setup.sh && /tmp/node_setup.sh && rm /tmp/node_setup.sh",
    ]
  }
}

