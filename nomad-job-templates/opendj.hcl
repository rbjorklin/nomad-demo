# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent smartindent syntax=hcl:
job "opendj" {
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
  group "opendj" {
    count = 1
    restart {
      attempts = 3
      interval = "2m"
      delay = "30s"
      mode = "fail"
    }
    ephemeral_disk {
      size    = "6000"
      sticky  = true
      migrate = true
    }
    task "server" {
      driver = "docker"
      env {
        BASE_DN = "dc=rbjorklin,dc=com"
        ROOT_USER_DN = "cn=admin"
      }
      config {
        hostname = "opendj.rbjorklin.com"
        image = "openidentityplatform/opendj:4.4.3"
        port_map {
          ldap = 1389
          ldaps = 1636
          replication = 4444
        }
      }
      resources {
        cpu    = 500
        memory = 1024
        network {
          port "ldap" {}
          port "ldaps" {}
          port "replication" {}
        }
      }
      service {
        name = "opendj"
        tags = ["nomad", "global", "opendj", "ldap", "expose"]
        port = "ldap"
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
