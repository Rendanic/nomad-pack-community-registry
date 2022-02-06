job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .loki.datacenters | toPrettyJson ]]

  [[ if .loki.constraints ]][[ range $idx, $constraint := .loki.constraints ]]
  constraint {
    attribute = [[ $constraint.attribute | quote ]]
    value     = [[ $constraint.value | quote ]]
    [[- if ne $constraint.operator "" ]]
    operator  = [[ $constraint.operator | quote ]]
    [[- end ]]
  }
  [[- end ]][[- end ]]

  group "loki" {
    count = 1

    network {
      mode = "bridge"

      port "http" {
        static = [[ .loki.http_port ]]
        to = [[ .loki.http_port ]]
      }

      port "grpc" {
        to = [[ .loki.grpc_port ]]
      }

      [[- if .loki.dns ]]
      dns {
        [[- if .loki.dns.source ]]
          servers = [[ .loki.dns.source | toPrettyJson ]]
        [[- end ]]
        [[- if .loki.dns.searches ]]
          searches = [[ .loki.dns.searches | toPrettyJson ]]
        [[- end ]]
        [[- if .loki.dns.options ]]
          options = [[ .loki.dns.options | toPrettyJson ]]
        [[- end ]]
      }
      [[- end ]]

    }

    service {
      name = "loki"
      port = "[[ .loki.http_port ]]"
      tags = [[ .loki.consul_tags | toPrettyJson ]]

      connect {
        sidecar_service {}
      }
    }

    task "loki" {
      driver = "docker"

      config {
        image = "grafana/loki:[[ .loki.version_tag ]]"
        [[- if ne .loki.loki_yaml "" ]]
        args = [
          "--config.file=/etc/loki/config/loki.yml",
        ]
        volumes = [
          "local/config:/etc/loki/config",
          [[- if ne .loki.rules_yaml "" ]]
          "local/rules:/etc/loki/rules/default",
          [[- end ]]
        ]
        [[- end ]]
      }

      resources {
        cpu    = [[ .loki.resources.cpu ]]
        memory = [[ .loki.resources.memory ]]
      }

      [[- if ne .loki.loki_yaml "" ]]
      template {
        data = <<EOH
[[ .loki.loki_yaml ]]
EOH
        change_mode   = "signal"
        change_signal = "SIGHUP"
        destination   = "local/config/loki.yml"
      }
      [[- end ]]

      [[- if ne .loki.rules_yaml "" ]]
      template {
        data = <<EOH
[[ .loki.rules_yaml ]]
EOH
        change_mode   = "signal"
        change_signal = "SIGHUP"
        destination   = "local/rules/rules.yaml"
      }
      [[- end ]]
    }
  }
}
