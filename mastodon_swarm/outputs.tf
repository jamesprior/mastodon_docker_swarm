output "first_manager" {
  value = "${var.manager_name}-01.${var.digitalocean_region}.${var.domain_name}"
}

output "manager_ips" {
  value = module.swarm-cluster.manager_ips
}

output "worker_ips" {
  value = module.swarm-cluster.worker_ips
}

output "swarm_hostname" {
  value = local.swarm_hostname
}

