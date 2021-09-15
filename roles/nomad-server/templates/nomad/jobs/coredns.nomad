job "coredns" {
  datacenters = ["dc1"]
  type        = "service"

  group "coredns" {
    count = 2

    network {
      port "http" { static = "53" }
      port "health" { static = "8081" }
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
        check {
          type = "http"
          port = "health"
          path = "/health"
          interval = "5s"
          timeout = "30s"
        }
      }

      resources {
        cpu    = 300
        memory = 300
      }

      template {
data = <<EOH
. {
  hosts {
    {% for tailscale_ip in nomad_tailscale_ips %}
      {% for nginx_domain in nginx_domains %}
        {{ tailscale_ip}} {{ nginx_domain }}
      {% endfor %}
    {% endfor %}
    reload 1s
  }
  loadbalance
  forward . 1.1.1.1
  health :8081
  log
  errors
}
EOH
        destination = "local/coredns/corefile"
      }
    }
  }
}
