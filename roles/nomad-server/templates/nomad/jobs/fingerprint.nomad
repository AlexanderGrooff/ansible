job "fingerprint" {
  datacenters = ["dc1"]
  group "postgres" {

    network {
      mode = "bridge"

      port "db" { static = 5432 }
    }

    volume "postgres" {
        type = "host"
        read_only = false
        source = "fingerprint"
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

  group "fingerprint" {
    count = 2
    network {
      mode = "bridge"

      port "http" {
        static = -1
        to = 3000
      }
    }

    service {
      name = "fingerprint"
      port = "http"

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "postgres"
              local_bind_port  = 5432
              local_bind_address = "0.0.0.0"
            }
          }
        }
      }
    }

    task "fingerprint" {
      driver = "docker"
      env {
        POSTGRES_DATABASE       = "postgres"
        POSTGRES_HOST           = "${NOMAD_UPSTREAM_IP_postgres}"
        POSTGRES_PORT           = "${NOMAD_UPSTREAM_PORT_postgres}"
        POSTGRES_USER           = "postgres"
        POSTGRES_PASSWORD       = "postgres"
        SECRET_KEY              = "{{ fingerprint.secret_key }}"
        DJANGO_SETTINGS_MODULE  = "fingerprint_api.settings.production"
        DJANGO_DEBUG            = false
      }

      config {
        image = "ghcr.io/alexandergrooff/fingerprint-api:0.1.1"
        ports = ["http"]
      }
    }
  }
}
