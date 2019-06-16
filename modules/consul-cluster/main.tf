provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_server" "nodes" {
  count       = var.amount
  name        = "node0${count.index + 1}"
  image       = var.image
  server_type = var.server_type
  location    = var.location
  ssh_keys    = var.ssh_keys
  labels      = var.labels
}

resource "null_resource" "bootstrap-nodes" {
  count = var.amount

  connection {
    user = "root"
    host = element(hcloud_server.nodes.*.ipv4_address, count.index)
  }

  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "file" {
    source      = "master.yaml"
    destination = "/etc/salt/master"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "/tmp/bootstrap.sh ${count.index} node0${count.index + 1}.${var.domain} ${join(" ", hcloud_server.nodes.*.ipv4_address)}",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "yum upgrade -y",
      "systemctl reboot",
    ]
  }
}
