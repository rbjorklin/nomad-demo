# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent smartindent syntax=hcl:
job "freeipa" {
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
  group "freeipa" {
    count = 1
    restart {
      attempts = 3
      interval = "2m"
      delay = "30s"
      mode = "fail"
    }
    # maybe use this if /local can be mapped to /data?
    #ephemeral_disk {
    #  size    = "2048"
    #  sticky  = true
    #  migrate = true
    #}
    task "server" {
      driver = "docker"
      config {
        hostname = "freeipa.rbjorklin.com"
        image = "freeipa/freeipa-server:fedora-30"
        args = [
          "--unattended",
          "--ds-password=123admin",
          "--admin-password=123admin",
          "--domain=rbjorklin.com",
          "--realm=RBJORKLIN.COM",
          "--no-ntp",
          "--no-ssh",
          "--no-sshd",
          "--no-dns-sshfp",
        ]
        mounts = [
            {
              type = "bind"
              target = "/sys/fs/cgroup"
              source = "/sys/fs/cgroup"
              readonly = true
            },
            {
              type = "volume"
              target = "/data"
              source = "ipa-data"
            },
            {
              type = "tmpfs"
              target = "/run"
            },
            {
              type = "tmpfs"
              target = "/tmp"
            }
        ]
        sysctl {
            net.ipv6.conf.all.disable_ipv6 = 0
        }
        port_map {
          http = 80
          ldap = 389
          https = 443
        }
      }
      resources {
        cpu    = 500
        memory = 1024
        network {
          port "http" {}
          port "https" {}
          port "ldap" {}
        }
      }
      service {
        name = "freeipa"
        tags = ["nomad", "global", "freeipa", "http", "expose"]
        port = "http"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "30s"
          timeout  = "2s"
        }
      }
      service {
        name = "freeipa"
        tags = ["nomad", "global", "freeipa", "https", "expose"]
        port = "https"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "30s"
          timeout  = "2s"
        }
      }
      service {
        name = "freeipa"
        tags = ["nomad", "global", "freeipa", "ldap", "tcp", "expose"]
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
