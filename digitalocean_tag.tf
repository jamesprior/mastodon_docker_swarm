resource "digitalocean_tag" "project_name" {
  name = "${var.project_name}"
}