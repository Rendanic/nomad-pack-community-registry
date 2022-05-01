# Loki

[Loki](https://grafana.com/oss/loki/) is a horizontally-scalable, highly-available, multi-tenant log aggregation system written by [Grafana Labs](https://grafana.com/) inspired by Prometheus.

This pack deploys a single instance of a Loki application using the `grafana/loki` Docker image and Consul Service named "loki".

## Variables

- `job_name` (string "") - The name to use as the job name which overrides using the pack name.
- `datacenters` (list(string) ["dc1"]) - A list of datacenters in the region which are eligible for
  task placement.
- `region` (string "global") - The region where the job should be placed.
- `dns` (object) - Network DNS configuration
- `constraints`
- `version_tag` (string "latest" ) - The version of Grafana Image
- `resources` (object) - CPU and Memory configuration for Grafana
- `consul_tags` (list(string)) - Service tag definition for Consul
- `http_port`
- `grpc_port`
- `loki_yaml`
- `rules_yaml`
- `volume` (object) - Persistent Volume configuration for Grafana

## Dependencies

This pack requires Linux clients to run properly.
