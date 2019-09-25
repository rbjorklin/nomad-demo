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
        command = "node_exporter-0.18.1.linux-amd64/node_exporter" # path is relative to alloc
      }
      artifact {
        source = "https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz"
        #destination = "local/" # local/ is the default and relative to alloc
        options {
          checksum = "sha256:b2503fd932f85f4e5baf161268854bf5d22001869b84f00fd2d1f57b51b72424"
        }
      }
      resources {
        cpu    = 500
        memory = 100
        network {
          port "http" {
            static = 9100
          }
        }
      }
      service {
        name = "node-exporter"
        tags = ["nomad", "global", "node_exporter", "http"]
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
