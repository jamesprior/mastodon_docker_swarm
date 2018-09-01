output "swarm_hostname" {
  value = "${module.mastodon_swarm.swarm_hostname}"
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
