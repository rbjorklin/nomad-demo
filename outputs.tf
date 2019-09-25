output "status" {
  value = module.hcloud-consul-cluster.status
}

output "datacenter" {
  value = module.hcloud-consul-cluster.datacenter
}

output "hosts_and_ips" {
  value = module.hcloud-consul-cluster.hosts_and_ips
}
