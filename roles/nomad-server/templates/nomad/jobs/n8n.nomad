job "n8n" {
  datacenters = ["dc1"]
  group "postgres" {

    network {
      mode = "bridge"

      port "db" { static = 5432 }
    }

    volume "postgres" {
        type = "host"
        read_only = false
        source = "postgres"
    }

    service {
      name = "postgres"
      port = "db"
    
      connect {
        sidecar_service {}
      }
    }

    task "postgres" {
      driver = "docker"

      config {
        image        = "postgres:13.4"
        ports        = ["db"]
      }

      volume_mount {
          volume = "postgres"
          read_only = false
          destination = "/var/lib/postgresql/data"
      }

      env {
        POSTGRES_DB       = "n8n"
        POSTGRES_USER     = "postgres"
        POSTGRES_PASSWORD = "postgres"
      }

      resources {
        cpu    = 300
        memory = 300
      }
    }
  }

  group "n8n" {
    count = 1
    network {
      mode = "bridge"

      port "http" {
        static = -1
      }
    }

    service {
      name = "n8n"
      port = "http"

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "postgres"
              local_bind_port  = 5432
            }
          }
        }
      }

      check {
        type     = "http"
        path     = "/"
        interval = "5s"
        timeout = "120s"
      }
    }

    task "n8n" {
      driver = "docker"
      env {
        DB_TYPE = "postgresdb"
        DB_POSTGRESDB_DATABASE = "n8n"
        DB_POSTGRESDB_HOST = "localhost"
        DB_POSTGRESDB_PORT = 5432
        DB_POSTGRESDB_USER = "postgres"
        DB_POSTGRESDB_PASSWORD = "postgres"
        DOMAIN_NAME = "alex.home"
        SUBDOMAIN = "n8n"
        N8N_HOST = "n8n.alex.home"
        N8N_PORT = "${NOMAD_PORT_http}"
        WEBHOOK_TUNNEL_URL = "http://n8n.alex.home/"
        VUE_APP_URL_BASE_API="http://n8n.alex.home/"
        GENERIC_TIMEZONE = "Europe/Amsterdam"
        SSL_EMAIL = "{{ letsencrypt.email }}"
        N8N_PROTOCOL = "http"
        N8N_LOG_LEVEL = "verbose"
        NODE_ENV = "production"
      }

      config {
        image = "n8nio/n8n:0.137.0"
        ports = ["http"]
      }
    }
  }
}
