job "nexus" {
  datacenters = ["{{ (datasource "config").datacenter }}"]
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
  group "nexus" {
    count = 1
    restart {
      attempts = 3
      interval = "2m"
      delay = "30s"
      mode = "fail"
    }
    task "nexus" {
      driver = "docker"
      config {
        image = "sonatype/nexus3:latest"
        port_map {
          http = 8081
        }
        mounts = [
            {
              type = "volume"
              target = "/nexus-data"
              source = "nexus-data"
            }
        ]
        logging {
          type = "gelf"
          config {
            gelf-address = "udp://graylog.rbjorklin.com:12201"
            labels = "testXlabel"
          }
        }
      }
      resources {
        cpu    = 1500
        memory = 2048
        network {
          port "http" {}
        }
      }
      service {
        name = "nexus"
        tags = ["nomad", "global", "nexus", "http"]
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
