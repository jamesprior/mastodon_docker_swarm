output "domain_name" {
  value = "${module.mastodon_swarm.domain_name}"
}

output "first_manager" {
  value = "${module.mastodon_swarm.first_manager}"
}

output "manager_ips" {
  value = "${module.mastodon_swarm.manager_ips}"
}

output "worker_ips" {
  value = "${module.mastodon_swarm.worker_ips}"
}
