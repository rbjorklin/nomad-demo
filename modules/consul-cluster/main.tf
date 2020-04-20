provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_server" "nodes" {
  count       = var.amount
  name        = "${var.location}${count.index + 1}"
  image       = var.image
  server_type = var.server_type
  location    = var.location
  ssh_keys    = var.ssh_keys
  labels      = var.labels
}

resource "hcloud_network" "hetznet" {
  name     = "hetznet"
  ip_range = "10.0.0.0/8"
}

resource "hcloud_network_subnet" "sub-hetznet" {
  network_id   = hcloud_network.hetznet.id
  type         = "server"
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

resource "hcloud_server_network" "srvnetwork" {
  count      = var.amount
  server_id  = hcloud_server.nodes[count.index].id
  network_id = hcloud_network.hetznet.id
}
