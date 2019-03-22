job "opendj" {
  datacenters = ["dc1"]
  type = "service"
  update {
    max_parallel = 1
    min_healthy_time = "10s"
    healthy_deadline = "3m"
    progress_deadline = "10m"
    auto_revert = false
    canary = 0
  }
  migrate {
    max_parallel = 1
    health_check = "checks"
    min_healthy_time = "10s"
    healthy_deadline = "5m"
  }
  group "opendj" {
    count = 1
    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }
    ephemeral_disk {
      size = 101
    }
    task "opendj" {
      driver = "docker"
      config {
        image = "openidentityplatform/opendj:4.3.1"
        port_map {
          ldap = 1389
          ldaps = 1636
          other = 4444
        }
      }
      resources {
        cpu    = 500 # 500 MHz
        memory = 384
        network {
          mbits = 10
          port "ldap" {}
        }
      }
      service {
        name = "opendj"
        tags = ["nomad", "global", "opendj"]
        port = "ldap"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
