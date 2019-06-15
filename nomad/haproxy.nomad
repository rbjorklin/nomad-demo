job "haproxy" {
  datacenters = ["dc1"]
  type = "service"
  constraint {
    operator  = "distinct_hosts"
    value     = "true"
  }
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
  group "haproxy" {
    count = 3
    restart {
      attempts = 2
      interval = "2m"
      delay = "15s"
      mode = "fail"
    }
    ephemeral_disk {
      size = 300
    }
    task "haproxy" {
      driver = "docker"
      config {
        image = "haproxy:alpine"
        args = [
          "-W",
          "-db",
          "-f",
          "/usr/local/etc/haproxy",
        ]
        network_mode = "host"
        mounts = [
            {
              type = "bind"
              target = "/usr/local/etc/haproxy"
              source = "/opt/haproxy/conf"
              readonly = true
            }
        ]
      }
      resources {
        cpu    = 500 # 500 MHz
        memory = 256
        network {
          mbits = 10
          port "http" {
            static = 80
          }
          port "https" {
            static = 443
          }
        }
      }
      service {
        name = "haproxy"
        tags = ["nomad", "global", "haproxy", "http", "https"]
        port = "http"
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
