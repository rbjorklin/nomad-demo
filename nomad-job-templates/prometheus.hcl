# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent smartindent syntax=hcl:
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
      interval = "2m"
      delay = "30s"
      mode = "fail"
    }
    ephemeral_disk {
      size    = "4000"
      sticky  = true
      migrate = true
    }
    network {
      mode = "bridge"
    }
    service {
      name = "grafana"
      #tags = ["nomad", "global", "grafana", "http", "expose", "healthMode=http", "healthMethod=GET", "healthPath=/api/health"]
      port = "3000"
      connect {
        sidecar_service {
          tags = ["http", "consul-connect", "hostHeaderBegin=grafana", "healthMode=http", "healthMethod=GET", "healthPath=/api/health"]
        }
      }
      #check {
      #  name     = "alive"
      #  type     = "http"
      #  path     = "/api/health"
      #  interval = "30s"
      #  timeout  = "2s"
      #}
    }
    service {
      name = "prometheus"
      #tags = ["nomad", "global", "prometheus", "http", "expose", "healthMode=http", "healthMethod=GET", "healthPath=/-/healthy"]
      port = "9090"
      connect {
        sidecar_service {
          tags = ["http", "consul-connect", "hostHeaderBegin=prometheus", "healthMode=http", "healthMethod=GET", "healthPath=/-/healthy"]
          proxy {
            upstreams {
              destination_name = "consul-http"
              local_bind_port = 8500
            }
          }
        }
      }
      #check {
      #  name     = "alive"
      #  type     = "http"
      #  path     = "/-/healthy"
      #  interval = "30s"
      #  timeout  = "2s"
      #}
    }
    service {
      name = "alertmanager"
      #tags = ["nomad", "global", "alertmanager", "http", "expose", "healthMode=http", "healthMethod=GET", "healthPath=/-/healthy"]
      port = "9093"
      connect {
        sidecar_service {
          tags = ["http", "consul-connect", "hostHeaderBegin=alertmanager", "healthMode=http", "healthMethod=GET", "healthPath=/-/healthy"]
        }
      }
      #check {
      #  name     = "alive"
      #  type     = "http"
      #  path     = "/-/healthy"
      #  interval = "30s"
      #  timeout  = "2s"
      #}
    }
    task "prometheus" {
      driver = "docker"
      config {
        image = "prom/prometheus:latest"
        args = [
          "--config.file",
          "/local/prometheus.yml",
          "--storage.tsdb.path",
          "${NOMAD_TASK_DIR}/data",
        ]
        mounts = [
            {
              type = "volume"
              target = "/prometheus"
              source = "prometheus"
            }
        ]
      }
      resources {
        cpu    = 300 # 500 MHz
        memory = 512
      }
      template {
        destination   = "local/prometheus.yml"
        change_mode   = "signal"
        change_signal = "SIGHUP"
        splay = "60s"
        data = <<EOH
# consul_sd_configs: # TODO: Use this!
scrape_configs:
  - job_name: haproxy
    metrics_path: /haproxy/metrics
    static_configs:
      - targets: ['haproxy.rbjorklin.com']
  - job_name: consul-services
    consul_sd_configs:
      - server: 'localhost:8500'
        tags:
          - prometheus=scrape
        allow_stale: true
EOH
      }
    }
    task "alertmanager" {
      driver = "docker"
      config {
        image = "prom/alertmanager:latest"
        mounts = [
            {
              type = "volume"
              target = "/alertmanager"
              source = "alertmanager"
            }
        ]
      }
      resources {
        cpu    = 300 # 500 MHz
        memory = 512
      }
    }
    task "grafana" {
      driver = "docker"
      config {
        image = "grafana/grafana:6.7.1"
      }
      env {
        # https://grafana.com/docs/grafana/latest/installation/configure-docker/#default-paths
        #GF_PATHS_CONFIG = "${NOMAD_TASK_DIR}/grafana.ini"
        GF_PATHS_DATA = "${NOMAD_TASK_DIR}/data"
        GF_PATHS_PLUGINS = "${NOMAD_TASK_DIR}/plugins"
        GF_PATHS_PROVISIONING = "${NOMAD_TASK_DIR}/provisioning"
      }
      resources {
        cpu    = 500 # 500 MHz
        memory = 512
      }
    }
  }
}
