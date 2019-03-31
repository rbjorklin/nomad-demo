provider "hcloud" {
  token = "${var.hcloud_token}"
}

resource "hcloud_server" "nodes" {
  count       = "${var.count}"
  name        = "node0${count.index+1}"
  image       = "${var.image}"
  server_type = "${var.server_type}"
  location    = "${var.location}"
  ssh_keys    = "${var.ssh_keys}"
  labels      = "${var.labels}"
}
