module "hcloud-consul-cluster" {
  source = "./modules/consul-cluster"

  ssh_keys = ["${var.ssh_key}"]

  labels = {
    deployment = "${terraform.workspace}"
  }

  hcloud_token = "${var.hcloud_token}"
  count        = 3
  domain       = "rbjorklin.com"

  #location     = "fsn1"
  #image        = "centos-7"
  #server_type  = "cx21"
}
