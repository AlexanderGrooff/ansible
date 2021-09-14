job "registry" {
  datacenters = ["dc1"]
  type        = "service"

  group "registry" {
    count = 1

    volume "registry" {
        type = "host"
        read_only = false
        source = "registry"
    }

    network {
      port "http" {
        static = 5000
      }
    }

    task "registry" {
      driver = "docker"

      config {
        image        = "registry:2"
        ports        = ["http"]
      }

      volume_mount {
          volume = "registry"
          read_only = false
          destination = "/var/lib/registry"
      }

      service {
        name = "registry"
        port = "http"

        check {
            type     = "http"
            path     = "/"
            interval = "2s"
            timeout  = "2s"
        }
      }
    }
  }
}
