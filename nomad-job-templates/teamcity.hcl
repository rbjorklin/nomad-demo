job "teamcity" {
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
  group "teamcity-server" {
    count = 1
    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }
    ephemeral_disk {
      size = 300
    }
    task "teamcity_server" {
      driver = "docker"
      env {
        TEAMCITY_SERVER_MEM_OPTS = "-Xmx1800m"
      }
      config {
        image = "jetbrains/teamcity-server:latest"
        port_map {
          http = 8111
        }
        volume_driver = "local"
        volumes = [
          "teamcity-data:/data/teamcity_server/datadir",
          "teamcity-logs:/opt/teamcity/logs",
        ]
      }
      resources {
        cpu    = 2000
        memory = 2048
        network {
          mbits = 1000
          port "http" {}
        }
      }
      service {
        name = "teamcity-server"
        tags = ["nomad", "global", "teamcity", "http", "server"]
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
  group "teamcity-agent" {
    count = 2
    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }
    ephemeral_disk {
      size = 300
    }
    task "teamcity_agent" {
      driver = "docker"
      env {
        SERVER_URL = "http://teamcity-server.service.consul:${NOMAD_PORT_teamcity_server_http}"
      }
      config {
        image = "jetbrains/teamcity-agent:latest"
      }
      resources {
        cpu    = 500 # 500 MHz
        memory = 200
        network {
          mbits = 10
        }
      }
      service {
        name = "teamcity-agent"
        tags = ["nomad", "global", "teamcity", "http", "agent"]
      }
    }
  }
}
