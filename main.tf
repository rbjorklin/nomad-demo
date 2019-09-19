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
  image        = "fedora-30"
  server_type  = "ccx21" # ccx21 requires a higher vCPU limit with Hetzner, try ccx11 if it fails
}
