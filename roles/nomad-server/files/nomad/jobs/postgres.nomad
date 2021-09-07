job "postgres-server" {
  datacenters = ["dc1"]
  type        = "service"

  group "postgres-server" {
    count = 1

    volume "postgres" {
      type      = "host"
      read_only = false
      source    = "postgres"
    }

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "postgres-server" {
      driver = "docker"

      volume_mount {
        volume      = "postgres"
        destination = "/var/lib/postgres"
        read_only   = false
      }

      env = {
        "MYSQL_ROOT_PASSWORD" = "password"
      }

      config {
        image = "postgres"

        port_map {
          db = 5432
        }
      }

      resources {
        cpu    = 500
        memory = 1024

        network {
          port "db" {
            static = 5432
          }
        }
      }

      service {
        name = "postgres-server"
        port = "db"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
