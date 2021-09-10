job "postgres" {
  datacenters = ["dc1"]
  type        = "service"

  group "postgres" {

    network {
      port "db" { static = 5432 }
    }

    volume "postgres" {
        type = "host"
        read_only = false
        source = "postgres"
    }

    task "postgres" {
      driver = "docker"

      config {
        image        = "postgres:13.4"
        network_mode = "host"
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

      service {
        name = "postgres"
        port = "db"
        check {
          type     = "tcp"
          port     = "db"
          interval = "30s"
          timeout  = "60s"
        }
      }

      resources {
        cpu    = 1024
        memory = 1024
      }
    }
  }
}
