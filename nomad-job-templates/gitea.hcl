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
      size = 300
    }
    task "gitea" {
      driver = "docker"
      env {
        DB_TYPE = "postgres"
        DB_HOST = "gitea-postgres.service.consul:${NOMAD_PORT_gitea_postgres_postgres}"
        DB_NAME = "gitea"
        DB_USER = "gitea"
        DB_PASSWD = "gitea"
      }
      config {
        image = "gitea/gitea:1.8.3"
        port_map {
          http = 3000
          ssh = 22
        }
        mounts = [
            {
              type = "volume"
              target = "/data"
              source = "data"
            }
        ]
      }
      resources {
        cpu    = 500
        memory = 512
        network {
          port "http" {}
          port "ssh" {}
        }
      }
      service {
        name = "gitea"
        tags = ["nomad", "global", "gitea", "http"]
        port = "http"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "30s"
          timeout  = "2s"
        }
      }
    }
    task "gitea_postgres" {
      driver = "docker"
      env {
        POSTGRES_DB = "gitea"
        POSTGRES_USER = "gitea"
        POSTGRES_PASSWORD = "gitea"
      }
      config {
        image = "postgres:11-alpine"
        port_map {
          postgres = 5432
        }
        mounts = [
            {
              type = "volume"
              target = "/var/lib/postgresql/data"
              source = "pgdata"
            }
        ]
      }
      resources {
        cpu    = 500 # 500 MHz
        memory = 256
        network {
          port "postgres" {}
        }
      }
      service {
        name = "gitea-postgres"
        tags = ["nomad", "global", "gitea", "postgres"]
        port = "postgres"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "30s"
          timeout  = "2s"
        }
      }
    }
  }
}
