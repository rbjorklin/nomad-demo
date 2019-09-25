# vim: set softtabstop=2 tabstop=2 shiftwidth=2 expandtab autoindent smartindent syntax=hcl:
job "graylog" {
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
  group "graylog" {
    count = 1
    restart {
      attempts = 3
      interval = "2m"
      delay = "30s"
      mode = "fail"
    }
    ephemeral_disk {
      size    = "2000"
      sticky  = true
      migrate = true
    }
    task "graylog" {
      driver = "docker"
      env {
        # CHANGE ME (must be at least 16 characters)!
        GRAYLOG_PASSWORD_SECRET = "somepasswordpepper"
        # Password: admin
        GRAYLOG_ROOT_PASSWORD_SHA2 = "8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918"
        GRAYLOG_HTTP_BIND_ADDRESS = "0.0.0.0"
        GRAYLOG_HTTP_EXTERNAL_URI = "http://graylog.rbjorklin.com:${NOMAD_PORT_http}/"
        GRAYLOG_MONGODB_URI = "mongodb://${NOMAD_ADDR_mongodb_mongo}/graylog"
        GRAYLOG_ELASTICSEARCH_HOSTS = "http://${NOMAD_ADDR_elastic_http}"
      }
      config {
        image = "graylog/graylog:3.1"
        port_map {
           http = 9000
           syslog = 1514
           gelf = 12201
        }
      }
      resources {
        cpu    = 1000
        memory = 1024
        network {
          port "http" {}
          port "syslog" {}
          port "graylog" {}
        }
      }
      service {
        name = "graylog"
        tags = ["nomad", "global", "graylog", "http", "expose"]
        port = "http"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "30s"
          timeout  = "2s"
        }
      }
    }
    task "mongodb" {
      driver = "docker"
      config {
        image = "mongo:4.0"
        port_map {
          mongo = 27017
        }
      }
      resources {
        cpu    = 500 # 500 MHz
        memory = 1024
        network {
          port "mongo" {}
        }
      }
      service {
        name = "mongo"
        tags = ["nomad", "global", "graylog", "mongo"]
        port = "mongo"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
    task "elastic" {
      driver = "docker"
      env {
        http.host = "0.0.0.0"
        transport.host = "localhost"
        network.host = "0.0.0.0"
        discovery.type = "single-node"
        ES_JAVA_OPTS = "-Xms512m -Xmx512m"
      }
      config {
        image = "elasticsearch:6.8.3"
        port_map {
          http = 9200
          replication = 9300
        }
      }
      resources {
        cpu    = 1000
        memory = 1024
        network {
          port "http" {}
          port "replication" {}
        }
      }
      service {
        name = "elastic"
        tags = ["nomad", "global", "graylog", "elastic", "http"]
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
