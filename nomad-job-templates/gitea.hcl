# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent smartindent syntax=hcl:
job "gitea" {
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
  group "gitea" {
    count = 1
    restart {
      attempts = 3
      interval = "2m"
      delay = "30s"
      mode = "fail"
    }
    ephemeral_disk {
      size    = "1000"
      sticky  = true
      migrate = true
    }
    network {
      mode = "bridge"
    }
    service {
      name = "gitea"
      #tags = ["nomad", "global", "gitea", "http", "expose"]
      port = "3000"
      connect {
        sidecar_service {
          tags = ["http", "consul-connect", "hostHeaderBegin=gitea"]
        }
      }
      #check {
      #  name     = "alive"
      #  type     = "tcp"
      #  interval = "30s"
      #  timeout  = "2s"
      #}
    }
    service {
      name = "giteapostgres"
      #tags = ["nomad", "global", "gitea", "postgres"]
      port = "5432"
      connect {
        sidecar_service {}
      }
      #check {
      #  name     = "alive"
      #  type     = "tcp"
      #  interval = "30s"
      #  timeout  = "2s"
      #}
    }
    task "gitea" {
      driver = "docker"
      env {
        DB_TYPE = "postgres"
        DB_HOST = "127.0.0.1:5432"
        DB_NAME = "gitea"
        DB_USER = "gitea"
        DB_PASSWD = "gitea"
      }
      config {
        image = "gitea/gitea:1.11.3"
        mounts = [
            {
              type = "volume"
              target = "/data"
              source = "data"
            }
        ]
      }
      resources {
        cpu    = 300
        memory = 512
      }
    }
    task "postgres" {
      driver = "docker"
      env {
        POSTGRES_DB = "gitea"
        POSTGRES_USER = "gitea"
        POSTGRES_PASSWORD = "gitea"
        PGDATA = "${NOMAD_TASK_DIR}/data"
      }
      config {
        image = "postgres:12-alpine"
      }
      resources {
        cpu    = 300 # 500 MHz
        memory = 256
      }
    }
  }
}
