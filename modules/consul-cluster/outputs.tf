output "ips" {
  value = ["${hcloud_server.nodes.*.ipv4_address}"]
}
