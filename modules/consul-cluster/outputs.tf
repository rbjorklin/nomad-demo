output "status" {
  value = [hcloud_server.nodes.*.status]
}

output "datacenter" {
  value = [hcloud_server.nodes.*.datacenter]
}

output "hosts_and_ips" {
  value = zipmap(hcloud_server.nodes.*.name, hcloud_server.nodes.*.ipv4_address)
}
