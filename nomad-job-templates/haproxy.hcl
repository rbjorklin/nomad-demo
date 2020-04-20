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
    meta {
      dummy = "reload6"
      environment = "dev"
    }
    count = 3
    restart {
      attempts = 3
      interval = "2m"
      delay = "30s"
      mode = "fail"
    }
    network {
      mode = "bridge"
      port "http" {
        static = 80
        to = 80
      }
      #port "https" {
      #  static = 443
      #  to = 443
      #}
    }
    service {
      name = "haproxy"
      tags = ["nomad", "global", "haproxy", "http"]
      port = "http"
      # the check only works because of the static port map above
      # https://github.com/hashicorp/nomad/issues/6120
      check {
        name     = "http"
        type     = "http"
        path     = "/haproxy/status"
        interval = "30s"
        timeout  = "2s"
      }
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "jenkins"
              local_bind_port = 8080
            }
            upstreams {
              destination_name = "consul"
              local_bind_port = 8500
            }
            upstreams {
              destination_name = "nexus"
              local_bind_port = 8081
            }
            upstreams {
              destination_name = "graylogweb"
              local_bind_port = 9000
            }
            upstreams {
              destination_name = "gitea"
              local_bind_port = 3000
            }
            upstreams {
              destination_name = "grafana"
              local_bind_port = 3001
            }
            upstreams {
              destination_name = "prometheus"
              local_bind_port = 9090
            }
            upstreams {
              destination_name = "alertmanager"
              local_bind_port = 9093
            }
          }
        }
      }
    }
    #service {
    #  name = "haproxy"
    #  tags = ["nomad", "global", "haproxy", "https"]
    #  port = "https"
    #  #check {
    #  #  name     = "https"
    #  #  type     = "tcp"
    #  #  interval = "30s"
    #  #  timeout  = "2s"
    #  #}
    #  connect {
    #    sidecar_service {
    #      proxy {
    #        upstreams {
    #          destination_name = "jenkins"
    #          local_bind_port = 8080
    #        }
    #      }
    #    }
    #  }
    #}
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
        #network_mode = "host"
      }
      resources {
        cpu    = 300 # 500 MHz
        memory = 256
      }
    }
  }
}
