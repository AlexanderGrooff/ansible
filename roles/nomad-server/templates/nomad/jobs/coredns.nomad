job "coredns" {
  datacenters = ["dc1"]
  type        = "service"

  group "coredns" {
    count = 2

    network {
      port "http" { static = "53" }
    }

    task "coredns" {
      driver = "docker"
      config {
        image = "coredns/coredns:1.8.4"
        args = ["-conf", "local/coredns/corefile"]
        network_mode = "host"
      }

      service {
        port = "http"
        name = "coredns"
      }

      resources {
        cpu    = 100
        memory = 128
      }

      template {
data = <<EOH
. {
  forward . 1.1.1.1
  log
}
home. {
  bind lo
  forward . {{ nomad_tailscale_ips | join (' ') }}
  log
}
EOH
        destination = "local/coredns/corefile"
      }
    }
  }
}
