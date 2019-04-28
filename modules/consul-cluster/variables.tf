variable "hcloud_token" {}
variable "domain" {}

variable "ssh_keys" {
  type = "list"
}

variable "labels" {
  type = "map"
}

# Optionals

variable "image" {
  default = "fedora-29"
}

variable "server_type" {
  default = "cx11"
}

variable "location" {
  default = "nbg1"
}

variable "count" {
  default = 1
}
