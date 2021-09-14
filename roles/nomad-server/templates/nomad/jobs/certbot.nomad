job "certbot" {
    datacenters = ["dc1"]
    priority = 100
    type = "batch"

    periodic {
        cron = "@weekly"
        prohibit_overlap = true
    }

    group "certbot" {
        volume "certbot" {
            type = "host"
            read_only = false
            source = "certbot"
        }

        task "certbot" {
            driver = "docker"

            config {
                image = "certbot/dns-cloudflare:v1.19.0"
                entrypoint = [ "certbot" ]
                command = "certonly"
                args = [
                    "--config", "${NOMAD_TASK_DIR}/certbot_config.ini",
                    "--dns-cloudflare",
                    "--dns-cloudflare-credentials", "${NOMAD_TASK_DIR}/cloudflare_creds.ini",
                    "-d", "agrooff.com",
                    "-d", "*.agrooff.com",
                ]
            }

            volume_mount {
                volume = "certbot"
                read_only = false
                destination = "/etc/letsencrypt"
            }

            template {
                data = <<EOH
# Cloudflare API credentials used by Certbot
dns_cloudflare_api_token = "{{ letsencrypt.cloudflare_api_token }}"
EOH
                destination = "${NOMAD_TASK_DIR}/cloudflare_creds.ini"
            }

            template {
                data = <<EOH
email = {{ letsencrypt.email }}
agree-tos = true
EOH
                destination = "${NOMAD_TASK_DIR}/certbot_config.ini"
            }
        }
    }
}
