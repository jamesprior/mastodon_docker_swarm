# From https://github.com/thojkooi/terraform-digitalocean-docker-swarm-firewall
# See MIT license below

locals {
  cluster_tags = ["${digitalocean_tag.manager.id}", "${digitalocean_tag.worker.id}"]
}

resource "digitalocean_firewall" "swarm-internal-fw" {
  name        = "${var.project_name}-swarm-internal-fw"
  tags        = ["${digitalocean_tag.project_name.id}"]

  outbound_rule = [
    {
      protocol                = "tcp"
      port_range              = "2377"
      destination_tags        = ["${local.cluster_tags}"]
    },
    {
      # for container network discovery
      protocol                = "tcp"
      port_range              = "7946"
      destination_tags        = ["${local.cluster_tags}"]
    },
    {
      # UDP for the container overlay network.
      protocol                = "udp"
      port_range              = "4789"
      destination_tags        = ["${local.cluster_tags}"]
    },
    {
      # for container network discovery.
      protocol                = "udp"
      port_range              = "7946"
      destination_tags        = ["${local.cluster_tags}"]
    },
  ]

  inbound_rule = [
    {
      protocol           = "tcp"
      port_range         = "2377"
      source_tags        = ["${local.cluster_tags}"]
    },
    {
      # for container network discovery
      protocol           = "tcp"
      port_range         = "7946"
      source_tags        = ["${local.cluster_tags}"]
    },
    {
      # UDP for the container overlay network.
      protocol           = "udp"
      port_range         = "4789"
      source_tags        = ["${local.cluster_tags}"]
    },
    {
      # for container network discovery.
      protocol           = "udp"
      port_range         = "7946"
      source_tags        = ["${local.cluster_tags}"]
    },
  ]
}

# remember there is a 50 rule limit
resource "digitalocean_firewall" "swarm-external-fw" {
  name        = "${var.project_name}-swarm-external-fw"
  tags        = ["${digitalocean_tag.project_name.id}"]

  outbound_rule = [
    # http/https connections
    {
      protocol                       = "tcp"
      port_range                     = "80"
      destination_addresses          = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol                       = "tcp"
      port_range                     = "443"
      destination_addresses          = ["0.0.0.0/0", "::/0"]
    },
    # DNS lookups
    {
      protocol                       = "udp"
      port_range                     = "53"
      destination_addresses          = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol                       = "tcp"
      port_range                     = "53"
      destination_addresses          = ["0.0.0.0/0", "::/0"]
    },
    # NTP
    {
      protocol                = "udp"
      port_range              = "123"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
    },
    # SMTP
    {
      protocol                = "tcp"
      port_range              = "${var.smtp_port}"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
    },
  ]
  
  inbound_rule = [
    # http/https connections
    {
      protocol                       = "tcp"
      port_range                     = "80"
      source_addresses               = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol                       = "tcp"
      port_range                     = "443"
      source_addresses               = ["0.0.0.0/0", "::/0"]
    },
  ]
}

resource "digitalocean_firewall" "swarm-ssh-fw" {
  name        = "${var.project_name}-swarm-ssh-fw"
  tags        = ["${digitalocean_tag.project_name.id}"]

  # git/ssh connection
  outbound_rule = [
    {
      protocol                = "tcp"
      port_range              = "22"
      destination_addresses   = ["${var.allowed_ssh_ips}"]
    },
  ]

  inbound_rule = [
    {
      protocol           = "tcp"
      port_range         = "22"
      source_addresses   = ["${var.allowed_ssh_ips}"]
    },
  ]
}



/*MIT License

Copyright (c) 2017 Thomas Kooi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.*/