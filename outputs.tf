output "ips" {
  value = module.hcloud-consul-cluster.ips
}

output "status" {
  value = module.hcloud-consul-cluster.status
}

output "datacenter" {
  value = module.hcloud-consul-cluster.datacenter
}
