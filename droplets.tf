resource "digitalocean_droplet" "swarm-master" {
  count  = "${var.swarm_master_count}" 
  # See https://developers.digitalocean.com/documentation/v2/#list-all-application-images for a list
  image  = "docker-16-04"
  monitoring = true
  name   = "${var.project_name}-master-${count.index}"
  private_networking = true
  region = "${var.digitalocean_region}"
  size   = "${var.swarm_master_size}"
  ssh_keys = "${var.swarm_master_ssh_key_ids}"
  tags   = ["${digitalocean_tag.project_name.id}"]
}
