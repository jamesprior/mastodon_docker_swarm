resource "digitalocean_tag" "project_name" {
  name = "${var.project_name}"
}

resource "digitalocean_tag" "manager" {
  name = "manager-${var.project_name}"
}

resource "digitalocean_tag" "worker" {
  name = "worker-${var.project_name}"
}