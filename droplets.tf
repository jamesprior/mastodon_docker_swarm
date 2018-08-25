data "template_file" "node_provisioner" {
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
  manager_user_data = "${data.template_file.node_provisioner.rendered}"
  manager_tags      = ["${digitalocean_tag.project_name.id}", "${digitalocean_tag.manager.id}"]
  
  worker_ssh_keys   = "${var.ssh_key_ids}"
  worker_image      = "docker-16-04"
  worker_size       = "${var.swarm_worker_size}"
  worker_user_data  = "${data.template_file.node_provisioner.rendered}"
  worker_tags       = ["${digitalocean_tag.project_name.id}", "${digitalocean_tag.worker.id}"]
}