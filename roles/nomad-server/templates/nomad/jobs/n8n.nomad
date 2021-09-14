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
        POSTGRES_DB       = "postgres"
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
        static = 5678
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
        timeout = "30s"
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
      }

      config {
        image = "n8nio/n8n:0.137.0"
        ports = ["http"]
      }
    }
  }
}
