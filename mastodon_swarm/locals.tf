locals {
  all_swarm_ips = concat(
    module.swarm-cluster.manager_ips,
    module.swarm-cluster.worker_ips,
  )

  # eg staging.kcmo.social, this is the domain name the swarm is accessible at in a browser
  swarm_hostname   = var.subdomain == "" ? var.domain_name : "${var.subdomain}.${var.domain_name}"
  swarm_node_count = var.swarm_manager_count + var.swarm_worker_count
}

