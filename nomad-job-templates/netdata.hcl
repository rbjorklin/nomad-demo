# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent smartindent syntax=hcl:
job "netdata" {
  datacenters = ["{{ (datasource "config").datacenter }}"]
  type = "system"
  update {
    max_parallel = 1
    min_healthy_time = "10s"
    healthy_deadline = "3m"
    progress_deadline = "10m"
    auto_revert = false
    canary = 0
  }
  group "netdata" {
    count = 1
    restart {
      attempts = 3
      interval = "2m"
      delay = "30s"
      mode = "fail"
    }
    task "netdata" {
      driver = "docker"
      config {
        image = "netdata/netdata:latest"
        network_mode = "host"
        mounts = [
            {
                type = "bind"
                target = "/host/proc"
                source = "/proc"
                readonly = true
            },
            {
                type = "bind"
                target = "/host/sys"
                source = "/sys"
                readonly = true
            },
            {
                type = "bind"
                target = "/var/run/docker.sock"
                source = "/var/run/docker.sock"
                readonly = true
            }
        ]
        cap_add = [
            "SYS_PTRACE",
        ]
        security_opt = [
            "seccomp=unconfined",
        ]
      }
      resources {
        cpu    = 500
        memory = 100
        network {
          port "http" {
            static = 19999
          }
        }
      }
      service {
        name = "netdata"
        tags = ["nomad", "global", "netdata", "http"]
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
