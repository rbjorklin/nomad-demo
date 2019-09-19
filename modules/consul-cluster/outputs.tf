output "ips" {
  value = [hcloud_server.nodes.*.ipv4_address]
}

output "status" {
  value = [hcloud_server.nodes.*.status]
}

output "datacenter" {
  value = [hcloud_server.nodes.*.datacenter]
}
