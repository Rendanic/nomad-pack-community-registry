variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name"
  type        = string
  // If "", the pack name will be used
  default = ""
}

variable "datacenters" {
  description = "A list of datacenters in the region which are eligible for task placement"
  type        = list(string)
  default     = ["dc1"]
}

variable "region" {
  description = "The region where the job should be placed"
  type        = string
  default     = "global"
}

variable "version_tag" {
  description = "The docker image version. For options, see https://hub.docker.com/grafana/grafana"
  type        = string
  default     = "latest"
}

variable "http_port" {
  description = "The Nomad client port that routes to the Grafana"
  type        = number
  default     = 3000
}

variable "upstreams" {
  description = ""
  type = list(object({
    name = string
    port = number
  }))
}

variable "resources" {
  description = "The resource to assign to the Grafana service task"
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 200,
    memory = 256
  }
}

variable "consul_tags" {
  description = ""
  type = list(string)
  default = []
}

variable "volume" {
  description = "The resource to assign to the Grafana service task"
  type = object({
    type    = string
    source = string
  })
}

variable "dns" {
  description = ""
  type = object({
    servers   = list(string)
    searches = list(string)
    options = list(string)
  })
}

variable "env_vars" {
  description = ""
  type = list(object({
    key   = string
    value = string
  }))
  default = [
    {key = "GF_LOG_LEVEL", value = "DEBUG"},
    {key = "GF_LOG_MODE", value = "console"},
    {key = "GF_SERVER_HTTP_PORT", value = "$${NOMAD_PORT_http}"},
    {key = "GF_PATHS_PROVISIONING", value = "/local/grafana/provisioning"}
  ]
}

variable "grafana_task_app_config" {
  description = "The TOML Traefik configuration to pass to the task."
  type        = string
  default     = <<EOF
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus.service.{{ env "NOMAD_DC" }}.consul:9090
    jsonData:
      exemplarTraceIdDestinations:
        - name: traceID
          datasourceUid: tempo
  - name: Tempo
    type: tempo
    access: proxy
    url: http://tempo.service.{{ env "NOMAD_DC" }}.consul:3400
    uid: tempo
  - name: Loki
    type: loki
    access: proxy
    url: http://loki.service.{{ env "NOMAD_DC" }}.consul:3100
    jsonData:
      derivedFields:
        - datasourceUid: tempo
          matcherRegex: (?:traceID|trace_id)=(\w+)
          name: TraceID
          url: $$${__value.raw}
EOF
}
