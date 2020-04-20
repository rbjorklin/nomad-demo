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
    meta {
      dummy = "reload2"
    }
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
    #volume "data" {
    #  type      = "host"
    #  source    = "nexus"
    #  read_only = false
    #}
    network {
      mode = "bridge"
      #port "nexus" {
      #  to = -1
      #}
    }
    service {
      name = "nexus"
      port = "8081"
      #address_mode = "driver"
      connect {
        sidecar_service {
          #tags = ["http", "consul-connect", "hostHeaderBegin=nexus", "healthMode=http", "healthMethod=GET", "healthPath=/service/rest/v1/status"]
          tags = ["http", "consul-connect", "hostHeaderBegin=nexus"]
        }
      }
      #check {
      #  name     = "alive"
      #  type     = "http"
      #  path     = "/service/rest/v1/status"
      #  interval = "30s"
      #  timeout  = "2s"
      #  address_mode = "driver"
      #}
    }
    task "nexus" {
      driver = "docker"
      #volume_mount {
      #  volume      = "data"
      #  destination = "/nexus-data"
      #  read_only = false
      #}
      env {
        NEXUS_HOME = "${NOMAD_TASK_DIR}/data"
      }
      config {
        image = "sonatype/nexus3:latest"
        #port_map {
        #  nexus = 8081
        #}
        {{- if (ds "config").logging_enabled }}
{{ strings.Indent 8 (ds "config").logging_config }}
	{{- end }}
      }
      resources {
        cpu    = 300
        memory = 1000
      }
    }
  }
}
