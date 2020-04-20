# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent smartindent syntax=hcl:
job "node_exporter" {
  datacenters = ["{{ (datasource "config").datacenter }}"]
  type = "system"
  update {
    max_parallel = 1
    min_healthy_time = "10s"
    healthy_deadline = "3m"
    progress_deadline = "10m"
    auto_revert = false
    canary = 0
  }
  group "node_exporter" {
    count = 1
    restart {
      attempts = 3
      interval = "2m"
      delay = "30s"
      mode = "fail"
    }
    task "node_exporter" {
      driver = "raw_exec"
      config {
        command = "node_exporter-1.0.0-rc.0.linux-amd64/node_exporter" # path is relative to alloc
      }
      artifact {
        source = "https://github.com/prometheus/node_exporter/releases/download/v1.0.0-rc.0/node_exporter-1.0.0-rc.0.linux-amd64.tar.gz"
        #destination = "local/" # local/ is the default and relative to alloc
        options {
          checksum = "sha256:f175cffc4b96114e336288c9ea54b54abe793ae6fcbec771c81733ebc2d7be7c"
        }
      }
      resources {
        cpu    = 200
        memory = 100
        network {
          port "http" {
            static = 9100
          }
        }
      }
      service {
        name = "node-exporter"
        tags = ["prometheus=scrape"]
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
