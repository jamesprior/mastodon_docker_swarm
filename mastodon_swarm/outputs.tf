
output "first_manager" {
  value = "manager-01.${var.digitalocean_region}.${local.node_subdomain}"
}

output "manager_ips" {
  value = "${module.swarm-cluster.manager_ips}"
}

output "worker_ips" {
  value = "${module.swarm-cluster.worker_ips}"
}

output "swarm_hostname" {
  value = "${local.swarm_hostname}"
}

