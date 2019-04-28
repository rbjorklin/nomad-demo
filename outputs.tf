output "status" {
  value = "${module.hcloud-consul-cluster.status}"
}

output "ips" {
  value = "${module.hcloud-consul-cluster.ips}"
}

output "server_type" {
  value = "${module.hcloud-consul-cluster.server_type}"
}

output "location" {
  value = "${module.hcloud-consul-cluster.location}"
}

output "datacenter" {
  value = "${module.hcloud-consul-cluster.datacenter}"
}

output "image" {
  value = "${module.hcloud-consul-cluster.image}"
}
