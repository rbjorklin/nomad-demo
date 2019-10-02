# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent smartindent syntax=hcl:
job "haproxy" {
  datacenters = ["{{ (datasource "config").datacenter }}"]
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
      attempts = 3
      interval = "2m"
      delay = "30s"
      mode = "fail"
    }
    task "haproxy" {
      env {
        STATS_USER = "haproxy"
        STATS_PASSWD = "haproxy"
      }
      template {
        destination   = "local/haproxy.conf"
        change_mode   = "signal"
        change_signal = "SIGUSR2"
        splay = "60s"
        data = <<EOH
{{ (ds "config").haproxy_bootstrap_conf -}}
EOH
      }
      driver = "docker"
      config {
        image = "haproxy:alpine"
        args = [
          "-f",
          "/local/haproxy.conf",
        ]
        network_mode = "host"
      }
      resources {
        cpu    = 500 # 500 MHz
        memory = 256
        network {
          port "http" {
            static = 80
          }
          port "https" {
            static = 443
          }
          port "ldap" {
            static = 389
          }
        }
      }
      service {
        name = "haproxy"
        tags = ["nomad", "global", "haproxy", "http"]
        port = "http"
        check {
          name     = "http"
          type     = "http"
          path     = "/haproxy/status"
          interval = "30s"
          timeout  = "2s"
        }
      }
      service {
        name = "haproxy"
        tags = ["nomad", "global", "haproxy", "https"]
        port = "https"
        check {
          name     = "https"
          type     = "tcp"
          interval = "30s"
          timeout  = "2s"
        }
      }
    }
  }
}
