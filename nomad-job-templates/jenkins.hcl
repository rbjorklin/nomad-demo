# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent smartindent syntax=hcl:
job "jenkins" {
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
  group "jenkins" {
    meta {
      dummy = "reload3"
    }
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
    # https://github.com/hashicorp/nomad/issues/6956
    # https://nomadproject.io/docs/job-specification/network/#bridge-mode
    network {
      mode = "bridge"
      #port "http" {
      #  to = 8080
      #}
      #port "http" {
      #  static = 8080
      #  to = 8080
      #}
    }
    service {
      name = "jenkins"
      #tags = ["nomad", "http", "consul-connect", "hostHeaderBegin=jenkins"]
      port = "8080" #"http" # might have to be 8080 to map to jenkins port
      connect {
        sidecar_service {
          tags = ["http", "consul-connect", "hostHeaderBegin=jenkins"]
        }
      }
    }
    task "jenkins" {
      driver = "docker"
      config {
        image = "jenkins/jenkins:lts-alpine"
        #port_map {
        #  http = 8080
        #  build_executor = 50000
        #}
        #volume_driver = "rbd"
        #volumes = [
        #  "jenkins_home:/var/jenkins_home"
        #]
      }
      #resources {
      #  cpu    = 500 # 500 MHz
      #  memory = 512
      #}
      #service {
      #  name = "jenkins"
      #  tags = ["nomad", "global", "jenkins", "http", "expose"]
      #  port = "http"
      #  check {
      #    name     = "alive"
      #    type     = "tcp"
      #    interval = "30s"
      #    timeout  = "2s"
      #  }
      #}
    }
  }
}
