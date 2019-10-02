# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent smartindent syntax=hcl:
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
    ephemeral_disk {
      size    = "5000"
      sticky  = true
      migrate = true
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
        {{- if (ds "config").logging_enabled }}
{{ strings.Indent 8 (ds "config").logging_config }}
	{{- end }}
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
        tags = ["nomad", "global", "nexus", "http", "expose", "healthMode=http", "healthMethod=GET", "healthPath=/service/rest/v1/status"]
        port = "http"
        check {
          name     = "alive"
          type     = "http"
          path     = "/service/rest/v1/status"
          interval = "30s"
          timeout  = "2s"
        }
      }
    }
  }
}
