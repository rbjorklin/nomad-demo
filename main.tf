module "hcloud-consul-cluster" {
  source = "./modules/consul-cluster"

  ssh_keys = [var.ssh_key]

  labels = {
    deployment = terraform.workspace
  }

  hcloud_token = var.hcloud_token
  amount       = 3
  domain       = "rbjorklin.com"
  #location     = "fsn1"
  image       = "centos-8"
  server_type = "cx21" # ccx21 requires a higher vCPU limit with Hetzner, try ccx11 if it fails
}

module "r53-dns-records" {
  source = "./modules/route53"

  #amount        = length(module.hcloud-consul-cluster.hosts_and_ips)
  hosts_and_ips   = module.hcloud-consul-cluster.hosts_and_ips
  domain          = "rbjorklin.com."
  aws_r53_zone_id = var.aws_r53_zone_id
}
