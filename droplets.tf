resource "digitalocean_droplet" "swarm-manager" {
  count  = "${var.swarm_manager_count}" 
  # See https://developers.digitalocean.com/documentation/v2/#list-all-application-images for a list
  image  = "docker-16-04"
  monitoring = true
  name   = "${var.project_name}-manager-${count.index}"
  private_networking = true
  region = "${var.digitalocean_region}"
  size   = "${var.swarm_manager_size}"
  ssh_keys = "${var.swarm_manager_ssh_key_ids}"
  tags   = ["${digitalocean_tag.project_name.id}"]
  
  connection {
    type = "ssh"
    user = "root"
    private_key = "${file("~/.ssh/id_rsa")}"
  }
  
  provisioner "remote-exec" {
    
    inline = [
      "curl -sSL https://agent.digitalocean.com/install.sh | sh"
    ]
  }
}
