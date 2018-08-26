output "manager_ips" {
  value = "${module.swarm-cluster.manager_ips}"
}

/*output "manager_domains" {
  value = "${digitalocean_record.manager_records.*.name}"
}*/

output "worker_ips" {
  value = "${module.swarm-cluster.worker_ips}"
}

/*output "worker_domains" {
  value = "${digitalocean_record.worker_records.*.name}"
}*/
