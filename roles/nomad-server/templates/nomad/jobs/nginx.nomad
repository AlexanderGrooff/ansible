job "nginx" {
  datacenters = ["dc1"]

  group "nginx" {
    count = 2

    network {
      port "http" {
        static = 80
        host_network = "private"
      }
      port "https" {
        static = 443
        host_network = "public"
      }
    }

    service {
      name = "nginxhttp"
      port = "http"
    }

    service {
      name = "nginxhttps"
      port = "https"
    }

    volume "certbot" {
        type = "host"
        read_only = true
        source = "certbot"
    }

    task "nginx" {
      driver = "docker"

      config {
        image = "nginx"

        ports = ["http", "https"]

        volumes = [
          "local:/etc/nginx/conf.d",
        ]
      }

      volume_mount {
          volume = "certbot"
          read_only = true
          destination = "/etc/letsencrypt"
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

server {
  listen 80;
  listen 443 ssl;
  server_name agrooff.com alex.home;

  include /etc/nginx/conf.d/ssl-options.conf;

  location / {
    proxy_pass http://app_backend;
    include /etc/nginx/conf.d/proxy-options.conf;
  }
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
  listen 443 ssl;
  server_name docker.agrooff.com docker.alex.home;

  allow 100.64.0.0/10;
  deny all;

  include /etc/nginx/conf.d/ssl-options.conf;

  # disable any limits to avoid HTTP 413 for large image uploads
  client_max_body_size 0;

  # required to avoid HTTP 411: see Issue #1486 (https://github.com/moby/moby/issues/1486)
  chunked_transfer_encoding on;

  location / {
    proxy_pass http://registry_backend;
    include /etc/nginx/conf.d/proxy-options.conf;
  }
}

upstream n8n_backend {
{% raw %}{{ range service "n8n" }}
  server {{ .Address }}:{{ .Port }};
{{ else }}
  server 127.0.0.1:65535; # force a 502
{{ end }}{% endraw %}
}

server {
  listen 80;
  listen 443 ssl;
  server_name n8n.agrooff.com n8n.alex.home;

  allow 100.64.0.0/10;
  deny all;

  include /etc/nginx/conf.d/ssl-options.conf;

  location / {
    proxy_pass http://n8n_backend;
    include /etc/nginx/conf.d/proxy-options.conf;
  }
}
EOF

        destination   = "local/load-balancer.conf"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }

      template {
        data = <<EOF
proxy_set_header  Host              $http_host;   # required for docker client's sake
proxy_set_header  X-Real-IP         $remote_addr; # pass on real client's IP
proxy_set_header  X-Forwarded-For   $proxy_add_x_forwarded_for;
proxy_set_header  X-Forwarded-Proto $scheme;
proxy_read_timeout                  900;
EOF
        destination   = "local/proxy-options.conf"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }

      template {
        data = <<EOF
ssl_certificate /etc/letsencrypt/live/agrooff.com/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/agrooff.com/privkey.pem;

ssl_session_cache shared:le_nginx_SSL:10m;
ssl_session_timeout 1440m;
ssl_session_tickets off;

ssl_protocols TLSv1.2 TLSv1.3;
ssl_prefer_server_ciphers off;

ssl_ciphers "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384";
EOF
        destination   = "local/ssl-options.conf"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }
    }
  }
}
