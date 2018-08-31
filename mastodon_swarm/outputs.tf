output "domain_name" {
  value = "${var.domain_name}"
}

output "first_manager" {
  value = "manager-01.${var.digitalocean_region}.${var.domain_name}"
}

output "manager_ips" {
  value = "${module.swarm-cluster.manager_ips}"
}

output "worker_ips" {
  value = "${module.swarm-cluster.worker_ips}"
}
