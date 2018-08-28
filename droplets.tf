data "template_file" "node_setup" {
  template = "${file("templates/node_setup.sh.tpl")}"

  vars {
    do_droplan_token   = "${var.do_droplan_token}"
    do_tag             = "${digitalocean_tag.project_name.name}"
  }
}

# See https://registry.terraform.io/modules/thojkooi/docker-swarm-mode/digitalocean/0.2.0
module "swarm-cluster" {
  source            = "thojkooi/docker-swarm-mode/digitalocean"
  version           = "0.2.0"

  total_managers    = "${var.swarm_manager_count}" 
  total_workers     = "${var.swarm_worker_count}" 
  domain            = "${var.domain_name}"
  provision_ssh_key = "${var.provision_ssh_key}"
  provision_user    = "root"
  region            = "${var.digitalocean_region}"
  
  manager_ssh_keys  = "${var.ssh_key_ids}"
  manager_image     = "docker-16-04"
  manager_size      = "${var.swarm_manager_size}"
  manager_user_data = "${file("provisioning/swarm_user_data.sh")}"
  manager_tags      = ["${digitalocean_tag.project_name.id}", "${digitalocean_tag.manager.id}"]
  
  worker_ssh_keys   = "${var.ssh_key_ids}"
  worker_image      = "docker-16-04"
  worker_size       = "${var.swarm_worker_size}"
  worker_user_data  = "${file("provisioning/swarm_user_data.sh")}"
  worker_tags       = ["${digitalocean_tag.project_name.id}", "${digitalocean_tag.worker.id}"]
}


# Setup some user accounts, firewall access for swarm, and droplan for private networking
# Tags the first manager node for postgres
# Tags the second manager node for redis
resource "null_resource" "manager_provisioner" {
  depends_on = ["module.swarm-cluster"]
  count      = "${var.swarm_manager_count}"
  
  triggers {
     manager_ips = "${module.swarm-cluster.manager_ips[count.index] }"
  }
  
  connection {
    host        = "${module.swarm-cluster.manager_ips[count.index]}"
    type        = "ssh"
    user        = "root"
    private_key = "${file("${var.provision_ssh_key}")}"
  }

  provisioner "file" {
    content     = "${data.template_file.node_setup.rendered}"
    destination = "/tmp/node_setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/node_setup.sh",
      "/tmp/node_setup.sh",
      "rm /tmp/node_setup.sh",
    ]
  }
}

resource "null_resource" "worker_provisioner" {
  depends_on = ["module.swarm-cluster"]
  count      = "${var.swarm_worker_count}"
  
  triggers {
     worker_ips = "${ module.swarm-cluster.worker_ips[count.index] }"
  }
  
  connection {
    host        = "${module.swarm-cluster.worker_ips[count.index]}"
    type        = "ssh"
    user        = "root"
    private_key = "${file("${var.provision_ssh_key}")}"
  }

  provisioner "file" {
    content     = "${data.template_file.node_setup.rendered}"
    destination = "/tmp/node_setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/node_setup.sh",
      "/tmp/node_setup.sh",
      "rm /tmp/node_setup.sh",
    ]
  }
}