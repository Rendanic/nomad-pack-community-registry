job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .grafana.datacenters | toPrettyJson ]]

  // must have linux for network mode
  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  group "grafana" {
    count = 1

    network {
      mode = "bridge"

    [[- if .grafana.dns ]]
    dns {
      [[- if .grafana.dns.source ]]
        servers = [[ .grafana.dns.source | toPrettyJson ]]
      [[- end ]]
      [[- if .grafana.dns.searches ]]
        searches = [[ .grafana.dns.searches | toPrettyJson ]]
      [[- end ]]
      [[- if .grafana.dns.options ]]
        options = [[ .grafana.dns.options | toPrettyJson ]]
      [[- end ]]
    }
    [[- end ]]

      port "http" {
        to = [[ .grafana.http_port ]]
      }
    }

    [[- if .grafana.volume ]]
    volume "grafana" {
      type = [[ .grafana.volume.type | quote ]]
      read_only = false
      source = [[ .grafana.volume.source | quote ]]
    }
    [[- end ]]

    service {
      name = "grafana"
      port = "[[ .grafana.http_port ]]"
      tags = [[ .grafana.consul_tags | toPrettyJson ]]

      connect {
        sidecar_service {
          proxy {
            [[ range $upstream := .grafana.upstreams ]]
            upstreams {
              destination_name = [[ $upstream.name | quote ]]
              local_bind_port  = [[ $upstream.port ]]
            }
            [[ end ]]
          }
        }
      }
    }

    task "grafana" {
      driver = "docker"

    [[- if .grafana.volume ]]
      volume_mount {
        volume      = "grafana"
        destination = "/var/lib/grafana"
        read_only   = false
      }
    [[- end ]]

      config {
        image = "grafana/grafana:[[ .grafana.version_tag ]]"
        ports = ["http"]
      }

      resources {
        cpu    = [[ .grafana.resources.cpu ]]
        memory = [[ .grafana.resources.memory ]]
      }

      env {
        [[- range $var := .grafana.env_vars ]]
        [[ $var.key ]] = "[[ $var.value ]]"
        [[- end ]]
      }

      [[- if ne .grafana.grafana_task_app_config "" ]]
      template {
        data = <<EOF
[[ .grafana.grafana_task_app_config ]]
EOF
        destination = "/local/grafana/provisioning/datasources/ds.yaml"
      }
    [[- end ]]
    }
  }
}
