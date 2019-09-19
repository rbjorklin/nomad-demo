job "prometheus" {
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
  group "prometheus" {
    count = 1
    restart {
      attempts = 3
      interval = "50m"
      delay = "15s"
      mode = "fail"
    }
    ephemeral_disk {
      size = 300
    }
    task "prometheus" {
      driver = "docker"
      config {
        image = "prom/prometheus:latest"
        port_map {
          http = 9090
        }
        mounts = [
            {
              type = "volume"
              target = "/prometheus"
              source = "prometheus"
            }
        ]
      }
      resources {
        cpu    = 500 # 500 MHz
        memory = 512
        network {
          port "http" {}
        }
      }
      service {
        name = "prometheus"
        tags = ["nomad", "global", "prometheus", "http"]
        port = "http"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
    task "alertmanager" {
      driver = "docker"
      config {
        image = "prom/alertmanager:latest"
        port_map {
          http = 9093
        }
        mounts = [
            {
              type = "volume"
              target = "/alertmanager"
              source = "alertmanager"
            }
        ]
      }
      resources {
        cpu    = 500 # 500 MHz
        memory = 512
        network {
          port "http" {}
        }
      }
      service {
        name = "grafana"
        tags = ["nomad", "global", "alertmanager", "http"]
        port = "http"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
    task "grafana" {
      driver = "docker"
      config {
        image = "grafana/grafana:6.4.0-beta1"
        port_map {
          http = 3000
        }
      }
      resources {
        cpu    = 500 # 500 MHz
        memory = 512
        network {
          port "http" {}
        }
      }
      service {
        name = "grafana"
        tags = ["nomad", "global", "grafana", "http"]
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
