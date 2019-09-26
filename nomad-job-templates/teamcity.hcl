# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent smartindent syntax=hcl:
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
  group "server" {
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
    task "server" {
      driver = "docker"
      env {
        # https://confluence.jetbrains.com/pages/viewpage.action?pageId=113084582#HowTo...-hardwarerequirements
        TEAMCITY_SERVER_MEM_OPTS = "-Xmx1100m"
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
        memory = 1220
        network {
          port "http" {}
        }
      }
      service {
        name = "teamcity"
        tags = ["nomad", "global", "teamcity", "http", "server", "expose", "healthMode=http", "healthMethod=GET", "healthPath=/login.html"]
        port = "http"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "30s"
          timeout  = "2s"
        }
      }
    }
  }
  group "agent" {
    count = 2
    restart {
      attempts = 3
      interval = "2m"
      delay = "30s"
      mode = "fail"
    }
    task "agent" {
      driver = "docker"
      template {
        # https://www.nomadproject.io/docs/runtime/environment.html#task-directories
        destination = "secrets/file.env"
        env = true
        data = <<EOH
{{ "SERVER_URL=http://{{ range service \"teamcity|any\" }}{{ .Address }}:{{ .Port }}{{ end }}" }}
EOH
      }
      config {
        image = "jetbrains/teamcity-agent:latest"
        port_map {
          agent = 9090
        }
      }
      resources {
        cpu    = 500
        memory = 200
        network {
          port "agent" {}
        }
      }
      service {
        name = "teamcity-agent"
        tags = ["nomad", "global", "teamcity", "agent"]
        port = "agent"
      }
    }
  }
}
