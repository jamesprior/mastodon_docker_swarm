output "manager_ips" {
  value = "${module.swarm-cluster.manager_ips}"
}

output "worker_ips" {
  value = "${module.swarm-cluster.worker_ips}"
}