output "ips" {
  value = ["${hcloud_server.nodes.*.ipv4_address}"]
}

output "status" {
  value = ["${hcloud_server.nodes.*.status}"]
}

output "server_type" {
  value = ["${hcloud_server.nodes.*.server_type}"]
}

output "location" {
  value = ["${hcloud_server.nodes.*.location}"]
}

output "datacenter" {
  value = ["${hcloud_server.nodes.*.datacenter}"]
}

output "image" {
  value = ["${hcloud_server.nodes.*.image}"]
}
