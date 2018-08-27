output "tld" {
  value = "${var.domain_name}"
}
output "manager_subdomains" {
  value = "${digitalocean_record.manager_records.*.name}"
}

output "manager_ips" {
  value = "${module.swarm-cluster.manager_ips}"
}

output "worker_subdomains" {
  value = "${digitalocean_record.worker_records.*.name}"
}

output "worker_ips" {
  value = "${module.swarm-cluster.worker_ips}"
}
