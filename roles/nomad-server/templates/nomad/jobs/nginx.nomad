job "nginx" {
  datacenters = ["dc1"]

  group "nginx" {
    count = 2

    network {
      port "http" {
        static = 80
      }
    }

    service {
      name = "nginx"
      port = "http"
    }

    task "nginx" {
      driver = "docker"

      config {
        image = "nginx"

        ports = ["http"]

        volumes = [
          "local:/etc/nginx/conf.d",
        ]
      }

      template {
        data = <<EOF
upstream app_backend {
{% raw %}{{ range service "demo-webapp" }}
  server {{ .Address }}:{{ .Port }};
{{ else }}
  server 127.0.0.1:65535; # force a 502
{{ end }}{% endraw %}
}

upstream registry_backend {
{% raw %}{{ range service "registry" }}
  server {{ .Address }}:{{ .Port }};
{{ else }}
  server 127.0.0.1:65535; # force a 502
{{ end }}{% endraw %}
}

server {
  listen 80;
  listen 443;
  server_name alex.home;

  location / {
    proxy_pass http://app_backend;
  }
}

server {
  listen 80;
  listen 443;
  server_name docker.alex.home;

  # disable any limits to avoid HTTP 413 for large image uploads
  client_max_body_size 0;

  # required to avoid HTTP 411: see Issue #1486 (https://github.com/moby/moby/issues/1486)
  chunked_transfer_encoding on;

  location / {
    proxy_pass http://registry_backend;
    proxy_set_header  Host              $http_host;   # required for docker client's sake
    proxy_set_header  X-Real-IP         $remote_addr; # pass on real client's IP
    proxy_set_header  X-Forwarded-For   $proxy_add_x_forwarded_for;
    proxy_set_header  X-Forwarded-Proto $scheme;
    proxy_read_timeout                  900;
  }
}
EOF

        destination   = "local/load-balancer.conf"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }
    }
  }
}
