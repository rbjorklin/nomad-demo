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
    meta {
      dummy = "reload"
      environment = "dev"
    }
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
    network {
      mode = "bridge"
    }
    service {
      name = "elastic"
      tags = ["group=graylog", "healthMode=http", "healthMethod=GET", "healthPath=/_cluster/health"]
      port = "9200" # 9300 is the replication port
      #check {
      #  name     = "alive"
      #  type     = "http"
      #  path     = "/_cluster/health"
      #  interval = "30s"
      #  timeout  = "2s"
      #}
    }
    service {
      name = "graylogsyslog"
      port = "1514"
    }
    service {
      name = "grayloggelf"
      port = "12201"
      connect {
        sidecar_service {}
      }
    }
    service {
      name = "graylogweb"
      #tags = ["http", "healthMode=http", "healthMethod=HEAD", "healthPath=/api/system/lbstatus"]
      port = "9000"
      connect {
        sidecar_service {
          tags = ["http", "consul-connect", "hostHeaderBegin=graylog", "healthMode=http", "healthMethod=HEAD", "healthPath=/api/system/lbstatus"]
        }
      }
      #check {
      #  name     = "alive"
      #  type     = "http"
      #  method   = "HEAD"
      #  path     = "/api/system/lbstatus"
      #  interval = "30s"
      #  timeout  = "2s"
      #}
    }
    service {
      name = "mongo"
      tags = ["group=graylog"]
      port = "27017"
      #check {
      #  name     = "alive"
      #  type     = "tcp"
      #  interval = "30s"
      #  timeout  = "2s"
      #}
    }
    task "graylog" {
      driver = "docker"
      env {
        # CHANGE ME (must be at least 16 characters)!
        GRAYLOG_PASSWORD_SECRET = "somepasswordpepper"
        # Password: admin
        GRAYLOG_ROOT_PASSWORD_SHA2 = "8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918"
        GRAYLOG_HTTP_BIND_ADDRESS = "0.0.0.0"
        GRAYLOG_HTTP_EXTERNAL_URI = "http://graylog.rbjorklin.com/"
        GRAYLOG_MONGODB_URI = "mongodb://127.0.0.1:27017/graylog"
        GRAYLOG_ELASTICSEARCH_HOSTS = "http://127.0.0.1:9200"
      }
      config {
        image = "graylog/graylog:3.2"
      }
      resources {
        cpu    = 300
        memory = 1000
      }
    }
    task "mongodb" {
      driver = "docker"
      config {
        image = "mongo:4.0"
      }
      resources {
        cpu    = 300
        memory = 200
      }
    }
    task "elastic" {
      driver = "docker"
      #env {
      #  ES_PATH_CONF = "/local"
      #}
#      template {
#        destination   = "local/elasticsearch.yml"
#        splay = "60s"
#        data = <<EOH
#cluster.name: graylog
#http.host: "0.0.0.0"
#network.host: "0.0.0.0"
#discovery.type: "single-node"
#transport.host: "localhost"
#path:
#  logs: /local/log/elasticsearch
#  data: /local/data/elasticsearch
#EOH
#      }
#      template {
#        destination   = "local/jvm.options"
#        splay = "60s"
#        data = <<EOH
#-Xms512m
#-Xmx512m
#EOH
#      }
      config {
        image = "elasticsearch:6.8.7"
      }
      resources {
        cpu    = 300
        memory = 1500
      }
    }
  }
}
