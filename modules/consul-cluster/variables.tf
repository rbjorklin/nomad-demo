variable "hcloud_token" {
}

variable "domain" {
}

variable "ssh_keys" {
  type = list(string)
}

variable "labels" {
  type = map(string)
}

# Optionals

variable "image" {
  default = "fedora-30"
}

variable "server_type" {
  default = "cx11"
}

variable "location" {
  default = "nbg1"
}

variable "amount" {
  default = 1
}
