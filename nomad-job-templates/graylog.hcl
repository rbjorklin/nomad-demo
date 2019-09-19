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
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }
    ephemeral_disk {
      size = 300
    }
    task "graylog" {
      driver = "docker"
      env {
        # CHANGE ME (must be at least 16 characters)!
        GRAYLOG_PASSWORD_SECRET = "somepasswordpepper"
        # Password: admin
        GRAYLOG_ROOT_PASSWORD_SHA2 = "8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918"
        GRAYLOG_HTTP_BIND_ADDRESS = "0.0.0.0"
        GRAYLOG_HTTP_EXTERNAL_URI = "http://graylog.test:${NOMAD_PORT_http}/"
        GRAYLOG_MONGODB_URI = "mongodb://${NOMAD_ADDR_graylog_mongodb_mongo}/graylog"
        GRAYLOG_ELASTICSEARCH_HOSTS = "http://${NOMAD_ADDR_graylog_elastic_elastic_rest}"
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
        tags = ["nomad", "global", "graylog", "http"]
        port = "http"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
    task "graylog_mongodb" {
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
        name = "graylog-mongo"
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
    task "graylog_elastic" {
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
          elastic_rest = 9200
          elastic_comm = 9300
        }
      }
      resources {
        cpu    = 1000
        memory = 1024
        network {
          port "elastic_rest" {}
          port "elastic_comm" {}
        }
      }
      service {
        name = "graylog-elastic"
        tags = ["nomad", "global", "graylog", "elastic"]
        port = "elastic_rest"
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
